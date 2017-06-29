//
//  CollectionViewController.m
//  JGPhotoBrowser
//
//  Created by 梅继高 on 2017/6/29.
//  Copyright © 2017年 Jigao Mei. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "JGPhotoBrowser.h"

static NSString * const reuseIdentifier = @"Cell";

@interface CollectionViewController ()

@property (nonatomic, strong) NSArray *imageURLArray;

@end

@implementation CollectionViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _imageURLArray = @[@"http://test.api.yypapa.com/img?id=17923&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17921&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17920&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17919&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17915&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17913&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17914&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17912&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17911&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17910&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17909&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17908&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17907&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17906&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17905&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17904&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17902&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17901&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17898&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17897&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17896&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17895&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17894&size=100x100",
                           @"http://test.api.yypapa.com/img?id=17892&size=100x100"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_imageURLArray[indexPath.row]]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = 0;
    NSMutableArray *photoArray = [NSMutableArray array];
    JGPhotoBrowser *photoBrowser = [[JGPhotoBrowser alloc] init];
    for (NSString *imageURL in _imageURLArray) {
        JGPhoto *photo = ({
            JGPhoto *photo = [[JGPhoto alloc] init];
            photo.url = [NSURL URLWithString:[imageURL substringToIndex:[imageURL rangeOfString:@"&"].location]];
            photo.srcImageView = ((CollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]]).imageView;
            photo;
        });
        row++;
        [photoArray addObject:photo];
    }
    photoBrowser.photos = photoArray;
    photoBrowser.currentPhotoIndex = indexPath.row;
    [photoBrowser show];
}

@end
