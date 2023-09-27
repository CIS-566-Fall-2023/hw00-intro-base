#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform int u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Col;
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1);

void main() {
    // Calculate the time-dependent transformation
    float timeFactor = sin(float(u_Time) * 0.1);
    mat4 timeTransform = mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
    timeTransform[0][0] = 1.0 + timeFactor;
    timeTransform[1][1] = 1.0 + timeFactor;
    timeTransform[2][2] = 1.0 + timeFactor;

    // Apply transformations to vertex position
    vec4 transformedPos = u_ViewProj * u_Model * timeTransform * vs_Pos;

    // Pass normal, color, and position to the fragment shader
    fs_Nor = normalize(u_ModelInvTr * vs_Nor);
    fs_LightVec = lightPos - transformedPos;
    fs_Col = vs_Col;
    fs_Pos = transformedPos;

    // Output the transformed vertex position
    gl_Position = transformedPos;
}
