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
@property (assign, nonatomic) NSInteger contentMaxHeight;

@end

@implementation MLWTiledLayout

- (void)prepareLayout {
    [super prepareLayout];

    NSParameterAssert(self.delegate);

    self.cachedAttributes = [NSMutableDictionary dictionary];

    NSInteger columnsCount = [self.delegate numberOfColumnsInTiledLayout:self];
    CGFloat columnWidth = (CGRectGetWidth(self.collectionView.bounds) - self.itemSpacing) / columnsCount;
    NSMutableArray<NSNumber *> *columnHeights = [NSMutableArray arrayWithCapacity:columnsCount];
    for (NSInteger column = 0; column < columnsCount; column++) {
        [columnHeights addObject:@0];
    }

    NSInteger sectionCount = self.collectionView.numberOfSections;
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemsCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemsCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGSize size = [self.delegate tiledLayout:self sizeForCellAtIndexPath:indexPath];

            NSInteger bestIndex = NSNotFound;
            NSInteger bestHeight = NSIntegerMax;
            NSInteger length = 0;
            NSInteger height = columnHeights.firstObject.integerValue;
            for (NSInteger index = 0; index < columnsCount; index++) {
                NSInteger columnHeight = columnHeights[index].integerValue;
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
                NSInteger height = columnHeights.firstObject.integerValue;
                for (NSInteger index = 0; index < columnsCount; index++) {
                    NSInteger columnHeight = columnHeights[index].integerValue;
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
            CGRect frame = CGRectMake(bestIndex * columnWidth, bestHeight * columnWidth,
                                      size.width * columnWidth, size.height * columnWidth);
            CGFloat halfSpacing = self.itemSpacing / 2.0;
            frame = CGRectInset(frame, halfSpacing, halfSpacing);
            frame = CGRectOffset(frame, halfSpacing, halfSpacing);
            attributes.frame = frame;
            self.cachedAttributes[indexPath] = attributes;
        }
    }

    self.contentMaxHeight = [[columnHeights valueForKeyPath:@"@max.integerValue"] integerValue] * columnWidth;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *_Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
        return CGRectIntersectsRect(evaluatedObject.frame, rect);
    }];
    return [self.cachedAttributes.allValues filteredArrayUsingPredicate:predicate];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cachedAttributes[indexPath];
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                      self.contentMaxHeight + self.itemSpacing);
}

@end
