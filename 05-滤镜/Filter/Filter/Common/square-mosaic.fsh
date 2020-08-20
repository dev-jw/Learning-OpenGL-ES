precision highp float;

varying vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;
 
const vec2 mosaicSizeRatio = vec2(0.05, 0.05);

void main()
{
    vec2 totalXY = vec2(floor(1.0 / mosaicSizeRatio.x), floor(1.0 / mosaicSizeRatio.y));
    
    vec2 eachXY  = vec2(floor(textureCoordinate.x / mosaicSizeRatio.x), floor(textureCoordinate.y / mosaicSizeRatio.y));
    
    vec2 UVMosaic = vec2(eachXY.x / totalXY.x , eachXY.y / totalXY.y);
    
    
    gl_FragColor = texture2D(inputImageTexture, UVMosaic);
}
