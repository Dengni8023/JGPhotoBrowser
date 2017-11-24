//
//  JGPhotoBrowserDemo.m
//  JGPhotoBrowserDemo
//
//  Created by Mei Jigao on 2017/11/24.
//  Copyright © 2017年 MeiJigao. All rights reserved.
//

#import "JGPhotoBrowserDemo.h"
#import "JGPhotoBrowserDemoCell.h"
#import "JGSourceBase.h"
#import "JGPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "FLAnimatedImage.h"

@interface JGPhotoBrowserDemo () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray<NSString *> *imageURLArray;

@end

@implementation JGPhotoBrowserDemo

#pragma mark - init
- (instancetype)init {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    return [self initWithCollectionViewLayout:layout];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *imgs = @[
                      @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1154115116,2827667481&fm=27&gp=0.jpg",
                      @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=123345699,3215794002&fm=27&gp=0.jpg",
                      @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=597870703,240090382&fm=27&gp=0.jpg",
                      
                      @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=4117781570,3707026475&fm=27&gp=0.jpg",
                      @"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1896668044,1740962079&fm=27&gp=0.jpg",
                      @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2282657293,62822783&fm=27&gp=0.jpg",
                      
                      @"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=346999072,684292960&fm=27&gp=0.jpg",
                      @"http://pic22.nipic.com/20120624/9833023_080802356198_2.gif?id=0",
                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1511333318401&di=c62ddcec2f83a1bb0a838f6487247f87&imgtype=0&src=http%3A%2F%2Fs9.rr.itc.cn%2Fr%2FwapChange%2F20167_23_19%2Fa4lvey5829124575362.GIF",
                      ];
    NSMutableArray *tmp = @[].mutableCopy;
    for (NSInteger i = 0; i < 2; i++) {
        [tmp addObjectsFromArray:imgs];
    }
    _imageURLArray = tmp.copy;
    
    JGEnableLogWithMode(JGLogModeFile);
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[JGPhotoBrowserDemoCell class] forCellWithReuseIdentifier:JGReuseIdentifier(JGPhotoBrowserDemoCell)];
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
    
    JGPhotoBrowserDemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JGReuseIdentifier(JGPhotoBrowserDemoCell) forIndexPath:indexPath];
    
    NSString *imageURL = _imageURLArray[indexPath.row];
    imageURL = [imageURL stringByAppendingString:@"&size=100x100"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSMutableArray *photoArray = [NSMutableArray array];
    [_imageURLArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        JGPhoto *photo = [[JGPhoto alloc] init];
        photo.url = [NSURL URLWithString:obj];
        photo.srcImageView = ((JGPhotoBrowserDemoCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]]).imageView;
        photo.extraText = [NSString stringWithFormat:@"%zd、%@\n这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；这里是图片介绍一二三四五；", idx + 1, obj];
        [photoArray addObject:photo];
    }];
    
    JGPhotoBrowser *photoBrowser = [[JGPhotoBrowser alloc] initWithPhotos:photoArray.copy index:indexPath.row];
    [photoBrowser show];
}

#pragma mark - End

@end
