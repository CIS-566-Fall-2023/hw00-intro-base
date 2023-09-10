#version 300 es

precision highp float;

uniform mat4 u_Model; 
uniform mat4 u_ViewProj;  
uniform mat4 u_ModelInvTr;
uniform float u_Time;
in vec4 vs_Pos;    
in vec4 vs_Nor;     

out vec4 fs_Pos;
/* 
const vec2 positions[6] = vec2[](
            vec2(-1.0, -1.0),
            vec2(1.0, -1.0), 
            vec2(-1.0, 1.0), 
            vec2(-1.0, 1.0), 
            vec2(1.0, -1.0), 
            vec2(1.0, 1.0)
        ); */

void main()
{
    float frequency = 1.0;
    float amplitude = 0.2;
    vec4 pos = vs_Pos;
    pos.x += amplitude * cos(frequency * pos.x + u_Time * 0.02);
    pos.y += amplitude * sin(frequency * pos.y + u_Time * 0.02);
    pos.z += amplitude * sin(cos(frequency * pos.z + u_Time * 0.02) + 3.98676 );

    fs_Pos =  u_Model * pos;

    gl_Position = u_ViewProj * fs_Pos;
}