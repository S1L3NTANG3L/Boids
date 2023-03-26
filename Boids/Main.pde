ArrayList<Boid> boids;
ArrayList<Avoid> avoids;

float globalScale = .91;
float eraseRadius = 20;
String tool = "boids";

// boid control
float maxSpeed;
float friendRadius;
float crowdRadius;
float avoidRadius;
float coheseRadius;

boolean option_friend = true;
boolean option_crowd = true;
boolean option_avoid = true;
boolean option_noise = true;
boolean option_cohese = true;

// gui 
int messageTimer = 0;
String messageText = "";

void setup () {
  size(1024, 576);
  textSize(16);
  recalculateConstants();
  boids = new ArrayList<Boid>();
  avoids = new ArrayList<Avoid>();
  setupSquare();
}

void recalculateConstants () {
  maxSpeed = 2.1 * globalScale;
  friendRadius = 60 * globalScale;
  crowdRadius = (friendRadius / 1.3);
  avoidRadius = 90 * globalScale;
  coheseRadius = friendRadius;
}

void setupSquare() {
  avoids = new ArrayList<Avoid>();
   for (int x = 0; x < width; x+= 20) {
    avoids.add(new Avoid(x, 10));
    avoids.add(new Avoid(x, height - 10));
  }
    for (int y = 0; y < height; y+= 20) {
    avoids.add(new Avoid(10, y));
    avoids.add(new Avoid(width - 10, y));
  } 
}

void draw () {
  noStroke();
  colorMode(HSB);
  fill(0, 100);
  rect(0, 0, width, height);
  if (tool == "erase") {
    noFill();
    stroke(0, 100, 260);
    rect(mouseX - eraseRadius, mouseY - eraseRadius, eraseRadius * 2, eraseRadius *2);
    if (mousePressed && (mouseButton == CENTER)) {
      erase();
    }
  } else if (tool == "avoids") {
    noStroke();
    fill(0, 200, 200);
    ellipse(mouseX, mouseY, 15, 15);
  }
  for (int i = 0; i <boids.size(); i++) {
    Boid current = boids.get(i);
    current.go();
    current.draw();
  }
  for (int i = 0; i <avoids.size(); i++) {
    Avoid current = avoids.get(i);
    current.go();
    current.draw();
  }
  if (messageTimer > 0) {
    messageTimer -= 1; 
  }
  drawGUI();
}

void drawGUI() {
   if(messageTimer > 0) {
     fill((min(30, messageTimer) / 30.0) * 255.0);
    text(messageText, 10, height - 20); 
   }
}

String s(int count) {
  return (count != 1) ? "s" : "";
}

String on(boolean in) {
  return in ? "on" : "off"; 
}

void mousePressed () {
  if (mousePressed && (mouseButton == LEFT)) {
    boids.add(new Boid(mouseX, mouseY));
    message(boids.size() + " Total Boid" + s(boids.size()));
  } else if (mousePressed && (mouseButton == RIGHT)) {
    avoids.add(new Avoid(mouseX, mouseY));
  } else if (mousePressed && (mouseButton == CENTER)) {
    tool = "erase";
  }
}

void erase () {
  for (int i = boids.size()-1; i > -1; i--) {
    Boid b = boids.get(i);
    if (abs(b.pos.x - mouseX) < eraseRadius && abs(b.pos.y - mouseY) < eraseRadius) {
      boids.remove(i);
    }
  }
  for (int i = avoids.size()-1; i > -1; i--) {
    Avoid b = avoids.get(i);
    if (abs(b.pos.x - mouseX) < eraseRadius && abs(b.pos.y - mouseY) < eraseRadius) {
      avoids.remove(i);
    }
  }
}

void drawText (String s, float x, float y) {
  fill(0);
  text(s, x, y);
  fill(200);
  text(s, x-1, y-1);
}

void message (String in) {
   messageText = in;
   messageTimer = (int) frameRate * 3;
}
