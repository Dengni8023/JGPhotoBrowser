//
//  JGSPhotoToolView.m
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSPhotoToolView.h"
#import "JGSourceBase.h"

@interface JGSPhotoToolView ()

@property (nonatomic, assign) BOOL imgSaved; // 是否已保存图片
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) JGSPhotoToolClose *closeBtn;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *saveImageBtn;

@end

@implementation JGSPhotoToolView

#pragma mark - Life Cycle
- (instancetype)initWithPhotosCount:(NSInteger)count index:(NSInteger)curIndex {
    
    self = [super init];
    if (self) {
        
        self.totalCount = count;
        self.currentIndex = curIndex;
        [self setupViewElements];
    }
    return self;
}

- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - View
- (void)setupViewElements {
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.28];
    
    // bg
    _contentView = [[UIView alloc] init];
    [self addSubview:_contentView];
    
    // 关闭
    _closeBtn = [JGSPhotoToolClose buttonWithType:UIButtonTypeCustom];
    [_closeBtn addTarget:self action:@selector(closeShow:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_closeBtn];
    _closeBtn.hidden = YES;
    
    // 页码
    _indexLabel = [[UILabel alloc] init];
    _indexLabel.backgroundColor = [UIColor clearColor];
    _indexLabel.font = [UIFont systemFontOfSize:18];
    _indexLabel.textColor = [UIColor whiteColor];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_indexLabel];
    _indexLabel.hidden = self.totalCount <= 1;
    
    // 保存图片按钮
    _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveImageBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_saveImageBtn setTitleColor:_indexLabel.textColor forState:UIControlStateNormal];
    [_saveImageBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_saveImageBtn addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_saveImageBtn];
    _saveImageBtn.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat viewW = CGRectGetWidth(self.frame) - self.contentInset.left - self.contentInset.right;
    CGFloat viewH = CGRectGetHeight(self.frame) - self.contentInset.top - self.contentInset.bottom;
    CGRect viewRect = CGRectMake(self.contentInset.left, self.contentInset.top, viewW, viewH);
    self.contentView.frame = viewRect;
    
    // btn
    [self.saveImageBtn sizeToFit];
    CGRect btnFrame = self.saveImageBtn.frame;
    btnFrame.size.width = CGRectGetWidth(btnFrame) + 8 * 2;
    btnFrame.size.height = CGRectGetHeight(btnFrame) + 4 * 2;
    btnFrame.origin.x = viewW - 20 - CGRectGetWidth(btnFrame);
    btnFrame.origin.y = (viewH - CGRectGetHeight(btnFrame)) * 0.5;
    self.saveImageBtn.frame = btnFrame;
    
    // index
    [self.indexLabel sizeToFit];
    CGRect indexFrame = self.indexLabel.frame;
    CGFloat btnMinX = CGRectGetMinX(btnFrame);
    indexFrame.size.width = MIN(CGRectGetWidth(self.indexLabel.frame), btnMinX - (CGRectGetWidth(viewRect) - btnMinX));
    indexFrame.origin.x = (viewW - CGRectGetWidth(indexFrame)) * 0.5;
    indexFrame.origin.y = (viewH - CGRectGetHeight(indexFrame)) * 0.5;
    self.indexLabel.frame = indexFrame;
    
    // clsoe
    self.closeBtn.frame = CGRectMake(20, (viewH - CGRectGetHeight(btnFrame)) * 0.5, CGRectGetHeight(btnFrame), CGRectGetHeight(btnFrame));
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self setNeedsLayout];
}

#pragma mark - Index
- (void)changeCurrentIndex:(NSInteger)toIndex indexSaved:(BOOL)saved {
    
    // 更新页码
    self.currentIndex = toIndex;
    self.indexLabel.text = [NSString stringWithFormat:@"%@/%@", @(self.currentIndex + 1), @(self.totalCount)];
    
    // 按钮
    self.imgSaved = saved;
    self.saveImageBtn.hidden = (!self.showSaveBtn || !self.saveShowPhotoAction || self.imgSaved);
    [self setNeedsLayout];
}

- (void)setCloseShowAction:(void (^)(void))closeShowAction {
    _closeShowAction = closeShowAction;
    self.closeBtn.hidden = !self.closeShowAction;
}

- (void)setSaveShowPhotoAction:(void (^)(NSInteger))saveShowPhotoAction {
    _saveShowPhotoAction = saveShowPhotoAction;
    self.saveImageBtn.hidden = (!self.showSaveBtn || !self.saveShowPhotoAction || self.imgSaved);
}

- (void)setShowSaveBtn:(BOOL)showSaveBtn {
    _showSaveBtn = showSaveBtn;
    self.saveImageBtn.hidden = (!self.showSaveBtn || !self.saveShowPhotoAction || self.imgSaved);
}

#pragma mark - Action
- (void)closeShow:(JGSPhotoToolClose *)sender {
    if (self.closeShowAction) {
        self.closeShowAction();
    }
}

- (void)saveImage:(UIButton *)sender {
    if (self.saveShowPhotoAction) {
        self.saveShowPhotoAction(self.currentIndex);
    }
}

#pragma mark - End

@end

@implementation JGSPhotoToolClose

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat centerX = CGRectGetWidth(self.frame) * 0.5, circleY = CGRectGetHeight(self.frame) * 0.5, strokeWidth = 1.5;
    CGFloat radius = CGRectGetWidth(self.frame) * 0.5, closeDis = radius * 0.5 * sin(M_PI_4);
    CGFloat closeMinX = centerX - closeDis, closeMaxX = centerX + closeDis;
    CGFloat closeMinY = circleY - closeDis, closeMaxY = circleY + closeDis;
    
    // 绘制参数
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, strokeWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetShouldAntialias(ctx, true);
    
    // 绘制圆，半径处理，否则边界被切
    //CGContextAddArc(ctx, centerX, circleY, radius - strokeWidth * 0.5, 0, M_PI * 2, true);
    
    // 绘制圆中心叉
    CGContextMoveToPoint(ctx, closeMinX, closeMinY);
    CGContextAddLineToPoint(ctx, closeMaxX, closeMaxY);
    CGContextMoveToPoint(ctx, closeMinX, closeMaxY);
    CGContextAddLineToPoint(ctx, closeMaxX, closeMinY);
    
    CGContextStrokePath(ctx);
}

#pragma mark - End

@end
