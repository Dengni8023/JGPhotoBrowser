//
//  JGSPhotoStatusView.m
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSPhotoStatusView.h"
#import "JGSourceBase.h"

@interface JGSPhotoStatusView ()

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) JGSPhotoProgressView *progressView;

@end

@implementation JGSPhotoStatusView

#pragma mark - Life Cycle
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - View
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat borderWidth = 76.f / 320.f * MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGFloat maxWidth = MIN(CGRectGetWidth(self.frame) - 18 * 2, CGRectGetHeight(self.frame) - 18 * 2);
    
    // status
    [self.statusLabel sizeToFit];
    CGRect labelFrame = self.statusLabel.frame;
    labelFrame.size.width = MIN(maxWidth, MAX(borderWidth, CGRectGetWidth(labelFrame) + 18 * 2));
    labelFrame.size.height = MIN(maxWidth, MAX(borderWidth, CGRectGetHeight(labelFrame) + 18 * 2));
    if (CGRectGetWidth(labelFrame) / CGRectGetHeight(labelFrame) > 16 / 9.f) {
        labelFrame.size.height = CGRectGetWidth(labelFrame) / (16 / 9.f);
    }
    else if (CGRectGetHeight(labelFrame) / CGRectGetWidth(labelFrame) > 16 / 9.f) {
        labelFrame.size.width = CGRectGetHeight(labelFrame) / (16 / 9.f);
    }
    labelFrame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(labelFrame)) * 0.5;
    labelFrame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(labelFrame)) * 0.5;
    self.statusLabel.frame = labelFrame;
    
    // loading
    self.progressView.frame = CGRectMake((CGRectGetWidth(self.frame) - borderWidth) * 0.5, (CGRectGetHeight(self.frame) - borderWidth) * 0.5, borderWidth, borderWidth);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        self.frame = newSuperview.bounds;
        [self setNeedsLayout];
    }
}

#pragma mark - Show
- (void)showWithStatus:(JGSPhotoStatus)status {
    
    switch (status) {
        case JGSPhotoStatusLoading:
            [self setProgress:0];
            break;
            
        case JGSPhotoStatusLoadFail:
            [self showWithStatusString:@"网络不给力\n图片下载失败"];
            break;
            
        case JGSPhotoStatusSaveFail:
            [self showWithStatusString:@"保存失败"];
            break;
            
        case JGSPhotoStatusSaveSuccess:
            [self showWithStatusString:@"已成功保存到相册"];
            break;
            
        case JGSPhotoStatusPrivacy: {
            NSString *execute = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
            [self showWithStatusString:[NSString stringWithFormat:@"请在设置中开启\"%@\"的相册访问权限", execute]];
        }
            break;
            
        case JGSPhotoStatusNone:
            break;
    }
}

- (void)showWithStatusString:(NSString *)string {
    
    [self.progressView removeFromSuperview];
    if (!self.statusLabel) {
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.font = [UIFont boldSystemFontOfSize:16];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.numberOfLines = 0;
        _statusLabel.layer.cornerRadius = 4.f;
        _statusLabel.layer.masksToBounds = YES;
    }
    if (!self.statusLabel.superview && string.length > 0) {
        [self addSubview:self.statusLabel];
    }
    
    // 显示行距问题
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.2;
    style.alignment = NSTextAlignmentCenter;
    self.statusLabel.attributedText = [[NSAttributedString alloc] initWithString:string attributes:@{NSParagraphStyleAttributeName : style}];
    [self setNeedsLayout];
}

- (void)showLoadingWithProgress:(CGFloat)progress {
    
    [self.statusLabel removeFromSuperview];
    if (!self.progressView) {
        _progressView = [[JGSPhotoProgressView alloc] init];
    }
    if (!self.progressView.superview && progress < 1.0) {
        [self addSubview:self.progressView];
    }
    self.progressView.progress = MAX(JGSPhotoLoadMinProgress, progress);
    [self setNeedsLayout];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self showLoadingWithProgress:self.progress];
}

#pragma mark - End

@end

/** 角度转弧度 */
FOUNDATION_EXTERN CGFloat JGSProgressAngleToRadian(CGFloat angle) {
    return (M_PI / 180.0 * (angle));
}

@implementation JGSPhotoProgressView

#pragma mark - Life Cycle
- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.backgroundColor = self.trackTintColor;
        self.layer.cornerRadius = 4.f;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat pathWidth = 8;
    CGPoint centerPoint = CGPointMake(rect.size.height * 0.5, rect.size.width * 0.5);
    CGFloat radius = MIN(rect.size.height, rect.size.width) * 0.5 - pathWidth * 0.5;
    
    CGFloat radians = JGSProgressAngleToRadian((_progress * 359.9) - 90);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, pathWidth);
    
    // 绘制半透明圆轨迹
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGMutablePathRef trackPath = CGPathCreateMutable();
    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, JGSProgressAngleToRadian(270), JGSProgressAngleToRadian(-90), YES);
    CGContextAddPath(context, trackPath);
    CGContextSetStrokeColorWithColor(context, [self.trackTintColor colorWithAlphaComponent:0.6].CGColor);
    CGContextStrokePath(context);
    CGPathRelease(trackPath);
    
    // 绘制圆弧
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGMutablePathRef progressPath = CGPathCreateMutable();
    CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius, JGSProgressAngleToRadian(270), radians, NO);
    CGContextAddPath(context, progressPath);
    CGContextSetStrokeColorWithColor(context, self.progressTintColor.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(progressPath);
    
    // 绘制圆弧内透明扇形
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGFloat innerRadius = radius - pathWidth * 0.5;
    CGMutablePathRef clearPath = CGPathCreateMutable();
    CGPathMoveToPoint(clearPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(clearPath, NULL, centerPoint.x, centerPoint.y, innerRadius, JGSProgressAngleToRadian(270), radians, NO);
    CGPathCloseSubpath(clearPath);
    CGContextAddPath(context, clearPath);
    CGContextFillPath(context);
    CGPathRelease(clearPath);
}

#pragma mark - Property Methods
- (UIColor *)trackTintColor {
    return _trackTintColor ?: [UIColor colorWithWhite:0 alpha:0.7f];
}

- (UIColor *)progressTintColor {
    return _progressTintColor ?: [UIColor whiteColor];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

#pragma mark - End

@end
