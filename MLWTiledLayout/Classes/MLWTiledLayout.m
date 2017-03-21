//
//  MLWTiledLayout.m
//  MLWTiledLayout
//
//  Created by Andrew Podkovyrin on 11/01/2017.
//  Copyright (c) 2016 Machine Learning Works
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MLWTiledLayout.h"

@interface MLWTiledLayout ()

@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *cachedAttributes;
@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *cachedSupplementaryViewsAttributes;
@property (assign, nonatomic) NSInteger contentMaxHeight;

@property (assign, nonatomic) CGRect previousRect;
@property (strong, nonatomic) NSArray<UICollectionViewLayoutAttributes*>* previousAttributes;

@end

@implementation MLWTiledLayout

- (void)prepareLayout {
    [super prepareLayout];

    NSParameterAssert(self.delegate);

    self.cachedAttributes = [NSMutableDictionary dictionary];
    self.cachedSupplementaryViewsAttributes = [NSMutableDictionary dictionary];
    self.contentMaxHeight = 0;
    self.previousRect = CGRectZero;
    self.previousAttributes = @[];

    NSInteger columnsCount = [self.delegate numberOfColumnsInTiledLayout:self];
    CGFloat columnWidth = (CGRectGetWidth(self.collectionView.bounds) - self.itemSpacing) / columnsCount;
    NSMutableArray<NSNumber *> *columnHeights = [NSMutableArray arrayWithCapacity:columnsCount];
    for (NSInteger column = 0; column < columnsCount; column++) {
        [columnHeights addObject:@0];
    }

    NSInteger headerOffset = 0, footerOffset = 0;
    NSInteger sectionCount = self.collectionView.numberOfSections;
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        if([self headerHeightForSection:section]) {
            [self cacheAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                atIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                                 withOffest:columnHeights.firstObject.doubleValue * columnWidth + headerOffset + footerOffset];
            headerOffset+=[self headerHeightForSection:section];
        }

        NSInteger itemsCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemsCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGSize size = [self.delegate tiledLayout:self sizeForCellAtIndexPath:indexPath];

            NSInteger bestIndex = NSNotFound;
            CGFloat bestHeight = CGFLOAT_MAX;
            NSInteger length = 0;
            CGFloat height = columnHeights.firstObject.doubleValue;
            for (NSInteger index = 0; index < columnsCount; index++) {
                CGFloat columnHeight = columnHeights[index].doubleValue;
                if (columnHeight == height) {
                    length++;
                }
                else {
                    length = 1;
                    height = columnHeight;
                }
                
                if (length == size.width && height < bestHeight) {
                    bestIndex = index + 1 - length;
                    bestHeight = height;
                }
            }
            
            if (bestIndex == NSNotFound) {
                NSAssert(NO, @"Inconsistency layout, check -tiledLayout:sizeForCellAtIndexPath: method to avoid spaces in layout");
                
                NSInteger length = 0;
                CGFloat height = columnHeights.firstObject.doubleValue;
                for (NSInteger index = 0; index < columnsCount; index++) {
                    CGFloat columnHeight = columnHeights[index].doubleValue;
                    if (columnHeight <= height) {
                        length++;
                    }
                    else {
                        length = 0;
                        height = columnHeight;
                    }
                    
                    if (length >= size.width && height < bestHeight) {
                        bestIndex = index + 1 - length;
                        bestHeight = height;
                    }
                }
            }
            
            for (NSInteger i = bestIndex; i < bestIndex + size.width; i++) {
                columnHeights[i] = @(bestHeight + size.height);
            }
            
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            CGRect frame = CGRectMake(bestIndex * columnWidth, bestHeight * columnWidth  + headerOffset + footerOffset,
                                      size.width * columnWidth, size.height * columnWidth);
            CGFloat halfSpacing = self.itemSpacing / 2.0;
            frame = CGRectInset(frame, halfSpacing, halfSpacing);
            frame = CGRectOffset(frame, halfSpacing, halfSpacing);
            attributes.frame = frame;
            self.cachedAttributes[indexPath] = attributes;
        }
        
        CGFloat pointHeight = [[columnHeights valueForKeyPath:@"@max.doubleValue"] doubleValue];
        for (NSUInteger i = 0; i < columnHeights.count; i++) {
            columnHeights[i] = @(pointHeight);
        }
        
        if([self footerHeightForSection:section]) {
            [self cacheAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                atIndexPath:[NSIndexPath indexPathForRow:itemsCount-1 inSection:section]
                                                 withOffest:columnHeights.firstObject.doubleValue * columnWidth + headerOffset + footerOffset];
            footerOffset+=[self footerHeightForSection:section];
        }
    }
    
    self.contentMaxHeight = columnHeights.firstObject.doubleValue * columnWidth + headerOffset + footerOffset;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    if(CGRectEqualToRect(rect, self.previousRect)) return self.previousAttributes;
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *_Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
        return CGRectIntersectsRect(evaluatedObject.frame, rect);
    }];

    self.previousAttributes = [[self.cachedAttributes.allValues filteredArrayUsingPredicate:predicate] arrayByAddingObjectsFromArray:
            [self.cachedSupplementaryViewsAttributes.allValues filteredArrayUsingPredicate:predicate]];
    self.previousRect = rect;
    
    return self.previousAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cachedAttributes[indexPath];
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                      self.contentMaxHeight + self.itemSpacing);
}

- (CGFloat)headerHeightForSection:(NSUInteger)section {
    CGSize size = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        size = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
    }
    return size.height;
}

- (CGFloat)footerHeightForSection:(NSUInteger)section {
    CGSize size = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        size = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section];
    }
    return size.height;
}

- (void)cacheAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath withOffest:(CGFloat)offestY {
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    CGFloat height = [kind isEqualToString:UICollectionElementKindSectionHeader] ? [self headerHeightForSection:indexPath.section] : [self footerHeightForSection:indexPath.section];
    CGRect frame = CGRectMake(0, offestY, CGRectGetWidth(self.collectionView.bounds), height);
    attributes.frame = frame;
    self.cachedSupplementaryViewsAttributes[indexPath] = attributes;
}

@end
