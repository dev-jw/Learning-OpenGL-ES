//
//  ShaderView.m
//  EBO-GLSL
//
//  Created by Zsy on 2020/8/2.
//  Copyright © 2020 Zsy. All rights reserved.
//

#import "ShaderView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLESMath.h"
#import "GLESUtils.h"

@interface ShaderView ()

@property (nonatomic, strong) EAGLContext *mContext;

@property (nonatomic, strong) CAEAGLLayer *mEAEGLLayer;

@property (nonatomic, assign) GLuint mRenderBuffer;
@property (nonatomic, assign) GLuint mFrameBuffer;

@property (nonatomic, assign) GLuint mProgram;
@property (nonatomic, assign) GLuint mVertices;

@end

@implementation ShaderView
{
    float Xdegree;
    float Ydegree;
    float Zdegree;

    BOOL bX;
    BOOL bY;
    BOOL bZ;
    NSTimer* myTimer;
}

- (IBAction)onX:(id)sender {
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onRes:) userInfo:nil repeats:YES];
    }
    bX = !bX;
}

- (IBAction)onY:(id)sender {
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onRes:) userInfo:nil repeats:YES];
    }
    bY = !bY;
}

- (IBAction)onZ:(id)sender {
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onRes:) userInfo:nil repeats:YES];
    }
    bZ = !bZ;
}

- (void)onRes:(id)sender {
    Xdegree += bX * 5;
    Ydegree += bY * 5;
    Zdegree += bZ * 5;
    [self render];
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupLayer];
    [self setupContext];
    [self deleteRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self render];
}

- (void)render {
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    CGFloat scale = UIScreen.mainScreen.scale;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale,
               self.frame.size.width * scale, self.frame.size.height * scale);
    
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    self.mProgram = [self loadShaders:vertFile frag:fragFile];
    
    [self linkProgram:self.mProgram];
    
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
    
    GLuint mCount = sizeof(indices) / sizeof(indices[0]);
    
    // 设置顶点缓冲
    if (self.mVertices == 0) {
        glGenBuffers(1, &_mVertices);
    }
    glBindBuffer(GL_ARRAY_BUFFER, _mVertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArr), vertexArr, GL_DYNAMIC_DRAW);
    
    // 设置 position
    GLuint position = glGetAttribLocation(self.mProgram, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 8, (GLfloat*)NULL);
    
    // 设置 positionColor
    GLuint positionColor = glGetAttribLocation(self.mProgram, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 8, (GLfloat*)NULL + 3);
    
    // 设置 projectionMatrix
    GLuint projectionMatrixSlot = glGetUniformLocation(self.mProgram, "projectionMatrix");
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    float aspect = width / height;
    
    ksPerspective(&_projectionMatrix, 30.0, aspect, 5.0f, 20.0f);
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);
    
    // 设置 modelViewMatrix
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.mProgram, "modelViewMatrix");
    
    KSMatrix4 _modelViewMatrix;
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -8.0);

    KSMatrix4 _rotationMatrix;
    ksMatrixLoadIdentity(&_rotationMatrix);
    ksRotate(&_rotationMatrix, Xdegree, 1.0, 0.0, 0.0);
    ksRotate(&_rotationMatrix, Ydegree, 0.0, 1.0, 0.0);
    ksRotate(&_rotationMatrix, Zdegree, 0.0, 0.0, 1.0);
    
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
    
    // 设置 textCoord;
    GLuint textCoord = glGetAttribLocation(self.mProgram, "textCoord");
    glEnableVertexAttribArray(textCoord);
    glVertexAttribPointer(textCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 8, (GLfloat *)NULL + 6);
    
    [self loadTexture:@"wlop.jpg"];
    glUniform1i(glGetUniformLocation(self.mProgram, "colorMap"), 0);

    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
//    并不需要开启混合，因为是单个图层
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glDrawElements(GL_TRIANGLES, mCount, GL_UNSIGNED_INT, indices);
    
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)loadTexture:(NSString *)imageName {
    CGImageRef imageRef = [UIImage imageNamed:imageName].CGImage;
    if (!imageRef) {
        NSLog(@"Failed to load image");
        exit(1);
    }
    
    size_t width  = CGImageGetWidth(imageRef);
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
    
//    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    
    // 图片翻转
    CGContextTranslateCTM(contextRef, width, height);
    CGContextRotateCTM(contextRef, -M_PI);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    
    // 释放上下文
    CGContextRelease(contextRef);
    
    // 读取纹理
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, bitmapData);
    glBindBuffer(GL_TEXTURE_2D, 0);
    
    free(bitmapData);
    return 0;
}

#pragma mark - 编译、链接Shader
- (void)linkProgram:(GLuint)program {
    glLinkProgram(program);
    
    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(program, sizeof(message), 0, &message[0]);
        NSString *messageInfo = [NSString stringWithUTF8String:message];
        NSLog(@"link error: %@", messageInfo);
        exit(1);
    }else {
        glUseProgram(program);
    }
}

- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag {
    GLuint vertShader, fragShader;
    GLuint program = glCreateProgram();
    
    // 验证
//    if (![self validate:program]) {
//        NSLog(@"Failed to validate program: %d", program);
//        glDeleteProgram(program);
//        self.mProgram = 0;
//        exit(1);
//    }else {
        [self compileShader:&vertShader type:GL_VERTEX_SHADER file:vert];
        [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
        
        glAttachShader(program, vertShader);
        glAttachShader(program, fragShader);
        
        glDeleteShader(vertShader);
        glDeleteShader(fragShader);
        return program;
//    }
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    NSString *filePath = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[filePath UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}

- (BOOL)validate:(GLuint)programId {
    GLint logLength, status;
    
    glValidateProgram(programId);
    glGetProgramiv(programId, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(programId, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(programId, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - 初始化配置
- (void)setupLayer {
    self.mEAEGLLayer = (CAEAGLLayer *)self.layer;
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    self.mEAEGLLayer.opaque = true;
    self.mEAEGLLayer.drawableProperties = @{
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,
        kEAGLDrawablePropertyRetainedBacking: @(false)
    };
}

- (void)setupContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    self.mContext = context;
}

- (void)deleteRenderAndFrameBuffer {
    glDeleteFramebuffers(1, &_mFrameBuffer);
    self.mFrameBuffer = 0;
    
    glDeleteRenderbuffers(1, &_mRenderBuffer);
    self.mRenderBuffer = 0;
}

- (void)setupRenderBuffer {
    GLuint buffer;
    glGenBuffers(1, &buffer);
    self.mRenderBuffer = buffer;
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.mRenderBuffer);
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mEAEGLLayer];
}

- (void)setupFrameBuffer {
    GLuint buffer;
    glGenBuffers(1, &buffer);
    self.mFrameBuffer = buffer;
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.mFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, self.mRenderBuffer);
}

@end
