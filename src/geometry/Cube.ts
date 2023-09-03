import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
    center : vec3;
    sizes : vec3;
    
    constructor(center: vec3, sizes : vec3) {
        super(); // Call the constructor of the super class. This is required.
        this.center = center;
        this.sizes = sizes;
    }

    create(): void {
        this.generateIdx();
        this.generatePos();
        this.generateNor();

        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
        // create 6 faces with 2 triangles each
        const positions = [
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
        ];

        for (let i = 0; i < positions.length; i += 4) {
            positions[i] *= this.sizes[0];
            positions[i + 1] *= this.sizes[1];
            positions[i + 2] *= this.sizes[2];
            positions[i] += this.center[0];
            positions[i + 1] += this.center[1];
            positions[i + 2] += this.center[2];
        }

        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);
        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
        const normals = [
            // front
            0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0,
            // back
            0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0,
            // left
            -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0,
            // right
            1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
            // top
            0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0,
            // bottom
            0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0
        ];
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(normals), gl.STATIC_DRAW);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
        const indices = [
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
        ];
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint32Array(indices), gl.STATIC_DRAW);
        this.count = indices.length;
    }
}

export default Cube;