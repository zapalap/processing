import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class flow_field extends PApplet {

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

  public void update() {
    if (location.x >= width) {
      location.x = 0;
    }

    if (location.y >= height) {
      location.y = 0;
    }

  if (location.y <= 0) {
      location.y = height;
    }

    if (location.x <= 0) {
      location.x = width;
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

  public void display() {
    pushMatrix();
    fill(191, 97, 127);
    stroke(191, 97, 127);
    float angle = velocity.heading() + PI/2;
    translate(location.x,location.y);
    rotate(angle);
    triangle(-3, 0, 0, -18, 3, 0);
    popMatrix();
  }

  public void setLocation(float x, float y) {
    location.x = x;
    location.y = y;
  }

  public void applyForce(PVector force) {
    acceleration.add(force);
  }

  public void follow(FlowField field) {
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

  public void Init() {
    for (int x = 0; x < floor(width/resolution); ++x) {
       for (int y = 0; y < floor(height/resolution); ++y) {
        float angle = map(noise(y), 0, 1, 0, 60);
        PVector vector = PVector.fromAngle(angle);
        field[x][y] = vector;
       }
    }
  }

  public PVector lookup(PVector position) {
    int x = floor(position.x/resolution);
    int y = floor(position.y/resolution);
    x = constrain(x, 0, 19);
    y = constrain(y, 0, 19);
    PVector vector = field[x][y];
    fill(0);
    stroke(0);
    return vector;
  }

  public void render() {
    for (int x = 0; x < floor(width/resolution); ++x) {
      for (int y = 0; y < floor(height/resolution); ++y) {
        pushMatrix();
        stroke(0);
        translate(x*resolution+resolution/2, y*resolution+resolution/2);
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

public void setup() {
  
  field = new FlowField(50);
  vehicles = new ArrayList<Vehicle>();
}

public void draw() {
  background(255);
  field.render();
  for (Vehicle vehicle : vehicles) {
    vehicle.update();
    vehicle.display();  
  }
 
  if (mousePressed) {
    Vehicle v = new Vehicle(mouseX, mouseY, random(100), random(0.5f));
    v.follow(field);
    vehicles.add(v);
  }

}

  public void settings() {  size(1000, 1000, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "flow_field" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
