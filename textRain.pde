/*
 * CSci-4611 Assignment #1 Text Rain
 */


/* Note: if Processing's video library does not support your particular combination of webcam and
   operating system, then the Sketch may hang in the setup() routine when the list of available
   image capture devices is requestd with "Capture.list()".  If this happens, you can skip all of
   the camera initilization code and just run in movie mode by setting the following global 
   variable to true. 
 */
boolean forceMovieMode = false;

// Global vars used to access video frames from either a live camera or a prerecorded movie file
import processing.video.*;
String[] cameraModes;
Capture cameraDevice;
Movie inputMovie;
boolean initialized = false;
// Quote by John Lennon: "Life is what happens when you're making other plans"
char[] quoteCharacters = {'l','i','f','e','i','s','w','h', 'a', 't', 'h','a','p','p','e','n', 's','w','h','e', 'n', 'y', 'o'
                        ,'u','r','e','b','u','s','y','m', 'a', 'k', 'i', 'n', 'g', 'o','t','h','e','r','p','l','a','n','s'};
// Chosen font
PFont font;

// Will be populated randomly with characters from quoteCharacters
Letter[] letters;

// Both modes of input (live camera and movie) will update this same variable with the lastest
// pixel data each frame.  Use this variable to access the new pixel data each frame!
PImage inputImage;

// inputImage flipped
PImage flippedImage;

// Threshold which can be updated with down and up arrows
int threshold = 128;

// Variable which indicates whether or not we are in debug mode
boolean debug = false;

// Letter class
class Letter {
  // Coordinates
  int xPos;
  int yPos;
  
  // Speed of falling
  float dy;
  float dyTemp;
  
  // Letter displayed
  char letter;
  
  // Color of the letter
  color c;
  
  // Color of the pixel four pixels above (used to determine if letter is touching dark object)
  color above;
  
  // Constructor
  Letter(char quoteCharacter){
    xPos = int(random(width));
    yPos = int(random(-25, -10));
    dy = int(random(2,5));
    dyTemp = dy;
    c = 255;
    letter = quoteCharacter;
  }
  
  // Make letter fall
  void descend() {
    // Reset letter if it goes off screen
    if (yPos >= height) {
      xPos = int(random(width));
      yPos = int(random(-25, -10));;
      dy = int(random(2,5));
    }
    yPos+= dy;
  }
  
  // Put letter on screen
  void display() {
    text(letter, xPos, yPos);
  }
  // Check to see if letter is falling into a dark object
  void scan() {
    flippedImage.loadPixels();
    
    // Determines index of given pixel in a 1D array
    int index1D = int(xPos + yPos * flippedImage.width);
    if (index1D > 0 && index1D <= 921600) {
      c = thresholdPixel(flippedImage.pixels[index1D - 1]);
      // 1280 * 4 + 1 = 5121 (four pixels above)
      if (index1D > 5121) {
        above = thresholdPixel(flippedImage.pixels[index1D - 5121]);
      }
    }
    if (c == 0 && index1D > 0) {
      // If above pixel is dark, then move the text above the pixel
      if (above == 0) {
        dy = -4;
        // Otherwise stop movement
      } else {
        dy = 0;
      }
      // Dark object has moved, restore movement
    } else {
      dy = dyTemp;
      }
  inputImage.updatePixels();
  }
}

// Reflects the image across the y-axis
PImage flip(PImage inputImage) {
  PImage flippedImage = inputImage.copy();
  
  for (int i = 0; i < inputImage.width; ++i){
    for (int j = 0; j < inputImage.height; ++j) {
      int temp = ((inputImage.width - i) - 1) + inputImage.width * j;
      int index = i + inputImage.width * j;
      flippedImage.pixels[index] = inputImage.pixels[temp];
    }
  }
  return flippedImage;
}

// Turns pixel black or white based on green channel of inputPixel.
color thresholdPixel(color inputPixel) {
  float grayscale = green(inputPixel);
  if (grayscale > threshold) {
    inputPixel = 255;
  }
  else {
    inputPixel = 0;
  }
  return inputPixel;
}


// Called automatically by Processing, once when the program starts up
void setup() {
  size(1280, 720);  
  inputImage = createImage(width, height, RGB);
  font = loadFont("LetterGothicStd-32.vlw");
  textFont(font,16);
  fill(0,128,0);
  
  if (!forceMovieMode) {
    println("Querying avaialble camera modes.");
    cameraModes = Capture.list();
    println("Found " + cameraModes.length + " camera modes.");
    for (int i=0; i<cameraModes.length; i++) {
      println(" " + i + ". " + cameraModes[i]); 
    }
    // if no cameras were detected, then run in offline mode
    if (cameraModes.length == 0) {
      println("Starting movie mode automatically since no cameras were detected.");
      initializeMovieMode(); 
    }
    else {
      println("Press a number key in the Processing window to select the desired camera mode.");
    }
  }
  // Populates the letters array with random letters from quoteCharacters
  letters = new Letter[75];
  for (int i = 0; i < letters.length; ++i){
    letters[i] = new Letter(quoteCharacters[int(random(quoteCharacters.length))]);
  }
}

// Called automatically by Processing, once per frame
void draw() {
  // start each frame by clearing the screen
  background(0);
    
  if (!initialized) {
    // IF NOT INITIALIZED, DRAW THE INPUT SELECTION MENU
    drawMenuScreen();      
  }
  else {
    // IF WE REACH THIS POINT, WE'RE PAST THE MENU AND THE INPUT MODE HAS BEEN INITIALIZED


    // GET THE NEXT FRAME OF INPUT DATA FROM LIVE CAMERA OR MOVIE  
    if ((cameraDevice != null) && (cameraDevice.available())) {
      // Get image data from cameara and copy it over to the inputImage variable
      cameraDevice.read();
      inputImage.copy(cameraDevice, 0,0,cameraDevice.width,cameraDevice.height, 0,0,inputImage.width,inputImage.height);
    }
    else if ((inputMovie != null) && (inputMovie.available())) {
      // Get image data from the movie file and copy it over to the inputImage variable
      inputMovie.read();
      inputImage.copy(inputMovie, 0,0,inputMovie.width,inputMovie.height, 0,0,inputImage.width,inputImage.height);
    }


    // DRAW THE INPUTIMAGE ACROSS THE ENTIRE SCREEN
    // Note, this is like clearing the screen with an image.  It will cover up anything drawn before this point.
    // So, draw your text rain after this!
    
    // Flip the image and display in grayscale
    flippedImage = flip(inputImage);
    flippedImage.filter(GRAY);
    set(0, 0, flippedImage);
    
    // Render the image in binary. Foreground made pure black, background made pure white
    if (debug) {
      for (int i = 0; i < flippedImage.pixels.length; ++i){
        flippedImage.pixels[i] = color(thresholdPixel(flippedImage.pixels[i]));
      }
      set(0, 0, flippedImage);
    }


    // DRAW THE TEXT RAIN, ETC.
    // TODO: Much of your implementation code should go here.  At this point, the latest pixel data from the
    // live camera or movie file will have been copied over to the inputImage variable.  So, if you access
    // the pixel data from the inputImage variable, your code should always work, no matter which mode you run in.
    
    for (int i = 0; i < letters.length; i++) {
      letters[i].descend();
      letters[i].display();
      letters[i].scan();
    } 
  }
}


// Called automatically by Processing once per frame
void keyPressed() {
  if (!initialized) {
    // CHECK FOR A NUMBER KEY PRESS ON THE MENU SCREEN    
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        initializeMovieMode();
      }
      else if ((input >= 1) && (input <= 9)) {
        initializeLiveCameraMode(input);
      }
    }
  }
  else {
    // CHECK FOR KEYPRESSES DURING NORMAL OPERATION
    // TODO: Fill in your code to handle keypresses here..
    if (key == CODED) {
      if (keyCode == UP) {
        // up arrow key pressed
        // Increment threshold
        if (threshold >= 255) {
          threshold = 255;
        } else {
          threshold++;
        }
        println("Threshold updated to: " + threshold);
      }
      else if (keyCode == DOWN) {
        // down arrow key pressed
        // Decrement threshold
        if (threshold <= 0) {
          threshold = 0;
        } else {
          threshold--;
        }
        println("Threshold updated to: " + threshold);
      }
    }
    else if (key == ' ') {
      // spacebar pressed
      // Put into debug mode
      debug = !debug;
      
      if (debug) {
        println("Activated debug mode");
      } else {
        println("Deactivated debug mode");
      }
    } 
  }
}



// Loads a movie from a file to simulate camera input.
void initializeMovieMode() {
  String movieFile = "TextRainInput.mov";
  println("Simulating camera input using movie file: " + movieFile);
  inputMovie = new Movie(this, movieFile);
  inputMovie.loop();
  initialized = true;
}


// Starts up a webcam to use for input.
void initializeLiveCameraMode(int cameraMode) {
  println("Activating camera mode #" + cameraMode + ": " + cameraModes[cameraMode]);
  cameraDevice = new Capture(this, cameraModes[cameraMode-1]);
  cameraDevice.start();
  initialized = true;
}


// Draws a quick text-based menu to the screen
void drawMenuScreen() {
  int y=10;
  text("Press a number key to select an input mode", 20, y);
  y += 40;
  text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
  y += 40; 
  for (int i = 0; i < min(9,cameraModes.length); i++) {
    text(i+1 + ": " + cameraModes[i], 20, y);
    y += 40;
  }  
}
