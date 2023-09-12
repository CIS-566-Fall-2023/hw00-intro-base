import {vec3} from 'gl-matrix';
import {mat4, vec4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import IcosphereEar from './geometry/IcosphereEar';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import Cube from './geometry/Cube'
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
   R: 0.4,
   G: 0.3,
   B: 0.4
};

let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let ear1: Icosphere;
let ear2: Icosphere;
let prevTesselations: number = 5;
let prevR: number = 0;
let prevG: number = 1;
let prevB: number = 0;
let time: number = 0;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(1, 1, 1));
  square.create();
  cube = new Cube(vec3.fromValues(0,0,0))
  cube.create()
  ear1 = new Icosphere(vec3.fromValues(0.6, 0.6, 0.6), 0.5, controls.tesselations);
  ear1.create()
  ear2 = new Icosphere(vec3.fromValues(-0.5, -0.5, -0.5), 0.2, controls.tesselations);
  ear2.create()

}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  gui.add(controls, 'R', 0, 1 ).step(0.1);
  gui.add(controls, 'G', 0, 1).step(0.1);
  gui.add(controls, 'B', 0, 1).step(0.1);

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/worley-frag.glsl')),
  ]);

  const basic = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/basic-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  // This function will be called every frame
  function tick() {
    time += 1;
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    
    renderer.clear();
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }
    if(controls.R != prevR)
    {
      prevR= controls.R;
    }
    if(controls.G != prevG)
    {
      prevG= controls.G;
    }
    if(controls.B != prevB)
    {
      prevB= controls.B;
    }

    renderer.render(camera, lambert, [
      icosphere
    ], vec4.fromValues(207, 10, 192,1), time);
    stats.end();

    renderer.render(camera, basic, [
      cube
    ], vec4.fromValues(prevR,prevG,prevB,1), time);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
