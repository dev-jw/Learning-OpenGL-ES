//
//  ViewController.m
//  Image-Stretch
//
//  Created by neotv on 2020/8/19.
//  Copyright © 2020 neotv. All rights reserved.
//

#import "ViewController.h"
#import "StretchView.h"
#import <Photos/Photos.h>

@interface ViewController ()<StretchViewDelegate>
@property (strong, nonatomic) IBOutlet StretchView *stretchView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineSpace;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *topBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UIView *topLine;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIView *mask;

@property (nonatomic, assign) CGFloat currentTop;  // 上方横线距离纹理顶部的高度
@property (nonatomic, assign) CGFloat currentBottom;    // 下方横线距离纹理顶部的高度

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupButtons];
    
    self.stretchView.stretchDelegate = self;
    [self.stretchView updateImage:[UIImage imageNamed:@"girl.jpg"]];
    [self setupStretchArea];
}

- (void)viewDidAppear:(BOOL)animated {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupStretchArea]; // 这里的计算要用到view的size，所以等待AutoLayout把尺寸计算出来后再调用
    });
}

#pragma mark - Private

- (void)setupButtons {
    self.topBtn.layer.borderWidth = 1;
    self.topBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.topBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(actionPanTop:)]];
    
    self.bottomBtn.layer.borderWidth = 1;
    self.bottomBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.bottomBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(actionPanBottom:)]];
}

// 设置初始的拉伸区域位置
- (void)setupStretchArea {
    self.currentTop = 0.25f;
    self.currentBottom = 0.75f;
    CGFloat textureOriginHeight = 0.7f; // 初始纹理占 View 的比例
    self.topLineSpace.constant = ((self.currentTop * textureOriginHeight) + (1 - textureOriginHeight) / 2) * self.stretchView.bounds.size.height;
    self.bottomLineSpace.constant = ((self.currentBottom * textureOriginHeight) + (1 - textureOriginHeight) / 2) * self.stretchView.bounds.size.height;
}

- (CGFloat)stretchAreaYWithLineSpace:(CGFloat)lineSpace {
    return (lineSpace / self.stretchView.bounds.size.height - self.stretchView.textureTopY) / self.stretchView.textureHeight;
}

#pragma mark - Action

- (void)actionPanTop:(UIPanGestureRecognizer *)pan {
    if ([self.stretchView hasChange]) {
        [self.stretchView updateTexture];
        self.slider.value = 0.5f; // 重置滑杆位置
    }
    
    CGPoint translation = [pan translationInView:self.view];
    self.topLineSpace.constant = MIN(self.topLineSpace.constant + translation.y,
                                     self.bottomLineSpace.constant);
    CGFloat textureTop = self.stretchView.bounds.size.height * self.stretchView.textureTopY;
    self.topLineSpace.constant = MAX(self.topLineSpace.constant, textureTop);
    [pan setTranslation:CGPointZero inView:self.view];
    
    self.currentTop = [self stretchAreaYWithLineSpace:self.topLineSpace.constant];
    self.currentBottom = [self stretchAreaYWithLineSpace:self.bottomLineSpace.constant];
}

- (void)actionPanBottom:(UIPanGestureRecognizer *)pan {
    if ([self.stretchView hasChange]) {
        [self.stretchView updateTexture];
        self.slider.value = 0.5f; // 重置滑杆位置
    }
    
    CGPoint translation = [pan translationInView:self.view];
    self.bottomLineSpace.constant = MAX(self.bottomLineSpace.constant + translation.y,
                                        self.topLineSpace.constant);
    CGFloat textureBottom = self.stretchView.bounds.size.height * self.stretchView.textureBottomY;
    self.bottomLineSpace.constant = MIN(self.bottomLineSpace.constant, textureBottom);
    [pan setTranslation:CGPointZero inView:self.view];
    
    self.currentTop = [self stretchAreaYWithLineSpace:self.topLineSpace.constant];
    self.currentBottom = [self stretchAreaYWithLineSpace:self.bottomLineSpace.constant];
}

#pragma mark - IBAction
- (void)setViewsHidden:(BOOL)hidden {
    self.topLine.hidden = hidden;
    self.bottomLine.hidden = hidden;
    self.topBtn.hidden = hidden;
    self.bottomBtn.hidden = hidden;
    self.mask.hidden = hidden;
}

- (IBAction)sliderValueDidChanged:(UISlider *)sender {
    CGFloat newHeight = (self.currentBottom - self.currentTop) * ((sender.value) + 0.5);
    [self.stretchView stretchingFromStartY:self.currentTop
                                    toEndY:self.currentBottom
                             withNewHeight:newHeight];
}

- (IBAction)sliderDidTouchDown:(UISlider *)sender {
    [self setViewsHidden:YES];
}

- (IBAction)sliderDidTouchup:(UISlider *)sender {
    [self setViewsHidden:NO];
    
}

- (IBAction)saveAction:(id)sender {
    UIImage *image = [self.stretchView createResult];
    [self saveImage:image];
}


// 保存图片到相册
- (void)saveImage:(UIImage *)image {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
    }];
}


#pragma mark - StretchViewDelegate
- (void)viewStretchAreaDidChanged:(StretchView *)stretchView {
    CGFloat topY = self.stretchView.bounds.size.height * self.stretchView.stretchAreaTopY;
    CGFloat bottomY = self.stretchView.bounds.size.height * self.stretchView.stretchAreaBottomY;
    self.topLineSpace.constant = topY;
    self.bottomLineSpace.constant = bottomY;
}

@end
