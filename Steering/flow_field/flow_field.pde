class Vehicle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float maxSpeed;
  float maxForce;
  FlowField field;

  Vehicle(float x, float y, float ms, float mf) {
    this.maxSpeed = ms;
    this.maxForce = mf;
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  void update() {
    if (location.x >= width) {
      location.x = width;
    }

    if (location.y >= height) {
      location.y = height;
    }

  if (location.y <= 0) {
      location.y = 0;
    }

    if (location.x <= 0) {
      location.x = 0;
    }

    PVector desired = field.lookup(this.location).copy();
    desired.setMag(maxSpeed);
    PVector steering = PVector.sub(desired, velocity);
    steering.limit(maxForce);
    applyForce(steering);
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    pushMatrix();
    fill(191, 97, 127);
    stroke(191, 97, 127);
    float angle = velocity.heading() + PI/2;
    translate(location.x,location.y);
    rotate(angle);
    triangle(-3, 0, 0, -18, 3, 0);
    popMatrix();
  }

  void setLocation(float x, float y) {
    location.x = x;
    location.y = y;
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void follow(FlowField field) {
   this.field = field;
  }
}


class FlowField {
  PVector[][] field;
  int resolution;
  float ta = 0;

  FlowField(int resolution) {
    this.resolution = resolution;
    field = new PVector[floor(width/resolution)][floor(height/resolution)];
    Init();
  }

  void Init() {
    for (int x = 0; x < floor(width/resolution); ++x) {
       for (int y = 0; y < floor(height/resolution); ++y) {
        float angle = map(noise(y), 0, 1, 0, 120);
        PVector vector = PVector.fromAngle(angle);
        field[x][y] = vector;
       }
    }
  }

  PVector lookup(PVector position) {
    int x = constrain(floor(position.x/resolution), 0, floor(width/resolution)-1);
    int y = constrain(floor(position.y/resolution), 0, floor(height/resolution)-1);
    PVector vector = field[x][y];
    fill(0);
    stroke(0);
    return vector;
  }

  void render() {
    for (int x = 0; x < floor(width/resolution); ++x) {
      for (int y = 0; y < floor(height/resolution); ++y) {
        pushMatrix();
        stroke(0);
        translate(x*resolution+resolution/2, y*resolution+resolution/2);
        fill(255);
        rect(-resolution/2, -resolution/2, resolution, resolution);
        PVector vector = field[x][y].copy();
        rotate(vector.heading());
        vector.setMag(resolution/2);
        line(0, 0, vector.x, vector.y);
        translate(vector.x, vector.y);
        rotate(vector.heading()-PI/2);
        triangle(-1, 0, 0, 5, 1, 0);
        popMatrix();
      }
    }
  }
}

FlowField field;
ArrayList<Vehicle> vehicles;

void setup() {
  size(1000, 1000, P2D);
  field = new FlowField(70);
  vehicles = new ArrayList<Vehicle>();
}

void draw() {
  background(255);
  field.render();
  for (Vehicle vehicle : vehicles) {
    vehicle.update();
    vehicle.display();
  }

  if (mousePressed) {
    Vehicle v = new Vehicle(mouseX, mouseY, random(100), random(0.3));
    v.follow(field);
    vehicles.add(v);
  }

}