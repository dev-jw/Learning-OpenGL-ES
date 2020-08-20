//
//  ViewController.m
//  GLKit
//
//  Created by Zsy on 2020/7/25.
//  Copyright © 2020 Zsy. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *mContext;
@property (nonatomic, strong) GLKBaseEffect *mEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self setupVertexData];
    [self setupTexture];
}

- (void)setupContext {
    // 新建OPenGL ES上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // 将 Storyboard 中的 view 改为 GLKitView
    GLKView *view = (GLKView*)self.view;
    view.context = self.mContext;
    
    // 设置颜色格式
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    // 将mContext设置为当前上下文
    [EAGLContext setCurrentContext:self.mContext];
}

#pragma mark - 设置顶点数据
- (void)setupVertexData {
    // 顶点数据
    // 顶点数据（x, y, z） + 纹理坐标（s, t）
    GLfloat squareVertexData[] = {
        0.5, -0.5, 0.0f,      1.0, 0.0f,
        0.5, 0.5, 0.0f,       1.0, 1.0f,
        -0.5, 0.5, 0.0f,      0.0, 1.0f,
        
        0.5, -0.5, 0.0f,       1.0, 0.0f,
        -0.5, 0.5, 0.0f,      0.0, 1.0f,
        -0.5, -0.5, 0.0f,     0.0, 0.0f,
    };
    
    // 顶点数据缓存
    GLuint buffer;
    // 创建顶点缓存区标识符
    glGenBuffers(1, &buffer);
    // 绑定顶点缓存区
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    // 将顶点数据 copy 到顶点缓存区
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    // 顶点坐标数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL + 0);
    
    // 纹理坐标数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLfloat *)NULL + 3);
}

#pragma mark - 加载纹理
- (void)setupTexture {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Farewell" ofType: @"jpg"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];

    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name    = textureInfo.name;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 清除颜色缓冲
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 将背景色设置为红色 RGBA
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    
    [self.mEffect prepareToDraw];

    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
