shader_type spatial;
render_mode depth_test_disabled, unshaded;
uniform float scale;
uniform float fogExp;
uniform float fresnelExp;
uniform vec3 seaColour : source_color;
uniform sampler2D normalTex : hint_normal;
uniform sampler2D reflectTex : source_color;
uniform sampler2D screenTex : hint_screen_texture;
uniform sampler2D depthTex : hint_depth_texture;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 scaledUV = SCREEN_UV * scale + ( (1. - scale) * 0.5);
	// calculate distance to surface plane
	vec3 dir = normalize(-(INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(scaledUV * 2.0 - 1.0, 0.0, 1.0)).xyz);
	float d = -(CAMERA_POSITION_WORLD.y) / dir.y;
	// convert to depth
	vec3 surfacePos = (CAMERA_POSITION_WORLD + dir * d);
	vec4 clipPos =  PROJECTION_MATRIX * VIEW_MATRIX * vec4(surfacePos,1);
	float surfaceDepth = (clipPos.z / clipPos.w);
	// get depth to compare
	float sceneDepth = texture(depthTex,scaledUV).x;
	vec4 worldPos = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(scaledUV * 2.0 - 1.0, sceneDepth, 1.0);
	float worldDepth = length(CAMERA_POSITION_WORLD - worldPos.xyz/worldPos.w);
	// uv needs to be flipped because camera is upside down
	vec2 reflectUV = vec2(1. - scaledUV.x, scaledUV.y);
	//calculate how UV is shifted by rough surface
	vec2 surfaceUV = (0.1) * vec2(surfacePos.x,surfacePos.z);
	vec3 normal = textureGrad(normalTex,surfaceUV,dFdx(surfaceUV),dFdy(surfaceUV)).rbg;	
	normal = normalize(normal - 0.5);
	vec2 offset = normal.xz * (1. - scale);
	reflectUV += offset;
	
	vec3 reflectedWorld = texture(reflectTex,reflectUV).rgb ;
	vec3 world = texture(screenTex,scaledUV).rgb;
	float fresnel = pow((1. - abs(dir.y)),fresnelExp);
	float fog = exp(- (worldDepth - d) * fogExp);
	vec3 fadedWorld = mix(seaColour,world, fog);
	// mix for transparency
	vec3 sea = mix(fadedWorld,reflectedWorld,fresnel);
	ALBEDO = (sceneDepth > surfaceDepth) ? world : sea;
}


//void light() {
	//if(LIGHT_IS_DIRECTIONAL && isReflected) {
		//DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR;
	//}
//}

