precision highp float;

varying vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;

const highp vec3 ratio = vec3(0.2125, 0.7154, 0.0721);

void main()
{
    vec4 mask = texture2D(inputImageTexture, textureCoordinate);
    float luminance = dot(mask.rgb, ratio);
    gl_FragColor = vec4(vec3(luminance), 1.0);
}
