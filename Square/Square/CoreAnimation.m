//
//  CoreAnimation.m
//  Square
//
//  Created by neotv on 2020/7/27.
//  Copyright © 2020 Zsy. All rights reserved.
//

#import "CoreAnimation.h"

@interface CoreAnimation ()
@property (nonatomic, strong) UIView *container;
@end

@implementation CoreAnimation
{
    dispatch_source_t timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.container = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.container];
    
    [self setupTransform];
}

- (void)setupTransform {
    CATransform3D transform = CATransform3DIdentity;
    
    transform = CATransform3DMakeTranslation(0, 0, 100);
    [self addCubeWithCATransform3D:transform];
    
    transform = CATransform3DMakeTranslation(100, 0, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    [self addCubeWithCATransform3D:transform];
    
    transform = CATransform3DMakeTranslation(0, -100, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
    [self addCubeWithCATransform3D:transform];
    
    transform = CATransform3DMakeTranslation(0, 100, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 1, 0, 0);
    [self addCubeWithCATransform3D:transform];
    
    transform = CATransform3DMakeTranslation(-100, 0, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
    [self addCubeWithCATransform3D:transform];
    
    transform = CATransform3DMakeTranslation(0, 0, -100);
    transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
    [self addCubeWithCATransform3D:transform];
    
    
    static CGFloat angle = 1.0f;
    double delayInSeconds = 0.1;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{
        CATransform3D transform3d = self.container.layer.sublayerTransform;
        transform3d = CATransform3DRotate(transform3d, angle/180.0f*M_PI, 1.0f, 1.0f, 1.0f);
        self.container.layer.sublayerTransform = transform3d;
        
    });
    dispatch_resume(timer);
    
//    NSTimer *timer = [NSTimer timerWithTimeInterval:0.01 repeats:true block:^(NSTimer * _Nonnull timer) {
//
//        CATransform3D transform3d = self.container.layer.sublayerTransform;
//        transform3d = CATransform3DRotate(transform3d, angle/180.0f*M_PI, 1.0f, 1.0f, 1.0f);
//        self.container.layer.sublayerTransform = transform3d;
//    }];
//
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)addCubeWithCATransform3D:(CATransform3D)transform {
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"cover" ofType:@"jpg"];
    UIImageView *face = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    face.image = [UIImage imageWithContentsOfFile:filePath];
    [self.container addSubview:face];
    
    CGSize containerSize = self.container.bounds.size;
    face.center = CGPointMake(containerSize.width / 2.0, containerSize.height / 2.0);
    
    face.layer.transform = transform;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
