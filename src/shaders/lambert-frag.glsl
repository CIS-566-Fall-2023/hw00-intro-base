uniform vec4 u_Color;
uniform float u_Time;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec3 fs_Pos;

out vec4 out_Col;

void main()
{
    float noise = (fbm(fs_Pos * 4.5 + u_Time * 0.25) + 1.0) / 2.0;
    if (step(0.5f, noise) == 0.0) {
        discard;
    }

    // simple blinn phong
    vec3 L = normalize(fs_LightVec.xyz);
    vec3 V = normalize(-fs_Pos);
    vec3 N = normalize(fs_Nor.xyz);
    vec3 H = normalize(L + V);

    const float shinness = 5.0;
    const float kd = 0.8;
    const float ks = 0.2;

    float diffuse = max(dot(N, L), 0.0);
    float specular = pow(max(dot(N, H), 0.0), shinness);

    float ao = 1.0 - noise;

    vec3 diffuseColor = u_Color.rgb * kd * diffuse;
    vec3 ambientColor = vec3(0.2) * ao;
    vec3 finalColor = ambientColor + diffuseColor + specular;

    out_Col = vec4(finalColor, u_Color.a);
}
