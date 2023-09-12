import { vec3 } from "gl-matrix"
const Stats = require("stats-js")
import * as DAT from "dat.gui"
import Icosphere from "./geometry/Icosphere"
import Square from "./geometry/Square"
import Cube from "./geometry/Cube"
import OpenGLRenderer from "./rendering/gl/OpenGLRenderer"
import Camera from "./Camera"
import { setGL } from "./globals"
import ShaderProgram, { Shader } from "./rendering/gl/ShaderProgram"

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  color: [255, 0, 0], // color of the object
  "Load Scene": loadScene, // A function pointer, essentially
}

let startTime = Date.now() // Start time for animation
let worleyScale = 0.00006 // Scale for worley noise
let timeScale = 0.1 // Scale for time

let icosphere: Icosphere
let square: Square
let cube: Cube
let prevTesselations: number = 5

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations)
  icosphere.create()
  square = new Square(vec3.fromValues(0, 0, 0))
  square.create()
  cube = new Cube(vec3.fromValues(0, 0, 0), 1)
  cube.create()
}

function main() {
  // Initial display for framerate
  const stats = Stats()
  stats.setMode(0)
  stats.domElement.style.position = "absolute"
  stats.domElement.style.left = "0px"
  stats.domElement.style.top = "0px"
  document.body.appendChild(stats.domElement)

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement>document.getElementById("canvas")
  const gl = <WebGL2RenderingContext>canvas.getContext("webgl2")
  if (!gl) {
    alert("WebGL 2 not supported!")
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl)

  // Initial call to load scene
  loadScene()

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0))

  const renderer = new OpenGLRenderer(canvas)
  renderer.setClearColor(0.2, 0.2, 0.2, 1)
  gl.enable(gl.DEPTH_TEST)

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require("./shaders/noise-vertex.glsl")),
    new Shader(gl.FRAGMENT_SHADER, require("./shaders/perlin-frag.glsl")),
  ])

  // Set default color to red
  lambert.setGeometryColor(new Float32Array([1, 0, 0, 1]))

  // Add controls to the gui
  const gui = new DAT.GUI()
  gui.add(controls, "tesselations", 0, 8).step(1)
  gui.add(controls, "Load Scene")
  gui.addColor(controls, "color").onChange(() => {
    const normalizedColor = new Float32Array([
      controls.color[0] / 255,
      controls.color[1] / 255,
      controls.color[2] / 255,
      1.0, // Alpha value. You can adjust this if you want a different default alpha.
    ])
    lambert.setGeometryColor(normalizedColor)
  })

  // set the default scale for worley noise
  lambert.setScale(new Float32Array([worleyScale, worleyScale, worleyScale, 1]))

  // This function will be called every frame
  function tick() {
    let elapsedTime = (Date.now() - startTime) * 0.001 * timeScale // Convert from ms to seconds, remap to -1 to 1 range
    lambert.setTime(elapsedTime)

    camera.update()
    stats.begin()
    gl.viewport(0, 0, window.innerWidth, window.innerHeight)
    renderer.clear()
    if (controls.tesselations != prevTesselations) {
      prevTesselations = controls.tesselations
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations)
      icosphere.create()
    }
    renderer.render(camera, lambert, [
      //   cube,
      icosphere,
      //   square,
    ])
    stats.end()

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick)
  }

  window.addEventListener(
    "resize",
    function () {
      renderer.setSize(window.innerWidth, window.innerHeight)
      camera.setAspectRatio(window.innerWidth / window.innerHeight)
      camera.updateProjectionMatrix()
    },
    false
  )

  renderer.setSize(window.innerWidth, window.innerHeight)
  camera.setAspectRatio(window.innerWidth / window.innerHeight)
  camera.updateProjectionMatrix()

  // Start the render loop
  tick()
}

main()
