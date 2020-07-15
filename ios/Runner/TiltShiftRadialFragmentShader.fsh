varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform highp float angle;

uniform lowp float excludeCircleRadius;
uniform lowp vec2 excludeCirclePoint;
uniform lowp float excludeBlurSize;
uniform highp float aspectRatio;

void main()
{
    lowp vec4 sharpImageColor = texture2D(inputImageTexture,
                                          textureCoordinate);
    lowp vec4 blurredImageColor = texture2D(inputImageTexture2,
                                            textureCoordinate2);
    
    lowp vec4 red = vec4(1.0,0.0,0.0,1.0);
    
    highp float
    distanceFromCenter = distance(excludeCirclePoint,
                                  textureCoordinate);
    
    gl_FragColor = mix(sharpImageColor,
//                       blurredImageColor,
                       red,
                       smoothstep(excludeCircleRadius - excludeBlurSize,
                                  excludeCircleRadius,
                                  distanceFromCenter));
}
