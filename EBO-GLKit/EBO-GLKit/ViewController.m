//
//  ViewController.m
//  EBO-GLKit
//
//  Created by Zsy on 2020/8/2.
//  Copyright © 2020 Zsy. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *mContext;

@property (nonatomic, strong) GLKBaseEffect *mEffect;

@property (nonatomic , assign) int mCount;

@property (nonatomic , assign) float mDegree;

@end

@implementation ViewController
{
    dispatch_source_t timer;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupContext];
    [self setupVertexData];
}

- (void)setupContext {
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.mContext) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    if (![EAGLContext setCurrentContext:self.mContext]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
}

- (void)setupVertexData {
    //    正方形，如果使用索引会造成，纹理坐标映射出现重复问题
    //    GLfloat vertexArr[] = {
    //        -0.5f, 0.5f, 0.5f,      0.0f, 0.0f, 0.5f,       0.0f, 1.0f,//左上
    //        0.5f, 0.5f, 0.5f,       0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
    //        -0.5f, -0.5f, 0.5f,     0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
    //        0.5f, -0.5f, 0.5f,      0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
    //
    //        -0.5f, 0.5f, -0.5f,     0.0f, 0.0f, 0.5f,       0.0f, 1.0f,//左上
    //        0.5f, 0.5f,  -0.5f,     0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
    //        -0.5f, -0.5f, -0.5f,    0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
    //        0.5f, -0.5f, -0.5f,     0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
    //    };
    //
    //    GLuint indices[] = {
    //        0, 2, 3,
    //        0, 3, 1,
    //
    //        0, 6, 2,
    //        0, 4, 6,
    //
    //        0, 1, 5,
    //        0, 5, 4,
    //
    //        1, 3, 7,
    //        1, 7, 5,
    //
    //        6, 2, 7,
    //        2, 7, 3,
    //
    //        4, 6, 7,
    //        6, 7, 5,
    //    };
    
    // 顶点数据，前三个是顶点坐标， 中间三个是顶点颜色，    最后两个是纹理坐标
    GLfloat vertexArr[] =
    {
        -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
        0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    };
    //顶点索引
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    self.mCount = sizeof(indices) / sizeof(GLuint);
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArr), vertexArr, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // 顶点坐标
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 8, (GLfloat *)NULL);
    
    // 顶点颜色
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 8, (GLfloat *)NULL + 3);
    
    // 纹理坐标
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 8, (GLfloat *)NULL + 6);
    
    // 加载纹理
    [self setupTexture];
    
    // 设置投影
    CGSize size  = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1f, 10.0f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);
    self.mEffect.transform.projectionMatrix = projectionMatrix;
    
    // 模型视图
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
    
    // 定时器
    double delayInSeconds = 0.1;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{
        self.mDegree += 0.1;
        
    });
    dispatch_resume(timer);
}

- (void)setupTexture {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"wlop" ofType:@"jpg"];
    
    GLKTextureInfo *textureInfo =
    [GLKTextureLoader textureWithContentsOfFile:filePath
                                        options:@{GLKTextureLoaderOriginBottomLeft: @true}
                                          error:nil];
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name    = textureInfo.name;
}

#pragma mark - GLKViewControllerDelegate
- (void)update {
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    
    
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, self.mDegree, 1.0, 1.0, 1.0);
    
    //        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.mDegree);
    //        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.mDegree);
    //        modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.mDegree);
    
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    
    [self.mEffect prepareToDraw];
    
    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);
}

@end
