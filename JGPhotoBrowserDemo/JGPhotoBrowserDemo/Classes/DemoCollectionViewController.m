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
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-001.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-002.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-003.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-004.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-005.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-006.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-007.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-008.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-009.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-010.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-011.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-012.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-013.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-014.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-015.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-016.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-017.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-018.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-019.jpg",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-020.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-021.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-022.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-023.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-024.gif",
                           @"http://github-source.dengni8023.com/JGPhotoBrowser-025.jpg",
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    //[self.view setNeedsLayout];
    [self.collectionView reloadData];
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
    cell.contentView.backgroundColor = JGSColorHex(0xF4F4F4);
    
    // 七牛图片自定义裁剪压缩
    NSString *imageURL = self.imageURLArray[indexPath.row];
    imageURL = [imageURL stringByAppendingString:@"?imageView1/1/w/100/h/100"];
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
        photo.imgDescription = (idx % 2) ? nil : [NSString stringWithFormat:@"%@、这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；", @(idx + 1)];
        [photoArray addObject:photo];
    }];
    
    JGSPhotoBrowserSetDescriptionHeight(120);
    JGSPhotoBrowser *photoBrowser = [[JGSPhotoBrowser alloc] initWithPhotos:photoArray index:indexPath.row];
    [photoBrowser show];
}

#pragma mark - End

@end
