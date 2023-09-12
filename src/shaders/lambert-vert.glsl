#version 300 es



uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;

in vec4 vs_Pos;
in vec4 vs_Nor;

uniform vec4 u_Color;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Col;
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1);

uniform float u_Time;

void main()
{
    fs_Col = u_Color;

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);

    vec4 newPos = vs_Pos;

   
    newPos.x += cos(u_Time / 100.0 + newPos.y);
    newPos.y *= mix(0.1, 0.8, (tan(u_Time / 100.0) + 1.0) / 2.0);
    newPos.z += 2.0 * (sin(newPos.y) + sin(newPos.x));

    float displacementNormal = sin(newPos.x * 2.f) + cos(newPos.y * 2.f) + sin(newPos.z * 2.f);
    newPos.xyz += vec3(sin(newPos.z * 7.f), cos(newPos.x * 7.f), sin(newPos.y * 7.f)) * 0.3;

    newPos = mix(vs_Pos, newPos, smoothstep(0.5f, 1.f, abs(u_Time / 31415.f - 1.0)) * 0.5);

    vec4 modelPosition = u_Model * newPos;
    fs_LightVec = lightPos - modelPosition;
    fs_Pos = modelPosition;
    gl_Position = u_ViewProj * modelPosition;
}