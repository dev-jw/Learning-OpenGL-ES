#ifdef GL_ES 
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

uniform sampler2D colorMap;

varying lowp vec2 varyTextCoord;

varying lowp vec4 varyColor;

void main()
{
    vec4 weakMask = texture2D(colorMap, varyTextCoord);
    vec4 mask = varyColor;
    float alpha = 0.3;
    
    vec4 tempColor = weakMask * (1.0 - alpha) + mask * alpha;
    gl_FragColor = tempColor;
}
