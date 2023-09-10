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
        const i = 0;
        // Initialise new float array.
        const vertList = new Float32Array(36);

        vertList[i] = 1;
        return vertList;
    }

    createNormals() {
        // TODO
    }

    createIndices() {
        // TODO
    }

    // The override. 
    create(): Drawable {
        // TODO
        this.positions = this.createPositions();

        this.generateIdx();
        this.generatePos();
        this.generateNor();

        this.count = this.indices.length;
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);

        return;
    }

}