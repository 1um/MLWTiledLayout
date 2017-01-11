//
//  MLWViewController.m
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

#import <MLWTiledLayout/MLWTiledLayout.h>

#import "MLWViewController.h"

static NSString *const kCellId = @"cell";

@interface MLWViewController () <UICollectionViewDataSource, MLWTiledLayoutDelegate>

@end

@implementation MLWViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MLWTiledLayout *layout = [[MLWTiledLayout alloc] init];
    layout.itemSpacing = 5.0;
    layout.delegate = self;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -2.0);
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellId];
    [self.view addSubview:collectionView];

    [collectionView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
    [collectionView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;
    [collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 40;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];

    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
    cell.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];

    cell.layer.cornerRadius = 5.0;
    cell.layer.masksToBounds = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.layer.shouldRasterize = YES;

    return cell;
}

#pragma mark - MLWTiledLayoutDelegate

- (NSUInteger)numberOfColumnsInTiledLayout:(MLWTiledLayout *)layout {
    return 6;
}

- (CGSize)tiledLayout:(MLWTiledLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 5 < 2) {
        return CGSizeMake(3.0, 3.0);
    }
    if (indexPath.item % 10 < 5) {
        if (indexPath.item % 5 == 2) {
            return CGSizeMake(4.0, 4.0);
        }
        else {
            return CGSizeMake(2.0, 2.0);
        }
    }
    else {
        if (indexPath.item % 5 == 3) {
            return CGSizeMake(4.0, 4.0);
        }
        else {
            return CGSizeMake(2.0, 2.0);
        }
    }
}

@end
