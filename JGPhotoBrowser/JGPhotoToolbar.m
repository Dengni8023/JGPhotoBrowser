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
    
    // 显示页码
    UILabel *_indexLabel;
    UIButton *_saveImageBtn;
}

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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 保存相片到相机胶卷
        JGPhoto *photo = _photos[_currentPhotoIndex];
        
        UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error) {
        
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
    }
    else {
        
        JGPhoto *photo = _photos[_currentPhotoIndex];
        photo.save = YES;
        _saveImageBtn.enabled = NO;
        [SVProgressHUD showSuccessWithStatus:@"成功保存到相册"];
    }
}

#pragma mark - End

@end
