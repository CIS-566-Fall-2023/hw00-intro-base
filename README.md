# HW 0: Intro to Javascript and WebGL

<p align="center">
  <img width="360" height="360" src="https://user-images.githubusercontent.com/1758825/132532354-e3a45402-e484-499e-bfa7-2d73b9f2c946.png">
</p>
<p align="center">(source: Ken Perlin)</p>

## Claire Lu
For the fragment shader, I used fbm to create the transitions between colors and the soft fractal noise textures. I parametrized the color changes based on time as well, helping to create the glow effect, where the shape transitions from blue/green to pink and then white. For the vertex shader, I used a combination of worley noise and fbm. When looking at the icosphere, this creates soft bumpy mountains, which pulse according to time. The cube also wobbles because of these vertex deformations. 

[Live Demo](https://clairel21.github.io/hw00-intro-base/)

## Icosphere
<img width="545" alt="Screenshot 2023-09-13 at 11 36 27 PM" src="https://github.com/ClaireL21/hw00-intro-base/assets/102630261/a6382ad9-1ae1-4d5b-a878-bfb5fbbe2fc7">

<img width="535" alt="Screenshot 2023-09-14 at 12 27 59 AM" src="https://github.com/ClaireL21/hw00-intro-base/assets/102630261/9bb8d5d2-eea1-4e3e-9408-75f22e970384">

<img width="500" alt="Screenshot 2023-09-13 at 11 37 21 PM" src="https://github.com/ClaireL21/hw00-intro-base/assets/102630261/e23acd94-2287-44ed-a9f4-92d2a7ac2069">

## Cube
<img width="686" alt="Screenshot 2023-09-13 at 11 40 13 PM" src="https://github.com/ClaireL21/hw00-intro-base/assets/102630261/f8fb6ee6-4a38-4f35-ae78-e48ea6630804">

<img width="534" alt="Screenshot 2023-09-14 at 12 29 31 AM" src="https://github.com/ClaireL21/hw00-intro-base/assets/102630261/7ae104bb-0f5d-400f-ade3-979cccdfc92b">

<img width="548" alt="Screenshot 2023-09-13 at 11 37 29 PM" src="https://github.com/ClaireL21/hw00-intro-base/assets/102630261/336df77a-6a16-4880-aa4f-01e17cd5d942">


## Objective
- Check that the tools and build configuration we will be using for the class works.
- Start learning Typescript and WebGL2
- Practice implementing noise

## Forking the Code
Rather than cloning the homework repository, please __fork__ the code into your own repository using the `Fork` button in the upper-right hand corner of the Github UI. This will enable you to have your own personal repository copy of the code, and let you make a live demo (described later in this document).

## Running the Code

1. [Install Node.js](https://nodejs.org/en/download/). Node.js is a JavaScript runtime. It basically allows you to run JavaScript when not in a browser. For our purposes, this is not necessary. The important part is that with it comes `npm`, the Node Package Manager. This allows us to easily declare and install external dependencies such as [dat.GUI](https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage), and [glMatrix](http://glmatrix.net/).

2. Using a command terminal, run `npm install` in the root directory of your project. This will download all of those dependencies.

3. Do either of the following (but we highly recommend the first one for reasons we will explain later).

    a. Run `npm start` and then go to `localhost:5660` in your web browser

    b. Run `npm run build` and then go open `dist/index.html` in your web browser

## Module Bundling
One of the most important dependencies of our projects is [Webpack](https://webpack.js.org/concepts/). Webpack is a module bundler which allows us to write code in separate files and use `import`s and `export`s to load classes and functions for other files. It also allows us to preprocess code before compiling to a single file. We will be using [Typescript](https://www.typescriptlang.org/docs/home.html) for this course which is Javascript augmented with type annotations. Webpack will convert Typescript files to Javascript files on compilation and in doing so will also check for proper type-safety and usage. Read more about Javascript modules in the resources section below.

## Developing Your Code
All of the JavaScript code is living inside the `src` directory. The main file that gets executed when you load the page as you may have guessed is `main.ts`. Here, you can make any changes you want, import functions from other files, etc. The reason that we highly suggest you build your project with `npm start` is that doing so will start a process that watches for any changes you make to your code. If it detects anything, it'll automagically rebuild your project and then refresh your browser window for you. Wow. That's cool. If you do it the other way, you'll need to run `npm build` and then refresh your page every time you want to test something.

We would suggest editing your project with Visual Studio Code https://code.visualstudio.com/. Microsoft develops it and Microsoft also develops Typescript so all of the features work nicely together. Sublime Text and installing the Typescript plugins should probably work as well.

## Assignment Details
1. Take some time to go through the existing codebase so you can get an understanding of syntax and how the code is architected. Much of the code is designed to mirror the class structures used in CIS 460's OpenGL assignments, so it should hopefully be somewhat familiar.
2. Take a look at the resources linked in the section below. Definitely read about Javascript modules and Typescript. The other links provide documentation for classes used in the code.
3. Add a `Cube` class that inherits from `Drawable` and at the very least implement a constructor and its `create` function. Then, add a `Cube` instance to the scene to be rendered.
4. Read the documentation for dat.GUI below. Update the existing GUI in `main.ts` with a parameter to alter the color passed to `u_Color` in the Lambert shader.
5. Write a custom fragment shader that implements FBM, Worley Noise, or Perlin Noise based on 3D inputs (as opposed to the 2D inputs in the slides). This noise must be used to modify your fragment color. If your custom shader is particularly interesting, you'll earn some bonus points.
6. Write a custom vertex shader that uses a trigonometric function (e.g. `sin`, `tan`) to non-uniformly modify your cube's vertex positions over time. This will necessitate instantiating an incrementing variable in your Typescript code that you pass to your shader every tick. Refer to the base code's methods of passing variables to shaders if you are unsure how to do so.
7. Feel free to update any of the files when writing your code. The implementation of the `OpenGLRenderer` is currently very simple.

## Making a Live Demo
When you push changes to the `master` branch of your repository on Github, a Github workflow will run automatically which builds your code and pushes the build to a new branch `gh-pages`. The configuration file which handles this is located at `.github/workflows/build-and-deploy.yml`. If you want to modify this, you can read more about workflows [here](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions).

Once your built code is pushed to `gh-pages`, Github can automatically publish a live site. Configure that by:

  1. Open the Settings tab of your repository in Github.

  2. Scroll down to the Pages tab of the Settings (in the table on the left) and choose which branch to make the source for the deployed project. This should be the `gh-pages` branch which is automatically created after the first successful build of the `master` branch.

  3. Done! Now, any new commits on the `master` branch will be built and pushed to `gh-pages`. The project should be visible at http://username.github.io/repo-name.
 

To check if everything is on the right track:

1. Make sure the `gh-pages` branch of your repo has a files called `index.html`, `bundle.js`, and `bundle.js.map`

2. In the settings tab of the repo, under Pages, make sure it says your site is published at some url.

## Submission
1. Create a pull request to this repository with your completed code.
2. Update README.md to contain a solid description of your project with a screenshot of some visuals, and a link to your live demo.
3. Submit the link to your pull request on Canvas, and add a comment to your submission with a hyperlink to your live demo.
4. Include a link to your live site.

## Resources
- Javascript modules https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import
- Typescript https://www.typescriptlang.org/docs/home.html
- dat.gui https://workshop.chromeexperiments.com/examples/gui/
- glMatrix http://glmatrix.net/docs/
- WebGL
  - Interfaces https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API
  - Types https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Types
  - Constants https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Constants
