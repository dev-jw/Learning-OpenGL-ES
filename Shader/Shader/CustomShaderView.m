//
//  CustomShaderView.m
//  Shader
//
//  Created by neotv on 2020/7/29.
//  Copyright © 2020 neotv. All rights reserved.
//

#import "CustomShaderView.h"
#import <OpenGLES/ES3/gl.h>

@interface CustomShaderView ()

@property (nonatomic, strong) EAGLContext *mContext;

@property (nonatomic, strong) CAEAGLLayer *mEAGLLayer;


@property (nonatomic , assign) GLuint myProgram;
@property (nonatomic , assign) GLuint myColorRenderBuffer;
@property (nonatomic , assign) GLuint myColorFrameBuffer;

@end

@implementation CustomShaderView

- (void)layoutSubviews {
    NSLog(@"self: %@", self);
    
    [self setupLayer];
    [self setupContext];
    [self deleteRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self draw];
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark - draw 绘制
- (void)draw {
    glClearColor(0.3, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 设置视口
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale,
               self.frame.size.width * scale, self.frame.size.height * scale);
    
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    
    self.myProgram = [self loadShaders:vertFile frag:fragFile];
    
    // 链接
    glLinkProgram(self.myProgram);
    GLint linkRes;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkRes);
    if (linkRes == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.myProgram, sizeof(message), 0, &message[0]);
        NSString *messageInfo = [NSString stringWithUTF8String:message];
        NSLog(@"link error: %@", messageInfo);
        return;
    }else {
        NSLog(@"link successed");
        glUseProgram(self.myProgram);
    }
    
    GLfloat attrArr[] =
    {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };
    
    // 申请顶点缓冲
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    // 开启顶点坐标
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(position);
    
    // 开启纹理
    GLuint textCoord = glGetAttribLocation(self.myProgram, "textCoord");
    glVertexAttribPointer(textCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL + 3);
    glEnableVertexAttribArray(textCoord);
    
    // 加载纹理
    [self loadTexture:@"hacker.jpg"];
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - 加载纹理
- (void)loadTexture:(NSString *)imageName {
    CGImageRef imageRef = [UIImage imageNamed:imageName].CGImage;
    if (!imageRef) {
        NSLog(@"Failed to load image");
        return;
    }
    
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
   CGColorSpaceRef  colorSpace;
   void *           bitmapData;
   unsigned long    bitmapByteCount;
   unsigned long    bitmapBytesPerRow;

   bitmapBytesPerRow   = (width * 4);// 1
   bitmapByteCount     = (bitmapBytesPerRow * height);

   colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);// 2
   bitmapData = calloc( bitmapByteCount, sizeof(uint8_t) );// 3
   if (bitmapData == NULL)
   {
       fprintf (stderr, "Memory not allocated!");
       return;
   }
    
    // 重画图片
    CGContextRef contextRef = CGBitmapContextCreate(bitmapData, width, height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    if (contextRef == NULL) {
        free(bitmapData);
        NSLog(@"Context not created!");
        return;
    }
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
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
}

#pragma mark - 设置 Frame Buffer
- (void)setupFrameBuffer {
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, self.myColorFrameBuffer);
}

#pragma mark - 设置 Render Buffer
- (void)setupRenderBuffer {
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer = buffer;
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    // 为 颜色缓冲区 分配存储空间
    [self.mContext renderbufferStorage:GL_RENDERBUFFER
                          fromDrawable:self.mEAGLLayer];
}

#pragma mark - 清理缓存
- (void)deleteRenderAndFrameBuffer {
    glDeleteRenderbuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
    
    glDeleteFramebuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
}

#pragma mark - OpenGL ES 上下文配置
- (void)setupContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    self.mContext = context;
}

#pragma mark - Layer 配置
- (void)setupLayer {
    
    self.mEAGLLayer = (CAEAGLLayer *)self.layer;
    
    self.mEAGLLayer.contentsScale = [UIScreen mainScreen].scale;
    
    self.mEAGLLayer.opaque = true;
    
    self.mEAGLLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking:@false,
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
    };
}

#pragma mark - 编译、链接、使用 shader
- (GLuint)loadShaders:(NSString *)vertex frag:(NSString *)frag {
    GLuint verShader, fragShader;
    GLuint program = glCreateProgram();
    
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vertex];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    NSString * filePath  = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[filePath UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}

@end
