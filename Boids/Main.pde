ArrayList<Boid> boids;              // List of all Boid objects
ArrayList<Avoid> avoids;            // List of all Avoid objects

float globalScale = .91;            // Global scale for size adjustments
float eraseRadius = 20;             // Radius for erasing Boids and Avoids
String tool = "boids";              // Default tool selection

// Boid behavior control options
float maxSpeed;                     // Maximum speed of Boids
float friendRadius;                 // Radius for Boids to consider others as friends
float crowdRadius;                  // Radius at which Boids will consider it crowded
float avoidRadius;                  // Radius for Boids to avoid obstacles
float coheseRadius;                 // Radius for Boids to cohere with others

// Toggle options for different Boid behaviors
boolean option_friend = true;       // Option to enable friend behavior
boolean option_crowd = true;        // Option to enable crowding behavior
boolean option_avoid = true;        // Option to enable avoidance behavior
boolean option_noise = true;        // Option to add random noise to Boid movement
boolean option_cohese = true;       // Option to enable cohesion behavior

// GUI-related variables
int messageTimer = 0;               // Timer to display messages for a fixed time
String messageText = "";            // Text to display in the GUI

void setup() {
  size(1600, 1000);                  // Set the canvas size
  textSize(16);                     // Set the text size for GUI messages
  recalculateConstants();           // Calculate initial Boid parameters based on global scale
  boids = new ArrayList<Boid>();    // Initialize the list to hold Boids
  avoids = new ArrayList<Avoid>();  // Initialize the list to hold Avoid objects
  setupSquare();                    // Setup square boundary of Avoid objects around the canvas
  setupAvoids(250, 15);              // Add 50 randomly placed Avoid objects with a minimum distance of 30
}

void draw() {
  noStroke();
  colorMode(HSB);
  fill(0, 100);
  rect(0, 0, width, height);        // Draw the background

  // Draw FPS counter in top-left corner
  drawFPS();
  
  // Draw all the Boids and Avoids
  for (int i = 0; i < boids.size(); i++) {
    Boid current = boids.get(i);
    current.go();                   // Update Boid's behavior and movement
    current.draw();                 // Draw the Boid on the canvas
  }
  for (int i = 0; i < avoids.size(); i++) {
    Avoid current = avoids.get(i);
    current.go();                   // Update Avoid's behavior
    current.draw();                 // Draw the Avoid object
  }

  // Draw the GUI elements including the toggle buttons and reset button
  drawToggleButtons();

  // Display any messages if messageTimer > 0
  if (messageTimer > 0) {
    messageTimer -= 1;
  }
  drawGUI();                        // Draw GUI messages
}

void setupAvoids(int count, float minDistance) {
  int retries = 1000;  // Maximum number of retries for each Avoid object placement

  for (int i = 0; i < count; i++) {
    PVector newPos;
    boolean validPosition;

    // Retry finding a valid position until the minimum distance condition is met
    do {
      validPosition = true;
      float randX = random(width);   // Generate a random x-coordinate within the canvas width
      float randY = random(height);  // Generate a random y-coordinate within the canvas height
      newPos = new PVector(randX, randY);

      // Check the distance between the new position and all existing Avoid objects
      for (Avoid existingAvoid : avoids) {
        if (PVector.dist(newPos, existingAvoid.pos) < minDistance) {
          validPosition = false;    // Set flag to false if too close to an existing Avoid
          break;                    // Exit the loop and retry with a new position
        }
      }

      retries--;                     // Decrease retries count to prevent infinite loop
      if (retries <= 0) break;       // Exit loop if maximum retries are reached

    } while (!validPosition);        // Repeat until a valid position is found

    // Add the new Avoid object to the list if a valid position was found
    if (retries > 0) {
      avoids.add(new Avoid(newPos.x, newPos.y));
    }
  }
}

void drawFPS() {
  String fps = "FPS: " + int(frameRate);      // Create the FPS text
  fill(0);                                   // Set fill to black for the background rectangle
  rect(10, 10, textWidth(fps) + 10, 25);      // Draw a rectangle behind the text
  
  fill(255);                                 // Set fill color to white for the text
  text(fps, 50, 30);                         // Draw the FPS text slightly offset inside the rectangle
}

// Draw toggle buttons and reset button at the bottom center
void drawToggleButtons() {
  String[] labels = {"Friend", "Crowd", "Avoid", "Noise", "Cohesion", "Reset"};
  boolean[] options = {option_friend, option_crowd, option_avoid, option_noise, option_cohese, false}; // 'Reset' button has no state

  int buttonWidth = 100;            // Width of each button
  int buttonHeight = 30;            // Height of each button
  int spacing = 10;                 // Space between buttons
  int totalWidth = labels.length * buttonWidth + (labels.length - 1) * spacing; // Total width of the button layout
  int startX = (width - totalWidth) / 2;  // Calculate starting X position for center alignment
  int yPosition = height - 50;      // Set Y position for buttons (bottom of canvas)

  for (int i = 0; i < labels.length; i++) {
    int x = startX + i * (buttonWidth + spacing); // Calculate X position for each button

    if (i < 5) {                     // Draw toggle buttons with colored backgrounds
      // Draw button background based on the option's state
      if (options[i]) {
        fill(0, 200, 0);              // Green background for enabled options
      } else {
        fill(200, 0, 0);              // Red background for disabled options
      }
      rect(x, yPosition, buttonWidth, buttonHeight); // Draw button rectangle
    }

    fill(255);                        // Set fill color for text
    textAlign(CENTER, CENTER);        // Center the text within the button
    text(labels[i] + (i < 5 ? ": " + (options[i] ? "On" : "Off") : ""), x + buttonWidth / 2, yPosition + buttonHeight / 2);
  }
}

// Handle mouse clicks to toggle the button states or perform the reset action
void mousePressed() {
  if (mousePressed && (mouseButton == LEFT)) {
    // Check if the click is on a toggle button before adding a new Boid
    if (!toggleButton(mouseX, mouseY)) {
      boids.add(new Boid(mouseX, mouseY));    // Add a Boid with left mouse button if not clicking a button
      message(boids.size() + " Total Boid" + s(boids.size())); // Display Boid count message
    }
  } else if (mousePressed && (mouseButton == RIGHT)) {
    avoids.add(new Avoid(mouseX, mouseY));    // Add an Avoid object with right mouse button
  } else if (mousePressed && (mouseButton == CENTER)) {
    tool = "erase";                          // Switch tool to erase with center mouse button
  }
}

// Function to toggle buttons or handle the reset button click
boolean toggleButton(int mx, int my) {
  String[] labels = {"Friend", "Crowd", "Avoid", "Noise", "Cohesion", "Reset"};
  boolean[] options = {option_friend, option_crowd, option_avoid, option_noise, option_cohese};
  int buttonWidth = 100;                  // Width of each button
  int buttonHeight = 30;                  // Height of each button
  int spacing = 10;                       // Space between buttons
  int totalWidth = labels.length * buttonWidth + (labels.length - 1) * spacing; // Total width of the button layout
  int startX = (width - totalWidth) / 2;  // Calculate starting X position for center alignment
  int yPosition = height - 50;            // Set Y position for buttons (bottom of canvas)

  for (int i = 0; i < labels.length; i++) {
    int x = startX + i * (buttonWidth + spacing); // Calculate X position for each button
    
    // Check if the mouse click is within the bounds of the button
    if (mx > x && mx < x + buttonWidth && my > yPosition && my < yPosition + buttonHeight) {
      if (i == 5) {                       // If the 'Reset' button is clicked
        resetSimulation();                 // Call reset function
        return true;                       // Return true indicating that a button was clicked
      } else {                             // Toggle the corresponding behavior option
        if (i == 0) option_friend = !option_friend;
        if (i == 1) option_crowd = !option_crowd;
        if (i == 2) option_avoid = !option_avoid;
        if (i == 3) option_noise = !option_noise;
        if (i == 4) option_cohese = !option_cohese;
        
        // Display a message indicating the new state of the option
        message(labels[i] + " Behavior: " + (options[i] ? "Off" : "On"));
        return true;                      // Return true indicating that a button was clicked
      }
    }
  }
  return false;                           // Return false if no button was clicked
}

// Function to reset the simulation by clearing all Boids and Avoids
void resetSimulation() {
  boids.clear();                          // Remove all Boid objects
  avoids.clear();                         // Remove all Avoid objects
  message("Simulation Reset");            // Display reset message
  recalculateConstants();           // Calculate initial Boid parameters based on global scale
  setupSquare();                    // Setup square boundary of Avoid objects around the canvas
  setupAvoids(250, 15);  
}

// Function to display GUI messages
void drawGUI() {
  if (messageTimer > 0) {
    fill((min(30, messageTimer) / 30.0) * 255.0);
    text(messageText, 80, height - 35);
  }
}

// Utility function to determine singular/plural text based on count
String s(int count) {
  return (count != 1) ? "s" : "";
}

// Utility function to display a message on the GUI for a fixed duration
void message(String in) {
  messageText = in;
  messageTimer = (int) frameRate * 3;
}

// Function to setup a square boundary of Avoid objects around the canvas edges
void setupSquare() {
  float diameter = 15;                    // Diameter of each Avoid object
  avoids = new ArrayList<Avoid>();        // Create a new list for Avoid objects

  // Place Avoids along the top and bottom edges
  for (float x = diameter / 2; x < width; x += diameter) {
    avoids.add(new Avoid(x, diameter / 2));                 // Top edge
    avoids.add(new Avoid(x, height - diameter / 2));        // Bottom edge
  }

  // Place Avoids along the left and right edges
  for (float y = diameter / 2; y < height; y += diameter) {
    avoids.add(new Avoid(diameter / 2, y));                 // Left edge
    avoids.add(new Avoid(width - diameter / 2, y));         // Right edge
  }
}

// Function to recalculate constants based on globalScale value
void recalculateConstants() {
  maxSpeed = 2.1 * globalScale;           // Adjust maximum speed of Boids
  friendRadius = 60 * globalScale;        // Adjust radius for friend detection
  crowdRadius = (friendRadius / 1.3);     // Adjust radius for crowd detection
  avoidRadius = 90 * globalScale;         // Adjust radius for obstacle avoidance
  coheseRadius = friendRadius;            // Set cohesion radius equal to friend radius
}
