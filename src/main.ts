import {vec2, vec3, vec4, mat4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import Cube from './geometry/Cube';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import FrameBuffer from './rendering/gl/FrameBuffer';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  worley_factor: 10,
  'Load Scene': loadScene, // A function pointer, essentially,
   diffuse_color: 0xffffff
};

let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let prevTesselations: number = 5;

function hexToVec3(hexColor : number): vec3 
{
  // Parse hexadecimal values to decimal
  const b = (hexColor & 0x0000ff) / 255.0;
  const g = ((hexColor >> 8) & 0x0000ff) / 255.0;
  const r = ((hexColor >> 16) & 0x0000ff) / 255.0;

  return vec3.fromValues(r, g, b);
}

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 0.1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  cube = new Cube(vec3.fromValues(0, 0, 0));
  square.create();
  cube.create();
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
  gui.addColor(controls, 'diffuse_color');
  gui.add(controls, 'worley_factor', 1, 100).step(1);
  
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
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/noise-frag.glsl')),
  ]);
  const sphere_shader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/noise-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/noise-sphere-frag.glsl')),
  ]);

  const postprocess = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/passthrough-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/postprocess-frag.glsl')),
  ]);
  const fb = new FrameBuffer(vec2.fromValues(window.innerWidth, window.innerHeight));
  //fb.resize();
  var time = 0;
  const dt = 0.01;
  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    fb.use();
    
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 0.005, prevTesselations);
      icosphere.create();
    }
    const color = hexToVec3(controls.diffuse_color);
    lambert.setUniformFloat4("u_Color", vec4.fromValues(color[0], color[1], color[2], 1));
    lambert.setUniformFloat("u_Time", time);
    sphere_shader.setUniformFloat4("u_Color", vec4.fromValues(color[0], color[1], color[2], 1));
    sphere_shader.setUniformFloat("u_Time", time);

    let model = mat4.create();
    let modelinvtr: mat4 = mat4.create();
    //mat4.identity(model);
    let angle = 0.5 * Math.sin(Math.cos(time)) + 0.5;
    model = mat4.rotate(mat4.create(), model, 2 * Math.PI * angle, vec3.fromValues(Math.sin(time), Math.sin(0.3 + 0.7 * time), 1));

    mat4.transpose(modelinvtr, model);
    mat4.invert(modelinvtr, modelinvtr);

    lambert.setUniformMat4("u_Model", model);
    lambert.setUniformMat4("u_ModelInvTr", modelinvtr);

    sphere_shader.setUniformMat4("u_Model", model);
    sphere_shader.setUniformMat4("u_ModelInvTr", modelinvtr);

    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    renderer.render(camera, lambert, [
      cube,
      // square,
    ]);
    
    renderer.render(camera, sphere_shader, [
      icosphere,
      // square,
    ]);

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();

    fb.bindToSlot(1);
    postprocess.setUniformInt("u_RenderedImage", 1);
    postprocess.setUniformFloat("u_Factor", controls.worley_factor);
    postprocess.setUniformFloat("u_Time", time);
    renderer.render(camera, postprocess, [
      square
    ]);

    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
    time += dt;
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
    fb.resize(vec2.fromValues(window.innerWidth, window.innerHeight));
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
