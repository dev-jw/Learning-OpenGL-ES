precision highp float;

varying vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;
 
const float mosaicSize = 0.02;

void main()
{
    float length = mosaicSize;

    float TR = sqrt(3.0) / 2.0;

    float x = textureCoordinate.x;
    float y = textureCoordinate.y;

    int wx = int(x / 1.5 / length);
    int wy = int(y / TR / length);
    
    vec2 v1, v2, vn;
    if(wx / 2 * 2 == wx){
        if(wy / 2 * 2 == wy){
            v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy));
            v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy + 1));
        }else {
            v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy + 1));
            v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy));
        }
    }else {
        if(wy / 2 * 2 == wy){
            v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy + 1));
            v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy));
        }else {
            v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy));
            v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy + 1));
        }  
    }

    if(distance(v1, textureCoordinate) < distance(v2, textureCoordinate)){
        vn = v1;
    }else {
        vn = v2;
    }

    gl_FragColor = texture2D(inputImageTexture, vn);
}
