//
//  DemoCollectionViewController.m
//  JGPhotoBrowserDemo
//
//  Created by Mei Jigao on 2018/3/19.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "DemoCollectionViewController.h"
#import <JGSourceBase/JGSourceBase.h>
#import "DemoCollectionViewCell.h"
#import <JGPhotoBrowser/JGPhotoBrowser.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface DemoCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSArray<NSString *> *imageURLArray;

@end

@implementation DemoCollectionViewController

#pragma mark - init & dealloc
- (instancetype)init {
    return [self initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initDatas];
    }
    return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        [self initDatas];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initDatas];
    }
    return self;
}

- (void)initDatas {
    
    // 图片
    self.imageURLArray = @[
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-001.jpg",
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-002.jpg",
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-003.jpg",
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-004.jpg",
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-005.jpg",
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-006.gif",
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-007.gif",
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-008.gif",
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-009.gif",
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-010.gif",
                           @"http://dengni8023-github.oss-cn-shenzhen.aliyuncs.com/JGSPhotoBrowser-012.jpg",
                           ];
}

- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Image List";
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.clearsSelectionOnViewWillAppear = YES;
    
    [self.collectionView registerClass:[DemoCollectionViewCell class] forCellWithReuseIdentifier:JGSReuseIdentifier(DemoCollectionViewCell)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DemoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JGSReuseIdentifier(DemoCollectionViewCell) forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor grayColor];
    
    // 七牛图片自定义裁剪压缩
    NSString *imageURL = self.imageURLArray[indexPath.row];
    //imageURL = [imageURL stringByAppendingString:@"?imageView1/1/w/100/h/100"];
    imageURL = [imageURL stringByAppendingString:@"?x-oss-process=image/resize,m_fill,w_300,h_300"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.frame) / 4.f - 8.f;
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8.f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    DemoCollectionViewCell *cell = (DemoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *srcImg = cell.imageView.image;
    
    NSMutableArray<JGSPhoto *> *photoArray = [NSMutableArray array];
    [self.imageURLArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        JGSPhoto *photo = [[JGSPhoto alloc] init];
        photo.url = [NSURL URLWithString:obj];
        photo.placeholder = srcImg ?: (photoArray.count > 0 ? photoArray[0].placeholder : nil);
        photo.srcImageView = ((DemoCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]]).imageView;
        photo.imgDescription = (idx % 2) ? nil : [NSString stringWithFormat:@"%zd、这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；", idx + 1];
        [photoArray addObject:photo];
    }];
    
    JGSPhotoBrowserSetDescriptionHeight(120);
    JGSPhotoBrowser *photoBrowser = [[JGSPhotoBrowser alloc] initWithPhotos:photoArray index:indexPath.row];
    [photoBrowser show];
}

#pragma mark - End

@end
