//
//  BlurView.m
//  Blur
//
//  Created by 李文龙 on 15/6/26.
//  Copyright (c) 2015年 李文龙. All rights reserved.
//

#import "BlurView.h"
#import "UIView+ITTAdditions.h"
#import "UIImage+ImageEffects.h"

#define BlurHeight          400 //毛玻璃的高度

@interface BlurView()
{
    UIButton * _bgBtn;
}
@property (nonatomic,assign) BOOL wasUnderZero;
@property (nonatomic,assign) CGFloat lastPoint;
@property (nonatomic,strong) UIImageView * bluredBackground;
@end

@implementation BlurView

#pragma mark - Public Method

+(void)showBlurViewFromSupView:(UIView *)supView
{
    BlurView * blurView = [BlurView loadFromXib];
    blurView.height = BlurHeight;
    [blurView showBlurViewFromSupView:supView complete:^{
        
    }];
}

#pragma mark - Private Method
- (void)initDatas
{
    
}

- (void)initViews
{
    self.clipsToBounds = YES;
    self.bluredBackground = [[UIImageView alloc]init];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollRecognizerView:)];
    panRecognizer.maximumNumberOfTouches = 1;
    panRecognizer.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:panRecognizer];
}


+ (id)loadViewFromXibNamed:(NSString*)xibName withFileOwner:(id)fileOwner
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:xibName owner:fileOwner options:nil];
    if (array && [array count]) {
        return array[0];
    }else {
        return nil;
    }
}

+ (id)loadViewFromXibNamed:(NSString*)xibName
{
    return [BlurView loadViewFromXibNamed:xibName withFileOwner:self];
}

+ (id)loadFromXib
{
    return [BlurView loadViewFromXibNamed:NSStringFromClass([self class])];
}

- (void)dismissView
{
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.top = - self.height;
        self.bluredBackground.top = self.height;
        _bgBtn.alpha = 0.0f;
    } completion:^(BOOL isfinsh){
        [_bgBtn removeFromSuperview];
        _bgBtn = nil;
        [self removeFromSuperview];
    }];
}

-(void)showBlurViewFromSupView:(UIView *)supView complete:(void (^)())completionHandler
{
    self.top = - self.height;
    self.bluredBackground.top = self.height;
    UIImage *image = [supView screenshotMH];
    self.bluredBackground.image = [image applyExtraLightEffect];
    self.bluredBackground.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self insertSubview:_bluredBackground atIndex:0];
    if (!_bgBtn) {
        _bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgBtn.frame = supView.bounds;
        _bgBtn.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7f];
        _bgBtn.alpha = 0.0f;
        [_bgBtn addTarget:self action:@selector(bgBtnClick:) forControlEvents:UIControlEventTouchDown];
    }
    [supView addSubview:_bgBtn];
    [supView addSubview:self];
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.75
          initialSpringVelocity:4
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         weakself.top = 0;
                         weakself.bluredBackground.top = 0;
                         _bgBtn.alpha = 1.0f;
                     }
                     completion:^(BOOL isfinsh){
                        if (completionHandler) {
                             completionHandler();
                         }
                     }];
}

#pragma mark - UIButton Event
- (void)bgBtnClick:(id)sender
{
    [self dismissView];
}

#pragma mark - Lifecycle Method
-(void)awakeFromNib
{
    [self initDatas];
    [self initViews];
}

- (void)dealloc
{
    NSLog(@"%@ dealloc",[self class]);
}

#pragma mark -  UIPanGestureRecognizer
- (void)scrollRecognizerView:(UIPanGestureRecognizer *)recognizer{
    [self changeFrameWithRecognizer:recognizer];
}

-(void)changeFrameWithRecognizer:(UIPanGestureRecognizer*)recognizer{
    
    CGPoint translatedPoint = [recognizer translationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.wasUnderZero =NO;
        self.lastPoint = [recognizer translationInView:self].y;
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (self.origin.y<=0 || !self.wasUnderZero) {
            self.bluredBackground.frame = CGRectMake(0, -(translatedPoint.y-self.lastPoint), self.bluredBackground.frame.size.width, self.bluredBackground.frame.size.height);
            self.frame = CGRectMake(0, translatedPoint.y-self.lastPoint, self.frame.size.width, self.frame.size.height);
            self.wasUnderZero =YES;
            if (self.frame.origin.y >= 0) {
                self.bluredBackground.frame = CGRectMake(0, 0, self.bluredBackground.frame.size.width, self.bluredBackground.frame.size.height);
                self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            }
            //根据滑动来改变灰色背景的透明度
            _bgBtn.alpha = (BlurHeight+self.origin.y)/BlurHeight;
        }
    }else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.4 animations:^{
            if (self.frame.origin.y > -self.frame.size.height/3) {
                self.bluredBackground.frame = CGRectMake(0, 0, self.bluredBackground.frame.size.width, self.bluredBackground.frame.size.height);
                self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                _bgBtn.alpha = 1.0;
            }else{
                self.bluredBackground.frame = CGRectMake(0, self.frame.size.height, self.bluredBackground.frame.size.width, self.bluredBackground.frame.size.height);
                self.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
                _bgBtn.alpha = 0.0f;
            }
        } completion:^(BOOL finished) {
            if (self.frame.origin.y == -self.frame.size.height) {
                [_bgBtn removeFromSuperview];
                [self removeFromSuperview];
                self.bluredBackground.image = nil;
            }
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
