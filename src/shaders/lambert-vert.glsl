#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself
uniform float u_Time;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.
const int N_OCTAVES=8;

/*float noisegen3(vec3 pos){
    return fract(sin(dot(pos, vec3(12.9898,78.233,32.767)))*43758.5453);
}*/
mat4 rotateX(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat4(
        vec4(1, 0, 0,0),
        vec4(0, c, -s,0),
        vec4(0, s, c,0),
        vec4(0, 0, 0,1)
    );
}
mat4 rotateY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat4(
        vec4(c, 0, s,0),
        vec4(0, 1, 0,0),
        vec4(-s, 0, c,0),
        vec4(0, 0, 0,1)
    );
}
mat4 rotateZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat4(
        vec4(c, -s, 0,0),
        vec4(s, c, 0,0),
        vec4(0, 0, 1,0),
        vec4(0, 0, 0,1)
    );
}

float noisegen3(vec3 pos){
    return fract(sin(dot(pos, vec3(12.9898,78.233,43.21)))*43758.5453);
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat4 randomMat=rotateX(cos(u_Time)*noisegen3(vec3(vs_Pos)))*rotateY(sin(u_Time)*noisegen3(vec3(vs_Pos)))*rotateY(sin(u_Time)*cos(u_Time)*noisegen3(vec3(vs_Pos)));

    mat4 ivrMat=transpose(inverse(randomMat));
    mat3 invTranspose = mat3(ivrMat*u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    //vec4 noise=noiseDP(u_Time,vec3(vs_Pos))*vs_Pos;
    //vec3 axis = vec3(1.0, 0.0, 0.0);
    vec4 modelposition = u_Model * randomMat*vs_Pos;   // Temporarily store the transformed vertex positions for use below

    //vec4 modelposition = u_Model * vec4(0.0f,0.0f,0.0f,1.0f); 
    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
