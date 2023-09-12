import {vec3, vec4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import Cube from './geometry/Cube';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  red: 256,
  green: 0,
  blue: 0,
  'Toggle Frag': toggleFrag,
  'Toggle Vert': toggleVert
};

let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let prevTesselations: number = 5;
let prevFragVert = {frag: 0, vert:0};

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  cube = new Cube(vec3.fromValues(0, 0, 0), 1);
  cube.create();
}

const fragvert = {
  frag: 0,
  vert: 0
}
function toggleFrag() {
  if(fragvert.frag == 0){
    fragvert.frag = 1;
  }
  else {
    fragvert.frag = 0;
  }
}

function toggleVert() {
  if(fragvert.vert == 0){
    fragvert.vert = 1;
  }
  else {
    fragvert.vert = 0;
  }
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
  gui.add(controls, 'red', 0, 256).step(1);
  gui.add(controls, 'green', 0, 256).step(1);
  gui.add(controls, 'blue', 0, 256).step(1);
  gui.add(controls, 'Toggle Frag');
  gui.add(controls, 'Toggle Vert');


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

  const frags = [
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')), 
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/perlin-frag.glsl'))
  ];
  const verts = [
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')), 
    new Shader(gl.VERTEX_SHADER, require('./shaders/trig-vert.glsl'))
  ];

  var shaderprog = new ShaderProgram([
    verts[0],
    frags[0]
  ]);

  let timetick: number = 0;
  // This function will be called every frame
  function tick() {
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
    if(fragvert.frag != prevFragVert.frag || fragvert.vert != prevFragVert.vert) {
      shaderprog = new ShaderProgram([verts[fragvert.vert],
        frags[fragvert.frag]]);
      prevFragVert.frag = fragvert.frag;
      prevFragVert.vert = fragvert.vert;
      timetick = 0;
    }

    renderer.render(camera, shaderprog, [
      cube,
      // square,
    ], vec4.fromValues(controls.red/256, controls.green/256, controls.blue/256, 1), timetick);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
    timetick++;
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
