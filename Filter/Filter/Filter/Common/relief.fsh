precision highp float;

varying vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;

const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);//灰度权重
const vec2 TexSize = vec2(500.0, 500.0);//纹理大小
const vec4 bkColor = vec4(0.5, 0.5, 0.5, 1.0); //背景色

void main()
{
    vec2 tex = textureCoordinate;
    
    vec2 upLeftUV = vec2(tex.x-1.0/TexSize.x, tex.y-1.0/TexSize.y);
    
    vec4 curColor = texture2D(inputImageTexture, textureCoordinate);
    
    vec4 upLeftColor = texture2D(inputImageTexture, upLeftUV);
    
    vec4 delColor = curColor - upLeftColor;
    
    float luminance = dot(delColor.rgb, W);
    
    gl_FragColor = vec4(vec3(luminance), 0.0) + bkColor;
}
