   interior      MatrixW                                                                             	   MatrixPVW                                                                                SAMPLER    +         LIGHTMAP_WORLD_EXTENTS                                interior.vs�  uniform mat4 MatrixW;
uniform mat4 MatrixPVW;

attribute vec3 POSITION;
attribute vec2 TEXCOORD0;

varying vec2 PS_TEXCOORD;
varying vec3 PS_POS;

void main(void){   
   vec4 world_pos = MatrixW * vec4( POSITION.xyz, 1.0 );
   PS_POS.xyz = world_pos.xyz;
   
   PS_TEXCOORD = (vec3(TEXCOORD0.xy, 0.0)).xy;

   // Set vertex position
   gl_Position = MatrixPVW * ( vec4( POSITION.xyz , 1.0 ));
}    interior.ps  #extension GL_OES_standard_derivatives : enable
#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D SAMPLER[4];
varying vec2 PS_TEXCOORD;
varying vec3 PS_POS;

uniform vec4 LIGHTMAP_WORLD_EXTENTS;

#define LIGHTMAP_TEXTURE SAMPLER[3]

#ifndef LIGHTMAP_TEXTURE
	#error If you use lighting, you must #define the sampler that the lightmap belongs to
#endif

vec3 CalculateLightingContribution()
{
	vec2 uv = ( PS_POS.xz - LIGHTMAP_WORLD_EXTENTS.xy ) * LIGHTMAP_WORLD_EXTENTS.zw;

	return texture2D( LIGHTMAP_TEXTURE, uv.xy ).rgb;
}

vec3 CalculateLightingContribution( vec3 normal )
{
	return vec3( 1, 1, 1 );
}

float mip_map_level(vec2 texcoords) {
	// The OpenGL Graphics System: A Specification 4.2
    //  - chapter 3.9.11, equation 3.21
    vec2 dx_vtc = dFdx(texcoords);
    vec2 dy_vtc = dFdy(texcoords);
    float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));

    return 0.5 * log2(delta_max_sqr);
}

void main() {
    // gl_FragColor = texture2D(SAMPLER[0], PS_TEXCOORD);

	vec2 TEXCOORD_wrapped = fract(-PS_TEXCOORD);
	float BIAS = mip_map_level(PS_TEXCOORD) - mip_map_level(TEXCOORD_wrapped);
	
	gl_FragColor = texture2D(SAMPLER[0], TEXCOORD_wrapped, BIAS);
	gl_FragColor.rgb *= CalculateLightingContribution();
}                    