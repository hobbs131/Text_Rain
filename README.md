# Text Rain

This project involves a reimagination of the Text Rain exhibit by Camille Utterback and Romy Achituv in the Processing language. Various design decisions and features of the program are described below.

# Design Decisions
- Algorithm for picking characters to display
  - The array of random letters was populated by selecting a random index from a quote by John Lennon. Code can be seen below. Population took place during setup().
  ``` java
  letters[i] = new Letter(quoteCharacters[int(random(quoteCharacters.length))]);
  ```
 - Letter class
    - Inline letter class which contains methods/attributes relevant to making the text rain. i.e. descend(), scan(), and display()
  
- Other relevant methods
  - flip() - flips the inputImage across the y-axis
  - thresholdPixel() - turns a pixel black or white based on the green channel of the input pixel

- User interaction
  - Dynamic thresholding
    - users can change the threshold value by either incrementing it using the up arrow or decrementing using the down arrow.
  - Debug mode
    - users can enter debug mode, which turns the background to pure white and the foreground to pure black. This is activated/deactivated using the space bar

