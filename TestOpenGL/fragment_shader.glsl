#version 440

struct Material
{
	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
	sampler2D diffuseTex;
	sampler2D specularTex;
};

in vec3 vs_position;
in vec3 vs_color;
in vec2 vs_texcoord;
in vec3 vs_normal;

out vec4 fs_color;

//Uniforms
uniform Material material;

uniform int activelights;

uniform vec3 lightPos[6];
uniform vec3 cameraPos;

//Functions
vec3 calculateAmbient(Material material)
{
	return material.ambient;
}

vec3 calculateDiffuse(Material material, vec3 vs_position, vec3 vs_normal, vec3 lightPosCur)
{
	vec3 posToLightDirVec = normalize(lightPosCur - vs_position);
	vec3 diffuseColor = vec3(1.0f, 1.0f, 1.0f);
	float diffuse = clamp(dot(posToLightDirVec, vs_normal), 0, 1);
	vec3 diffuseFinal = material.diffuse * diffuse;

	return diffuseFinal;
}

vec3 calculateSpecular(Material material, vec3 vs_position, vec3 vs_normal, vec3 lightPosCur, vec3 cameraPos)
{
	vec3 lightToPosDirVec = normalize(vs_position - lightPosCur);
	vec3 reflectDirVec = normalize(reflect(lightToPosDirVec, normalize(vs_normal)));
	vec3 posToViewDirVec = normalize(cameraPos - vs_position);
	float specularConstant = pow(max(dot(posToViewDirVec, reflectDirVec), 0), 50);
	vec3 specularFinal = material.specular * specularConstant * texture(material.specularTex, vs_texcoord).rgb;

	return specularFinal;
}

void main()
{
	//fs_color = vec4(vs_color, 1.f);
	//fs_color = texture(texture0, vs_texcoord) * texture(texture1, vs_texcoord) * vec4(vs_color, 1.f);

	//Ambient light
	vec3 ambientFinal = calculateAmbient(material);

	//Diffuse light
	vec3 diffuseFinal = vec3(0,0,0);
	vec3 specularFinal = vec3(0,0,0);

	for(int i = 0; i < activelights ; i++){
	diffuseFinal += calculateDiffuse(material, vs_position, vs_normal, lightPos[i]);
	
	//Specular light
	 specularFinal+=calculateSpecular(material, vs_position, vs_normal, lightPos[i], cameraPos);
}
	//Final light
	fs_color = 
	texture(material.diffuseTex, vs_texcoord) /* * vec4(vs_color, 1.f)*/ 
	* (vec4(ambientFinal, 1.0f) + vec4(diffuseFinal, 1.0f) + vec4(specularFinal, 1.0f));
}