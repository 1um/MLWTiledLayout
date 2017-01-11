//
//  MLWTiledLayout.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLWTiledLayoutDelegate;

//

@interface MLWTiledLayout : UICollectionViewLayout

@property (weak, nonatomic) id<MLWTiledLayoutDelegate> delegate;

/**
 Space between items and edges
 */
@property (assign, nonatomic) CGFloat itemSpacing;

@end

//

@protocol MLWTiledLayoutDelegate <NSObject>

/**
 Number of tiled columns in layout
 */
- (NSUInteger)numberOfColumnsInTiledLayout:(MLWTiledLayout *)layout;

/**
 Relative size of cell for given indexPath
 Sum of widths of all cells in row should equals `numberOfColumnsInTiledLayout:` to prevent empty spaces 
 */
- (CGSize)tiledLayout:(MLWTiledLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
