class Boid {
  // Main fields
  PVector pos;                // Position of the Boid
  PVector move;               // Movement vector of the Boid
  float shade;                // Color shade of the Boid
  ArrayList<Boid> friends;    // List of nearby Boids considered as friends

  // Timer fields
  int thinkTimer = 0;         // Timer for controlling how often the Boid recalculates its behavior

  // Constructor to initialize a Boid with its position
  Boid(float xx, float yy) {
    move = new PVector(0, 0);                 // Initialize movement vector
    pos = new PVector(xx, yy);                // Set the initial position
    thinkTimer = int(random(10));             // Randomize the initial value of thinkTimer
    shade = random(255);                      // Randomize color shade of the Boid
    friends = new ArrayList<Boid>();          // Initialize the list of friends
  }

  // Method to update Boid's position and behavior
  void go() {
    increment();                              // Update the timers
    wrap();                                   // Wrap position if Boid goes out of screen bounds

    if (thinkTimer == 0) {                    // Update friends list every few frames
      getFriends();                           // Find nearby Boids and update friends
    }
    flock();                                  // Apply flocking behavior to calculate movement
    pos.add(move);                            // Update position based on movement
  }

  // Method to apply flocking behavior to the Boid
  void flock() {
    PVector allign = getAverageDir();         // Get the average direction of nearby friends
    PVector avoidDir = getAvoidDir();         // Get the direction to avoid crowded areas
    PVector avoidObjects = getAvoidAvoids();  // Get the direction to avoid obstacles
    PVector noise = new PVector(random(2) - 1, random(2) - 1); // Add random noise to the movement
    PVector cohese = getCohesion();           // Get the direction to cohere with other Boids

    // Modify each behavior vector based on toggled options
    allign.mult(1);
    if (!option_friend) allign.mult(0);

    avoidDir.mult(1);
    if (!option_crowd) avoidDir.mult(0);

    avoidObjects.mult(3);
    if (!option_avoid) avoidObjects.mult(0);

    noise.mult(0.1);
    if (!option_noise) noise.mult(0);

    cohese.mult(1);
    if (!option_cohese) cohese.mult(0);

    // Update movement vector based on combined behavior vectors
    move.add(allign);
    move.add(avoidDir);
    move.add(avoidObjects);
    move.add(noise);
    move.add(cohese);

    // Limit movement speed
    move.limit(maxSpeed);

    // Update Boid's color shade based on average color of friends
    shade += getAverageColor() * 0.03;
    shade += (random(2) - 1);
    shade = (shade + 255) % 255;
  }

  // Method to find nearby Boids and update friends list
  void getFriends() {
    ArrayList<Boid> nearby = new ArrayList<Boid>();
    for (int i = 0; i < boids.size(); i++) {
      Boid test = boids.get(i);
      if (test == this) continue;             // Skip itself
      if (abs(test.pos.x - this.pos.x) < friendRadius &&
          abs(test.pos.y - this.pos.y) < friendRadius) {
        nearby.add(test);                     // Add to friends list if within friend radius
      }
    }
    friends = nearby;                         // Update friends list
  }

  // Method to get the average color difference of nearby friends
// Method to get the average color difference of nearby friends within the same group
float getAverageColor() {
  float total = 0;         // Sum of color differences
  int count = 0;           // Number of valid friends considered

  for (Boid other : friends) {
    float colorDifference = abs(other.shade - shade);  // Calculate the absolute color difference
    // Check if the Boid's color is within a reasonable range (e.g., +/- 30 units)
    if (colorDifference <= 30) {
      total += other.shade;   // Add the friend's shade to the total
      count++;                // Increment the count of valid friends
    }
  }

  // If there are no valid friends in the group, return the current shade
  if (count == 0) return shade;

  return total / count;       // Return the average shade of the group
}

  // Method to calculate the average direction of movement of nearby friends
  PVector getAverageDir() {
    PVector sum = new PVector(0, 0);
    int count = 0;

    for (Boid other : friends) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < friendRadius)) {
        PVector copy = other.move.copy();
        copy.normalize();
        copy.div(d);          // Weight direction by distance
        sum.add(copy);
        count++;
      }
    }
    return sum;               // Return the sum of direction vectors
  }

  // Method to calculate the direction to avoid crowding
  PVector getAvoidDir() {
    PVector steer = new PVector(0, 0);
    int count = 0;

    for (Boid other : friends) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < crowdRadius)) {
        PVector diff = PVector.sub(pos, other.pos); // Calculate vector away from friend
        diff.normalize();
        diff.div(d);            // Weight by distance
        steer.add(diff);
        count++;
      }
    }
    return steer;
  }

  // Method to calculate the direction to avoid obstacles
  PVector getAvoidAvoids() {
    PVector steer = new PVector(0, 0);
    int count = 0;

    for (Avoid other : avoids) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < avoidRadius)) {
        PVector diff = PVector.sub(pos, other.pos); // Calculate vector away from obstacle
        diff.normalize();
        diff.div(d);            // Weight by distance
        steer.add(diff);
        count++;
      }
    }
    return steer;
  }

  // Method to calculate cohesion, i.e., moving towards the center of friends
  PVector getCohesion() {
    PVector sum = new PVector(0, 0);    // Accumulate all locations
    int count = 0;
    for (Boid other : friends) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < coheseRadius)) {
        sum.add(other.pos);             // Add friend's position to the sum
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);                   // Calculate average position
      PVector desired = PVector.sub(sum, pos);
      return desired.setMag(0.05);      // Return vector pointing towards average position
    } else {
      return new PVector(0, 0);         // Return zero vector if no friends found
    }
  }

  // Method to draw the Boid on the canvas
  void draw() {
    noStroke();
    fill(shade, 90, 200);
    pushMatrix();
    translate(pos.x, pos.y);            // Move the origin to the Boid's position
    rotate(move.heading());             // Rotate to align with movement direction
    beginShape();                       // Draw the Boid as a triangle
    vertex(15 * globalScale, 0);
    vertex(-7 * globalScale, 7 * globalScale);
    vertex(-7 * globalScale, -7 * globalScale);
    endShape(CLOSE);
    popMatrix();
  }

  // Method to increment timers
  void increment() {
    thinkTimer = (thinkTimer + 1) % 5;  // Increment thinkTimer with wrap-around at 5
  }

  // Method to wrap the Boid's position when it goes beyond screen bounds
  void wrap() {
    pos.x = (pos.x + width) % width;    // Wrap x-coordinate within screen width
    pos.y = (pos.y + height) % height;  // Wrap y-coordinate within screen height
  }
}
