//
//  JGPhotoToolbar.m
//  JGPhotoBrowserExample
//
//  Created by 梅继高 on 2017/6/29.
//  Copyright © 2017年 Jigao Mei. All rights reserved.
//

#import "JGPhotoToolbar.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Photos/Photos.h>

@interface JGPhotoToolbar() {
    
}

@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *saveImageBtn;

@end

@implementation JGPhotoToolbar

#pragma mark - init & dealloc
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // 页码
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.frame = self.bounds;
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
        _indexLabel.hidden = YES;
        
        // 保存图片按钮
        CGFloat btnWidth = frame.size.height;
        _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveImageBtn.frame = CGRectMake(20, 0, btnWidth, btnWidth);
        _saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        // 动态framework打包bundle在framework内
        // 动态framework打包bundle在taraget内
        NSBundle *parentBundle = [NSBundle bundleForClass:[self class]];
        NSString *resBundlePath = [parentBundle pathForResource:@"JGPhotoBrowser" ofType:@"bundle"];
        if (resBundlePath) {
            
            NSBundle *imageBundle = [NSBundle bundleWithPath:resBundlePath];
            
            [_saveImageBtn setImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"save_icon" ofType:@"png"]] forState:UIControlStateNormal];
            [_saveImageBtn setImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"save_icon_highlighted" ofType:@"png"]] forState:UIControlStateHighlighted];
        }
        
        [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_saveImageBtn];
        _saveImageBtn.hidden = YES;
    }
    
    return self;
}

- (void)dealloc {
    
    //NSLog(@"%s %zd :", __PRETTY_FUNCTION__, __LINE__);
}

#pragma mark - Photos
- (void)setPhotos:(NSArray *)photos {
    
    _photos = photos;
    _indexLabel.hidden = _photos.count <= 1;
    
    // 保存图片按钮
    CGFloat btnWidth = self.bounds.size.height;
    _saveImageBtn.frame = CGRectMake(20, 0, btnWidth, btnWidth);
    _saveImageBtn.hidden = !_showSaveBtn;
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex {
    
    // 更新页码
    _currentPhotoIndex = currentPhotoIndex;
    _indexLabel.text = [NSString stringWithFormat:@"%d / %d", (int)_currentPhotoIndex + 1, (int)_photos.count];
    
    // 按钮
    _saveImageBtn.hidden = !_showSaveBtn;
    JGPhoto *photo = _photos[_currentPhotoIndex];
    _saveImageBtn.enabled = photo.image != nil && !photo.save;
}

- (void)setShowSaveBtn:(NSUInteger)showSaveBtn {
    
    // 按钮
    _showSaveBtn = showSaveBtn;
    _saveImageBtn.hidden = !_showSaveBtn;
}

#pragma mark - Save
- (void)saveImage {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 保存相片到相册
        __strong typeof(weakSelf) strongSelf = weakSelf;
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        if (authorizationStatus == PHAuthorizationStatusAuthorized) {
            
            [strongSelf saveShowingImageToPhotoLibrary];
        }
        else if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                if (status == PHAuthorizationStatusAuthorized) {
                    
                    [strongSelf saveShowingImageToPhotoLibrary];
                }
                else {
                    
                    [SVProgressHUD showWithStatus:@"请在隐私设置界面，授权访问相册"];
                }
            }];
        }
        else {
            
            [SVProgressHUD showWithStatus:@"请在隐私设置界面，授权访问相册"];
        }
    });
}

- (void)saveShowingImageToPhotoLibrary {
    
    __weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        JGPhoto *showPhoto = [strongSelf.photos objectAtIndex:strongSelf.currentPhotoIndex];
        NSData *saveData = showPhoto.GIFImage.data ?: UIImageJPEGRepresentation(showPhoto.image, 1.f);
        if ([PHAssetCreationRequest class]) {
            
            PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
            [request addResourceWithType:PHAssetResourceTypePhoto data:saveData options:nil];
        }
        else {
            
            NSString *temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
            NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:temporaryFileName];
            NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
            NSError *error = nil;
            [saveData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
            
            [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:temporaryFileURL];
            [[NSFileManager defaultManager] removeItemAtURL:temporaryFileURL error:nil];
        }
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            BOOL saved = success && !error ? YES : NO;
            JGPhoto *showPhoto = [strongSelf.photos objectAtIndex:strongSelf.currentPhotoIndex];
            showPhoto.save = saved ? YES : NO;
            strongSelf.saveImageBtn.enabled = !saved;
            
            [SVProgressHUD showSuccessWithStatus:saved ? @"成功保存到相册" : @"保存失败"];
        });
    }];
}

#pragma mark - End

@end
