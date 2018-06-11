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

@property (nonatomic, strong) NSArray<NSString *> *imageURLArray;

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
    
    // 七牛图片
    NSArray *imgs = @[
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-1.gif",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-2.gif",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-3.gif",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-4.gif",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-5.gif",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-6.jpg",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-7.jpg",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-8.jpg",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-9.jpg",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-10.jpg",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-11.jpg",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-12.gif",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-13.gif",
                      @"http://p5tpnlvr1.bkt.clouddn.com/JGPhotoBrowser-14.gif",
                      ];
    //NSMutableArray *tmp = @[].mutableCopy;
    //for (NSInteger i = 0; i < 2; i++) {
    //    [tmp addObjectsFromArray:imgs];
    //}
    _imageURLArray = imgs.copy;
}

- (void)dealloc {
    
    JGSCLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Image List";
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    [self.collectionView registerClass:[DemoCollectionViewCell class] forCellWithReuseIdentifier:JGSCReuseIdentifier(DemoCollectionViewCell)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _imageURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DemoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JGSCReuseIdentifier(DemoCollectionViewCell) forIndexPath:indexPath];
    
    // 七牛图片自定义裁剪压缩
    NSString *imageURL = _imageURLArray[indexPath.row];
    imageURL = [imageURL stringByAppendingString:@"?imageView1/1/w/100/h/100"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSMutableArray<JGPBPhoto *> *photoArray = [NSMutableArray array];
    [_imageURLArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        JGPBPhoto *photo = [[JGPBPhoto alloc] init];
        photo.url = [NSURL URLWithString:obj];
        photo.placeholder = photoArray.count > 0 ? photoArray[0].placeholder : nil;
        photo.srcImageView = ((DemoCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]]).imageView;
        photo.extraText = [NSString stringWithFormat:@"%zd、这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；", idx + 1];
        [photoArray addObject:photo];
    }];
    
    JGPBBrowserController *photoBrowser = [[JGPBBrowserController alloc] initWithPhotos:photoArray.copy index:indexPath.row];
    [photoBrowser show];
}

#pragma mark - End

@end
