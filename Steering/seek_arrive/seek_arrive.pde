class Vehicle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float maxSpeed;
  float maxForce;

  Vehicle(float x, float y, float ms, float mf) {
    this.maxSpeed = ms;
    this.maxForce = mf;
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    pushMatrix();
    fill(255);
    float angle = velocity.heading() + PI/2;
    translate(location.x,location.y);
    rotate(angle);
    triangle(-3, 0, 0, -10, 3, 0);
    popMatrix();
  }

  void setLocation(float x, float y) {
    location.x = x;
    location.y = y;

  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void seek(Vehicle target) {
    PVector desired = PVector.sub(target.location, location);
    float distance = desired.mag();
    if(mousePressed) {
      desired.mult(-1);
    }
    if (distance > 100) {
      desired.setMag(maxSpeed);
    } else {
      float m = map(distance, 0, 100,0, maxSpeed);
      desired.setMag(m);
    }

    PVector steering = PVector.sub(desired, velocity);
    steering.limit(maxForce);
    applyForce(steering);
  }
}

Vehicle seeker;
Vehicle target;
ArrayList<Vehicle> seekers;


void setup() {
  size(1200, 800);
  seekers = new ArrayList<Vehicle>();

  for(int i=1;i < 3000; i++) {
        seekers.add(new Vehicle(random(width), random(height), random(1,10), random(0.1, 0.9)));
  }

  target = new Vehicle(width/2, height/2, 5.5, 0.1);
}

void draw() {
  background(255);
  textSize(36);
  fill(0);
  text("LMB to make them run...", 120, 120);
  target.setLocation(mouseX, mouseY);
  target.update();

  for (Vehicle seeker : seekers) {
    seeker.seek(target);
    seeker.update();
    seeker.display();
  }



}
