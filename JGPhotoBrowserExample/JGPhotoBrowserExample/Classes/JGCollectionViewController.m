//
//  JGCollectionViewController.m
//  JGPhotoBrowserExample
//
//  Created by 梅继高 on 2017/6/29.
//  Copyright © 2017年 Jigao Mei. All rights reserved.
//

#import "JGCollectionViewController.h"
#import "JGCollectionViewCell.h"
#import <JGPhotoBrowser/JGPhotoBrowser.h>
#import <SDWebImage/FLAnimatedImageView+WebCache.h>

@interface JGCollectionViewController ()

@property (nonatomic, strong) NSArray<NSString *> *imageURLArray;

@end

@implementation JGCollectionViewController

static NSString * const reuseIdentifier = @"JGCollectionCell";

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _imageURLArray = @[@"http://test.api.yypapa.com/img?id=17923",
                           @"http://test.api.yypapa.com/img?id=17921",
                           @"http://test.api.yypapa.com/img?id=17920",
                           @"http://test.api.yypapa.com/img?id=17919",
                           @"http://test.api.yypapa.com/img?id=17915",
                           @"http://test.api.yypapa.com/img?id=17913",
                           @"http://test.api.yypapa.com/img?id=17914",
                           @"http://test.api.yypapa.com/img?id=17912",
                           @"http://test.api.yypapa.com/img?id=17911",
                           @"http://test.api.yypapa.com/img?id=17910",
                           @"http://test.api.yypapa.com/img?id=17909",
                           @"http://test.api.yypapa.com/img?id=17908",
                           @"http://test.api.yypapa.com/img?id=17907",
                           @"http://test.api.yypapa.com/img?id=17906",
                           @"http://test.api.yypapa.com/img?id=17905",
                           @"http://test.api.yypapa.com/img?id=17904",
                           @"http://test.api.yypapa.com/img?id=17902",
                           @"http://test.api.yypapa.com/img?id=17901",
                           @"http://test.api.yypapa.com/img?id=17898",
                           @"http://test.api.yypapa.com/img?id=17897",
                           @"http://test.api.yypapa.com/img?id=17896",
                           @"http://test.api.yypapa.com/img?id=17895",
                           @"http://test.api.yypapa.com/img?id=16256",
                           @"http://pic22.nipic.com/20120624/9833023_080802356198_2.gif?id=0",
                           @"http://test.api.yypapa.com/img?id=17894",
                           @"http://test.api.yypapa.com/img?id=17892",
                           ];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.collectionView registerClass:[JGCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _imageURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JGCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSString *imageURL = _imageURLArray[indexPath.row];
    imageURL = [imageURL stringByAppendingString:@"&size=100x100"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSInteger row = 0;
    NSMutableArray *photoArray = [NSMutableArray array];
    JGPhotoBrowser *photoBrowser = [[JGPhotoBrowser alloc] init];
    for (NSString *imageURL in _imageURLArray) {
        
        JGPhoto *photo = [[JGPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageURL];
        photo.srcImageView = ((JGCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]]).imageView;
        [photoArray addObject:photo];
        
        row++;
    }
    
    photoBrowser.photos = photoArray;
    photoBrowser.currentPhotoIndex = indexPath.row;
    [photoBrowser show];
}

@end
