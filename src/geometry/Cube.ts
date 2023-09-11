import { vec3, vec4 } from 'gl-matrix';
import Drawable from "../rendering/gl/Drawable";
import { gl } from '../globals';

class Cube extends Drawable {
    indices: Uint32Array;
    positions: Float32Array;
    normals: Float32Array;
    center: vec4;

    constructor(center: vec3) {
        super();
        this.center = vec4.fromValues(center[0], center[1], center[2], 1);
    }

    createPositions() {
        // Initialise new float array.
        const vertList = new Float32Array([1, 1, 1, 1,
            1, -1, 1, 1,
            -1, -1, 1, 1,
            -1, 1, 1, 1, // Front

            1, 1, -1, 1,
            1, -1, -1, 1,
            1, -1, 1, 1,
            1, 1, 1, 1, // Right

            -1, 1, 1, 1,
            -1, -1, 1, 1,
            -1, -1, -1, 1,
            -1, 1, -1, 1, // Left

            -1, 1, -1, 1,
            -1, -1, -1, 1,
            1, -1, -1, 1,
            1, 1, -1, 1, // Back

            1, 1, -1, 1,
            1, 1, 1, 1,
            -1, 1, 1, 1,
            -1, 1, -1, 1, // Up

            1, -1, 1, 1,
            1, -1, -1, 1,
            -1, -1, -1, 1,
            -1, -1, 1, 1 // Down
        ]);

        return vertList;
    }

    createNormals() {
        const normList = new Float32Array([0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0, // Front

            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0, // Right

            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0, // Left

            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0, // Back

            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0, // Up

            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0 // Down
        ]);
        return normList;
    }

    createIndices() {
        const inds = new Uint32Array([0, 1, 2,
            0, 2, 3,
            4, 5, 6,
            4, 6, 7,
            8, 9, 10,
            8, 10, 11,
            12, 13, 14,
            12, 14, 15,
            16, 17, 18,
            16, 18, 19,
            20, 21, 22,
            20, 22, 23]);
        return inds;
    }

    // The override. 
    create() {
        this.positions = this.createPositions();
        this.normals = this.createNormals();
        this.indices = this.createIndices();

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

        console.log('Created cube.');
    }

}

export default Cube;