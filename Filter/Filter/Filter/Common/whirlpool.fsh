precision highp float;

varying vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;
 
const float uD = 80.0;

const float uR = 0.5;

void main()
{
    float Radius = uR;
    vec2 xy = textureCoordinate;
    
    vec2 dxy = xy - vec2(0.5, 0.5);
    
    float r = length(dxy);
    
    float beta = atan(dxy.y, dxy.x) + radians(uD) * 2.0 * (1.0 - (r / Radius) * (r / Radius));
    
    if (r <= Radius) {
        xy = 0.5 + r * vec2(cos(beta), sin(beta));
    }

    vec3 irgb = texture2D(inputImageTexture, xy).rgb;
    gl_FragColor = vec4(irgb, 1.0);
}
