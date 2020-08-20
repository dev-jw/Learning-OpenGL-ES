//
//  ViewController.m
//  Filter
//
//  Created by Zsy on 2020/8/7.
//  Copyright © 2020 Zsy. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import "FilterBar.h"

typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;

@interface ViewController ()

@property (nonatomic, strong) FilterBar *bar;

@property (nonatomic, assign) SenceVertex *vertices;

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLuint program;

@property (nonatomic, assign) GLuint textureID;

@property (nonatomic, assign) GLuint vertexBuffer;

@property (nonatomic, strong) NSArray *dataArr, *douyinArr, *commonArr;

// 用于刷新屏幕
@property (nonatomic, strong) CADisplayLink *displayLink;

// 开始的时间戳
@property (nonatomic, assign) NSTimeInterval startTimeInterval;

@property (nonatomic, assign) NSInteger section;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupFilterBar];
    [self setupContext];
    [self startFilerAnimation];
}

- (void)startFilerAnimation {
    //1.判断displayLink 是否为空
    //CADisplayLink 定时器
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    //2. 设置displayLink 的方法
    self.startTimeInterval = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    
    //3.将displayLink 添加到runloop 运行循环
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];
}

- (void)timeAction {
    //DisplayLink 的当前时间撮
    if (self.startTimeInterval == 0) {
        self.startTimeInterval = self.displayLink.timestamp;
    }
    
    glUseProgram(self.program);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    
    // 传入时间
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time = glGetUniformLocation(self.program, "Time");
    glUniform1f(time, currentTime);
    
    // 清除画布
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    
    // 重绘
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //渲染到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - Draw
- (void)draw {
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    
    glUseProgram(self.program);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - Shader
- (void)setupNoramlShader {
    self.section = 1;
    [self setupFragmentShader:@"split"];
    [self startFilterWithHorizontal:1.0 Vertical:1.0];
}

- (void)setupFragmentShader:(NSString *)fragShaderName {
    NSString *fragShaderPath = [[NSBundle mainBundle] pathForResource:fragShaderName ofType:@"fsh"];
    NSString *fragShaderString = [NSString stringWithContentsOfFile:fragShaderPath encoding:NSUTF8StringEncoding error:nil];
    
    GLuint program;
//    if (!self.program) {
        program = [self createProgramWithFragmentShader:fragShaderString];
//    }else {
//        program = self.program;
//    }
    
    glUseProgram(program);
    
    GLuint textureSlot = glGetUniformLocation(program, "inputImageTexture");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    glUniform1i(textureSlot, 0);
    
    GLuint positionSlot = glGetAttribLocation(program, "position");
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    GLuint textureCoordSlot = glGetAttribLocation(program, "inputTextureCoordinate");
    glEnableVertexAttribArray(textureCoordSlot);
    glVertexAttribPointer(textureCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    self.program = program;
}

- (void)startFilterWithHorizontal:(float)horizontal Vertical:(float)vertical {
    
    GLuint horizontalSlot = glGetUniformLocation(self.program, "horizontal");
    glUniform1f(horizontalSlot, horizontal);
    
    GLuint verticalSlot = glGetUniformLocation(self.program, "vertical");
    glUniform1f(verticalSlot, vertical);
}

- (GLuint)createProgramWithFragmentShader:(NSString *)fragShaderString {
    GLuint vertexShader, fragmentShader;
    
    NSString *verShaderPath = [[NSBundle mainBundle] pathForResource:@"normal" ofType:@"vsh"];
    NSString *verShaderString = [NSString stringWithContentsOfFile:verShaderPath encoding:NSUTF8StringEncoding error:nil];
    
    [self compileShader:&vertexShader type:GL_VERTEX_SHADER string:verShaderString];
    [self compileShader:&fragmentShader type:GL_FRAGMENT_SHADER string:fragShaderString];
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    return [self linkWithProgram:program] ? program : 0;
}

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
               string:(NSString *)shaderString
{
    GLint status;
    
    const GLchar *source;
    source = [shaderString UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status != GL_TRUE) {
        GLint logLength;
        glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(sizeof(logLength));
            glGetShaderInfoLog(*shader, logLength, &logLength, log);
            if (type == GL_VERTEX_SHADER) {
                NSLog(@"Failed to compile vertex shader: %@", [NSString stringWithFormat:@"%s", log]);
            }else {
                NSLog(@"Failed to compile fragment shader: %@", [NSString stringWithFormat:@"%s", log]);
            }
            free(log);
        }
    }
    return status == GL_TRUE;
}

- (BOOL)linkWithProgram:(GLuint)program {
    GLint status;
    
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"program link failed：%@", messageString);
        exit(1);
    }
    return  program;
}

#pragma mark - EAGLContext
- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (![EAGLContext setCurrentContext:self.context]) {
        NSLog(@"Failed to set EAGLContext");
        exit(1);
    }
    
    // 初始化顶点数据
    self.vertices = (SenceVertex *)malloc(sizeof(SenceVertex) * 4);
    self.vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}};
    self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}};
    self.vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}};
    self.vertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}};
    
    CAEAGLLayer *layer  = [[CAEAGLLayer alloc] init];
    layer.frame         = CGRectMake(0, 0, self.view.frame.size.width, CGRectGetMinY(self.bar.frame));
    layer.contentsScale = [UIScreen mainScreen].scale;
    [self.view.layer addSublayer:layer];
    
    [self bindRenderLayer:layer];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"wlop" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    self.textureID = [self loadTextureWithImage:image];
    
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SenceVertex) * 4, self.vertices, GL_STATIC_DRAW);
    
    [self setupNoramlShader];
    
    self.vertexBuffer = buffer;
}

- (GLuint)loadTextureWithImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        NSLog(@"Load Image Failed");
        exit(1);
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    unsigned long   bitmapByteCount;
    unsigned long   bitmapBytesPerRow;
    
    bitmapBytesPerRow = (width * 4);
    bitmapByteCount   = (bitmapBytesPerRow * height);
    
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    bitmapData = calloc(bitmapByteCount, sizeof(uint8_t));
    if (bitmapData == NULL) {
        fprintf(stderr, "Memory not allocted!");
        exit(1);
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(bitmapData, width, height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    if (contextRef == NULL) {
        free(bitmapData);
        NSLog(@"context not created!");
        exit(1);
    }
    
    //    CGContextTranslateCTM(contextRef, width, height);
    //    CGContextRotateCTM(contextRef, -M_PI);
    CGContextTranslateCTM(contextRef, 0, height);
    CGContextScaleCTM(contextRef, 1.0f, -1.0f);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(contextRef);
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, bitmapData);
    glBindBuffer(GL_TEXTURE_2D, 0);
    
    free(bitmapData);
    
    return textureID;
}

//绑定渲染缓存区和帧缓存区
- (void)bindRenderLayer:(CALayer<EAGLDrawable> *)layer {
    
    //1.渲染缓存区,帧缓存区对象
    GLuint renderBuffer;
    GLuint frameBuffer;
    
    //2.获取帧渲染缓存区名称,绑定渲染缓存区以及将渲染缓存区与layer建立连接
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    //3.获取帧缓存区名称,绑定帧缓存区以及将渲染缓存区附着到帧缓存区上
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              renderBuffer);
}

- (void)setupFilterBar {
    
    BOOL iPhoneXSeries = false;
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        iPhoneXSeries = true;
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat y = height - cellHeight - (iPhoneXSeries ? 34.0f : 0);
    FilterBar * bar = [[FilterBar alloc] initWithFrame:CGRectMake(0, y, width, cellHeight)];
    
    bar.dataSource = self.dataArr.mutableCopy;
    
    [self.view addSubview:bar];
    self.bar = bar;
    
    bar.selectedIndex = ^(NSInteger index) {
        if (index == 0) {
            [self setupFragmentShader:@"normal"];
        }else {
            if (self.section == 1) {
                NSString *filterName = self.dataArr[index];
                NSString *aspect = [filterName componentsSeparatedByString:@"分屏"].firstObject;
                NSArray *vec2 = [aspect componentsSeparatedByString:@":"];
                
                [self startFilterWithHorizontal:[vec2.firstObject floatValue] Vertical:[vec2.lastObject floatValue]];
            }else {
                [self setupFragmentShader:[self selectShaderNameWithIndex:index]];
            }
            [self draw];
        }
    };
    
    __weak __typeof(FilterBar *)weakBar= bar;
    
    bar.btnClicked = ^(NSInteger index) {
        switch (index) {
            case 1:
                weakBar.dataSource = self.dataArr.mutableCopy;
                [self setupFragmentShader:@"split"];
                self.section = 1;
                break;
            case 2:
                weakBar.dataSource = self.douyinArr.mutableCopy;
                [self setupFragmentShader:@"normal"];
                self.section = 2;
                break;
            case 3:
                weakBar.dataSource = self.commonArr.mutableCopy;
                [self setupFragmentShader:@"normal"];
                self.section = 3;
                break;
        }
    };
}

//获取渲染缓存区的宽
- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}

//获取渲染缓存区的高
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}

- (NSString *)selectShaderNameWithIndex:(NSInteger)index {
    
    if (self.section == 2) {
        NSArray * arr = @[
            @"soul",
            @"illusory",
            @"shake",
            @"glitch",
            @"flash",
        ];
        return arr[index - 1];
    }
    
    if (self.section == 3) {
        NSArray * arr = @[
            @"gray",
            @"whirlpool",
            @"relief",
            @"reverse",
            @"square-mosaic",
            @"hexagon-mosaic",
            @"triangle-mosaic"
        ];
        return arr[index - 1];
    }
    
    return  @"";
}

- (NSArray *)dataArr {
    if (_dataArr == nil) {
        _dataArr = @[
            @"无",
            @"1:2分屏",
            @"1:3分屏",
            @"2:2分屏",
            @"3:2分屏",
            @"3:3分屏",
            @"4:4分屏",
        ];
    }
    return _dataArr;
}

- (NSArray *)douyinArr {
    if (_douyinArr == nil) {
        _douyinArr = @[
            @"无",
            @"灵魂出窍",
            @"幻觉",
            @"晕眩",
            @"毛刺",
            @"闪白",
        ];
    }
    return _douyinArr;
}

- (NSArray *)commonArr {
    if (_commonArr == nil) {
        _commonArr = @[
            @"无",
            @"灰度",
            @"旋涡",
            @"浮雕",
            @"颠倒",
            @"马赛克-正方形",
            @"马赛克-六边形",
            @"马赛克-三角形",
        ];
    }
    return _commonArr;
}

@end
