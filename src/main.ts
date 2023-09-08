import {vec3, vec4,mat4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import Cube from './geometry/Cube';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import { mode } from '../webpack.config';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  GUIcolor:[0, 128, 255,1],
  GUIworley0: 0,
  GUIworley1: 1,
};

let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let prevTesselations: number = 5;
let color: vec4;
let date: Date;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  cube = new Cube(vec3.fromValues(0, 0, 0));
  cube.create();
}

function loadGUI(){
    // Add controls to the gui
    const gui = new DAT.GUI();
    gui.add(controls, 'tesselations', 0, 8).step(1);
    color = vec4.fromValues(1,1,1,1);
    gui.addColor(controls,"GUIcolor").name("cube color").onChange((value)=>{
      color = vec4.fromValues(value[0]/255.0,value[1]/255.0,value[2]/255.0,1);
    });
    gui.add(controls,"GUIworley0",0.0,1.0).step(0.1);
    gui.add(controls,"GUIworley1",0.0,1.0).step(0.1);
}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);
  date = new Date();

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
  loadGUI();
  
  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));
  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);
  const worley = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/worley-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/worley-frag.glsl')),
  ]);
  worley.addUnif("u_worley0");
  worley.addUnif("u_worley1");
  worley.addUnif("u_time");
  lambert.addUnif("u_time");


  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    //update inputs
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }
    lambert.setGeometryColor(color);
    worley.setGeometryColor(color);
    worley.setUnifFloat("u_worley0",controls.GUIworley0);
    worley.setUnifFloat("u_worley1",controls.GUIworley1);
    let time = Date.now()%2000000/1000.0;
    worley.setUnifFloat("u_time",time);
    lambert.setUnifFloat("u_time",time);
    let model = mat4.create();
    mat4.identity(model);
    model[0] = 0.6;
    model[5] = 0.6;
    model[10] = 0.6;
    lambert.setModelMatrix(model);
    
    model[14] = 1.5 * Math.sin(time);
    model[13] = 0
    model[12] = 1.5 * Math.cos(time);

    worley.setModelMatrix(model);
    //render
    renderer.render(camera, lambert, [
      icosphere,
    ]);

    renderer.render(camera,worley,[
      cube,
    ]);
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
