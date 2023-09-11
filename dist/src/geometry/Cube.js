import { vec3, vec4 } from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import { gl } from '../globals';
class Cube extends Drawable {
    constructor(center, size, subdivisions) {
        super(); // Call the constructor of the super class. This is required.
        this.size = size;
        this.subdivisions = subdivisions;
        this.center = vec4.fromValues(center[0], center[1], center[2], 1);
    }
    create() {
        let halfSize = this.size * 0.5;
        let stepSize = this.size / this.subdivisions;
        this.indices = new Uint32Array(this.subdivisions * this.subdivisions * 6 * 6);
        // this.positions = new Float32Array(8 + (this.subdivisions - 1) ** 2 + (this.subdivisions - 1) * 12);
        this.positions = new Float32Array(this.subdivisions * this.subdivisions * 4 * 4 * 6);
        this.normals = new Float32Array(this.positions.length);
        let positionIdx = 0, indexIdx = 0, normalIdx = 0;
        // front & back
        for (let x = -halfSize; x < halfSize; x += stepSize) {
            for (let y = -halfSize; y < halfSize; y += stepSize) {
                for (let zz = -1; zz <= 1; zz += 2) {
                    let z = zz * halfSize;
                    let v0 = positionIdx / 4;
                    let v1 = v0 + 1;
                    let v2 = v1 + 1;
                    let v3 = v2 + 1;
                    this.indices[indexIdx++] = v0;
                    this.indices[indexIdx++] = v1;
                    this.indices[indexIdx++] = v2;
                    this.indices[indexIdx++] = v2;
                    this.indices[indexIdx++] = v3;
                    this.indices[indexIdx++] = v0;
                    let normal = vec3.fromValues(0, 0, zz);
                    vec3.normalize(normal, normal);
                    // v0
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // v1
                    x += stepSize;
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // v2
                    y += stepSize;
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // v3
                    x -= stepSize;
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // back to v0
                    y -= stepSize;
                }
            }
        }
        // left & right
        for (let xx = -1; xx <= 1; xx += 2) {
            for (let y = -halfSize; y < halfSize; y += stepSize) {
                for (let z = -halfSize; z < halfSize; z += stepSize) {
                    let x = xx * halfSize;
                    let v0 = positionIdx / 4;
                    let v1 = v0 + 1;
                    let v2 = v1 + 1;
                    let v3 = v2 + 1;
                    this.indices[indexIdx++] = v0;
                    this.indices[indexIdx++] = v1;
                    this.indices[indexIdx++] = v2;
                    this.indices[indexIdx++] = v2;
                    this.indices[indexIdx++] = v3;
                    this.indices[indexIdx++] = v0;
                    let normal = vec3.fromValues(xx, 0, 0);
                    vec3.normalize(normal, normal);
                    // v0
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // v1
                    y += stepSize;
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // v2
                    z += stepSize;
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // v3
                    y -= stepSize;
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // back to v0
                    z -= stepSize;
                }
            }
        }
        // top & bottom
        for (let x = -halfSize; x < halfSize; x += stepSize) {
            for (let yy = -1; yy <= 1; yy += 2) {
                for (let z = -halfSize; z < halfSize; z += stepSize) {
                    let y = yy * halfSize;
                    let v0 = positionIdx / 4;
                    let v1 = v0 + 1;
                    let v2 = v1 + 1;
                    let v3 = v2 + 1;
                    this.indices[indexIdx++] = v0;
                    this.indices[indexIdx++] = v1;
                    this.indices[indexIdx++] = v2;
                    this.indices[indexIdx++] = v2;
                    this.indices[indexIdx++] = v3;
                    this.indices[indexIdx++] = v0;
                    let normal = vec3.fromValues(0, yy, 0);
                    vec3.normalize(normal, normal);
                    // v0
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // v1
                    x += stepSize;
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // v2
                    z += stepSize;
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // v3
                    x -= stepSize;
                    this.positions[positionIdx++] = x + this.center[0];
                    this.positions[positionIdx++] = y + this.center[1];
                    this.positions[positionIdx++] = z + this.center[2];
                    this.positions[positionIdx++] = 1.0;
                    this.normals[normalIdx++] = normal[0];
                    this.normals[normalIdx++] = normal[1];
                    this.normals[normalIdx++] = normal[2];
                    this.normals[normalIdx++] = 0.0;
                    // back to v0
                    z -= stepSize;
                }
            }
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
        console.log(`Created square`);
    }
}
export default Cube;
//# sourceMappingURL=Cube.js.map