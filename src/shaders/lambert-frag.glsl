uniform vec4 u_Color;
uniform float u_Time;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec3 fs_Pos;

out vec4 out_Col;

void main()
{
    float noise = (perlin(fs_Pos * 4.5 + u_Time * 0.25) + 1.0) / 2.0;
    if(step(0.5f, noise) == 0.0) {
        discard;
    }
    vec4 diffuseColor = vec4(u_Color.rgb * noise, 1.0);
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    float ambientTerm = 0.2;
    float lightIntensity = diffuseTerm + ambientTerm;
    out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
