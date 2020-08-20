//
//  ShaderHelper.h
//  Image-Stretch
//
//  Created by neotv on 2020/8/19.
//  Copyright © 2020 neotv. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShaderHelper : NSObject

/**
 将一个顶点着色器和一个片段着色器挂载到一个着色器程序上，并返回程序的 id

 @param shaderName 着色器名称，顶点着色器应该命名为 shaderName.vsh ，片段着色器应该命名为 shaderName.fsh
 @return 着色器程序的 ID
 */
+ (GLuint)programWithShaderName:(NSString *)shaderName;
@end

NS_ASSUME_NONNULL_END
