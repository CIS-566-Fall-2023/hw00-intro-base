import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable
{
    indices: Uint32Array;
    positions: Float32Array;
    normals: Float32Array;

    center: vec3;
    size: vec3;

    constructor(center: vec3, size: vec3){
        super();
        this.center = center;
        this.size = size;
    }

    create(): void {

        this.indices = new Uint32Array([
            // front
            0, 1, 2,
            2, 3, 0,
            // back
            4, 5, 6,
            6, 7, 4,
            // left
            8, 9, 10,
            10, 11, 8,
            // right
            12, 13, 14,
            14, 15, 12,
            // top
            16, 17, 18,
            18, 19, 16,
            // bottom
            20, 21, 22,
            22, 23, 20
        ]);
          
        this.normals = new Float32Array([
            0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0,   // Front face 
            0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0,  // Back face 
            -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0,   // Left face 
            1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,    // Right face 
            0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0,   // Top face 
            0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0   // Bottom face  
        ]);
          
        this.positions = new Float32Array([
            // front
            -1, -1, 1, 1,
            1, -1, 1, 1,
            1, 1, 1, 1,
            -1, 1, 1, 1,
            // back
            -1, -1, -1, 1,
            1, -1, -1, 1,
            1, 1, -1, 1,
            -1, 1, -1, 1,
            // left
            -1, -1, -1, 1,
            -1, -1, 1, 1,
            -1, 1, 1, 1,
            -1, 1, -1, 1,
            // right
            1, -1, -1, 1,
            1, -1, 1, 1,
            1, 1, 1, 1,
            1, 1, -1, 1,
            // top
            -1, 1, -1, 1,
            1, 1, -1, 1,
            1, 1, 1, 1,
            -1, 1, 1, 1,
            // bottom
            -1, -1, -1, 1,
            1, -1, -1, 1,
            1, -1, 1, 1,
            -1, -1, 1, 1
        ]);

        for (let i = 0; i < this.positions.length; i += 4) {
            this.positions[i] = this.positions[i] * this.size[0] + this.center[0];
            this.positions[i + 1] = this.positions[i + 1] * this.size[1] + this.center[1];
            this.positions[i + 2] = this.positions[i + 2] * this.size[2] + this.center[2];
        }

        this.generateIdx();
        this.generatePos();
        this.generateNor();

        this.count = this.indices.length;
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
        gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
        gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

        console.log(`Created Cube`);
    }
}

export default Cube;