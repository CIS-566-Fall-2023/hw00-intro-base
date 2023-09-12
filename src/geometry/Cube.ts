import { vec3, vec4 } from "gl-matrix"
import Drawable from "../rendering/gl/Drawable"
import { gl } from "../globals"

// Utility function to flatten arrays of arrays
function flatten(arrays: number[][]): Float32Array {
  return new Float32Array([].concat(...arrays))
}

class Cube extends Drawable {
  buffer: ArrayBuffer
  indices: Uint32Array
  positions: Float32Array
  normals: Float32Array
  center: vec4

  constructor(center: vec3, public sideLength: number) {
    super()
    this.center = vec4.fromValues(center[0], center[1], center[2], 1)
  }

  create() {
    // The indices of the vertices of each triangle in the cube
    this.indices = new Uint32Array([
      0,
      1,
      2,
      0,
      2,
      3, // Front

      4,
      5,
      6,
      4,
      6,
      7, // Back

      8,
      9,
      10,
      8,
      10,
      11, // Top

      12,
      13,
      14,
      12,
      14,
      15, // Bottom

      16,
      17,
      18,
      16,
      18,
      19, // Left

      20,
      21,
      22,
      20,
      22,
      23, // Right
    ])

    // The normals of each vertex
    this.normals = flatten([
      ...Array(4).fill([0, 0, 1, 0]), // Front face
      ...Array(4).fill([0, 0, -1, 0]), // Back face
      ...Array(4).fill([0, 1, 0, 0]), // Top face
      ...Array(4).fill([0, -1, 0, 0]), // Bottom face
      ...Array(4).fill([-1, 0, 0, 0]), // Left face
      ...Array(4).fill([1, 0, 0, 0]), // Right face
    ])

    const halfLength = this.sideLength / 2
    const [cx, cy, cz] = [this.center[0], this.center[1], this.center[2]]

    // Lambda function to add the center coordinates to each vertex
    const v = (x: number, y: number, z: number) => [x + cx, y + cy, z + cz, 1]
    const frontTopLeft = v(-halfLength, halfLength, halfLength)
    const frontTopRight = v(halfLength, halfLength, halfLength)
    const frontBottomLeft = v(-halfLength, -halfLength, halfLength)
    const frontBottomRight = v(halfLength, -halfLength, halfLength)
    const backTopLeft = v(-halfLength, halfLength, -halfLength)
    const backTopRight = v(halfLength, halfLength, -halfLength)
    const backBottomLeft = v(-halfLength, -halfLength, -halfLength)
    const backBottomRight = v(halfLength, -halfLength, -halfLength)

    this.positions = new Float32Array([
      ...frontBottomLeft,
      ...frontBottomRight,
      ...frontTopRight,
      ...frontTopLeft,
      ...backBottomLeft,
      ...backBottomRight,
      ...backTopRight,
      ...backTopLeft,
      ...frontTopLeft,
      ...frontTopRight,
      ...backTopRight,
      ...backTopLeft,
      ...frontBottomLeft,
      ...frontBottomRight,
      ...backBottomRight,
      ...backBottomLeft,
      ...frontBottomLeft,
      ...backBottomLeft,
      ...backTopLeft,
      ...frontTopLeft,
      ...frontBottomRight,
      ...backBottomRight,
      ...backTopRight,
      ...frontTopRight,
    ])

    this.generateIdx()
    this.generatePos()
    this.generateNor()

    this.count = this.indices.length
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx)
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW)

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor)
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW)

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos)
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW)

    console.log(`Created cube`)
  }
}

export default Cube
