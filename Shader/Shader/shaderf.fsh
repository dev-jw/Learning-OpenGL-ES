#ifdef GL_ES 
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

varying lowp vec2 varyTextCoord;

uniform sampler2D colorMap;

void main(){
  gl_FragColor = texture2D(colorMap, varyTextCoord);
}
