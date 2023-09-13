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
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.


float random1(float x) {
    return fract(sin(x) * 43758.5453123); // This is an example random function using sin(). Replace with your actual random1 function.
}

float worley(float p) {
    float pInt = floor(p);
    float pFract = fract(p);

    float minDist = 1.0;  // Maximum possible value in our 1D space
    float secondMinDist = 1.0;
    // Iterate over the current cell and immediate neighbors
    for(int x = -1; x <= 1; x++) {
        float cellPoint = pInt + float(x);
        float voronoiPoint = cellPoint + random1(cellPoint);  // Compute Voronoi centerpoint for the cell
        float dist = abs(pFract + float(x) - voronoiPoint);  // Compute distance to the Voronoi point
        if(dist < minDist) {
            secondMinDist = minDist;
            minDist = dist;
        } else if(dist < secondMinDist) {
            secondMinDist = dist;
        }
    }

    return mix(minDist, secondMinDist, 0.5);
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation
    fs_Pos = vs_Pos;

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.


    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    float timeOffset = sin(u_Time / 1000.0) * 0.5 + 0.5;

    modelposition.x += worley(vs_Pos.y * timeOffset + vs_Pos.z * (1.0 - timeOffset));
    modelposition.y += worley(vs_Pos.z * timeOffset + vs_Pos.x * (1.0 - timeOffset));
    modelposition.z += worley(vs_Pos.x * timeOffset + vs_Pos.y * (1.0 - timeOffset));

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
