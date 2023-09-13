import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
    indices: Uint32Array;
    positions: Float32Array;
    normals: Float32Array;
    center: vec4;

    constructor(center: vec3) {
        super();
        this.center = vec4.fromValues(center[0], center[1], center[2], 1);
    }

    create() {
        // Define vertices for a cube (12 triangles, 36 indices)
        this.indices = new Uint32Array([
            0, 1, 2, 0, 2, 3, // Front
            4, 5, 6, 4, 6, 7, // Back
            8, 9, 10, 8, 10, 11, // Top
            12, 13, 14, 12, 14, 15, // Bottom
            16, 17, 18, 16, 18, 19, // Right
            20, 21, 22, 20, 22, 23  // Left
        ]);

        this.positions = new Float32Array([
             // front
             -1, -1, -1, 1,
             1, -1, -1, 1,
             1, 1, -1, 1,
             -1, 1, -1, 1,
             // right
             1, -1, -1, 1,
             1,-1, 1, 1,
             1, 1, 1, 1,
             1, 1, -1, 1,
             // back
             1, -1, 1, 1,
             -1, -1, 1, 1,
             -1, 1, 1, 1,
             1, 1, 1, 1,
             // left
             -1, -1, 1, 1, 
             -1, -1, -1, 1,
             -1, 1, -1, 1,
             -1, 1, 1, 1,
             // up
             -1, 1, -1, 1,
             1, 1, -1, 1,
             1, 1, 1, 1, 
             -1, 1, 1, 1,
             // down
             -1, -1, -1, 1,
             1, -1, -1, 1,
             1, -1, 1, 1, 
             -1, -1, 1, 1
        ]);

        this.normals = new Float32Array([
            // Front
            0, 0, -1, 0,
            0, 0, -1, 0,
            0, 0, -1, 0,
            0, 0, -1, 0,
            // Right
            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            // Back
            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0,
            // Left
            -1, 0, 0, 0,
            -1, 0, 0, 0,
            -1, 0, 0, 0,
            -1, 0, 0, 0,
            // Top
            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0,
            // Bottom
            0, -1, 0, 0,
            0, -1, 0, 0,
            0, -1, 0, 0,
            0, -1, 0, 0
        ]);
        


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

        console.log(`Created cube`);
    }
};

export default Cube;