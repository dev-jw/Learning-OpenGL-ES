precision highp float;

uniform sampler2D inputImageTexture;
varying vec2 textureCoordinate;

uniform float horizontal;
uniform float vertical;

void main (void) {
    
    float horizontalCount = max(horizontal, 1.0);
    float verticalCount = max(vertical, 1.0);
    float ratio = verticalCount / horizontalCount;
    
    vec2 originSize = vec2(1.0, 1.0);
    vec2 newSize = originSize;
    
    if (ratio > 1.0) {
        newSize.y = 1.0 / ratio;
    } else {  
        newSize.x = ratio;
    }
    
    vec2 offset = (originSize - newSize) / 2.0;
    vec2 position = offset + mod(textureCoordinate * min(horizontalCount, verticalCount), newSize);
    
    gl_FragColor = texture2D(inputImageTexture, position);
}
