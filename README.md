# Intro to Javascript and WebGL

[Live Demo Link] (https://yuhanliu-tech.github.io/hw00-intro-base/)

* Added a Cube class that inherits from Drawable. Then added a Cube instance to the scene to be rendered.

* Updated existing GUI in main.ts with a parameter to alter the color passed to u_Color in the Lambert shader.

* Implemented custom fragment shader that uses Absolute Value 3D Perlin Noise to modify fragment color. I wanted to create an inky paint effect on the cube that animates with respect to time.

* Also implemented custom vertex shader that uses 3D Perlin noise and cosine functions to gently deform the cube's vertices over time. 

![Image](https://github.com/yuhanliu-tech/hw00-intro-base/blob/master/image.png)
