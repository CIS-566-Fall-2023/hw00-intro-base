import Drawable from "./Drawable";
import { vec3, vec4 } from "gl-matrix"
import { gl } from "../../globals"

class Cube extends Drawable {
  indices: Uint32Array
  positions: Float32Array
  normals: Float32Array
  center: vec4

  constructor(center: vec3) {
    super();
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create() {

    this.indices = new Uint32Array([
                                    0, 1, 2,
                                    0, 2, 3,
  
                                    1, 4, 5, 
                                    1, 5, 2,
  
                                    6, 4, 5,
                                    6, 5, 7,
  
                                    0, 6, 7,
                                    0, 7, 3,
  
                                    3, 2, 5, 
                                    3, 5, 7,
  
                                    0, 1, 4,
                                    0, 4, 6
                                  ]);
    this.normals = new Float32Array([
                                     0, 0, 1, 0,
                                     0, 0, 1, 0,
                                     0, 0, 1, 0,
                                     0, 0, 1, 0,
  
                                     1, 0, 0, 0,
                                     1, 0, 0, 0,
                                     1, 0, 0, 0,
                                     1, 0, 0, 0,
  
                                     0, 0, -1, 0,
                                     0, 0, -1, 0,
                                     0, 0, -1, 0,
                                     0, 0, -1, 0,
  
                                     -1, 0, 0, 0,
                                     -1, 0, 0, 0,
                                     -1, 0, 0, 0,
                                     -1, 0, 0, 0,
  
                                     0, 1, 0, 0,
                                     0, 1, 0, 0,
                                     0, 1, 0, 0,
                                     0, 1, 0, 0,
  
                                     0, -1, 0, 0,
                                     0, -1, 0, 0,
                                     0, -1, 0, 0,
                                     0, -1, 0, 0,
                                     ]);
  
    this.positions = new Float32Array([
                                      -1, -1, 1, 1,
                                       1, -1, 1, 1,
                                       1, 1, 1, 1,
                                       -1, 1, 1, 1,
  
                                       1, -1, -1, 1,
                                       1, 1, -1, 1,
                                       -1, -1, -1, 1,
                                       -1, 1, -1, 1
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
                                      }
  
}

export default Cube

