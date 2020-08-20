precision highp float;

varying vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;

const float mosaicSize = 0.02;
const float PI6 = 0.523599;

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
    
    vec4 mid = texture2D(inputImageTexture, textureCoordinate);
    float a = atan(y- vn.y, x - vn.x);

    vec2 area1 = vec2(vn.x, vn.y - mosaicSize * TR / 2.0);
    vec2 area2 = vec2(vn.x + mosaicSize / 2.0, vn.y - mosaicSize * TR / 2.0);
    vec2 area3 = vec2(vn.x + mosaicSize / 2.0, vn.y + mosaicSize * TR / 2.0);
    vec2 area4 = vec2(vn.x, vn.y + mosaicSize * TR / 2.0);
    vec2 area5 = vec2(vn.x - mosaicSize / 2.0, vn.y + mosaicSize * TR / 2.0);
    vec2 area6 = vec2(vn.x - mosaicSize / 2.0, vn.y - mosaicSize * TR / 2.0);

    if (a >= PI6 * 2.0 && a < PI6 * 4.0) {
        vn = area1;
    } else if (a >= 0.0 && a < PI6 * 2.0) {
        vn = area2;
    } else if (a>= -PI6 * 2.0 && a < 0.0) {
        vn = area3;
    } else if (a >= -PI6 * 4.0 && a < -PI6 * 2.0) {
        vn = area4;
    } else if(a >= -PI6 * 6.0&& a < -PI6 * 4.0) {
        vn = area5;
    } else if (a >= PI6 * 4.0 && a < PI6 * 6.0) {
        vn = area6;
    }
    vec4 color = texture2D(inputImageTexture, vn);
    gl_FragColor = color;
}
