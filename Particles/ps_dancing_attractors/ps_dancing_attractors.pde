class Particle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  float ttl;
  PImage img;

  Particle(float x, float y, float mass, PImage img) {
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    this.mass = mass;
    ttl = 95;
    this.img = img;
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    ttl -= 1;
  }

  void display() {
    // imageMode(CENTER);
    // tint(255, ttl);
    // image(img, location.x, location.y, 60, 60);
    color c = color(255, 172, 59);
    float theta = velocity.heading() + PI/2;
    pushMatrix();
    fill(c, ttl/3);
    stroke(c, ttl/3);
    translate(location.x,location.y);
    rotate(theta);
    triangle(-2, 0, 0, -5, 2, 0);
    popMatrix();
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  boolean isExpired() {
    return ttl <= 0;
  }
}

class Attractor {
  ArrayList<Particle> attractees;
  float c;
  float mass;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float tx;
  float ty;
  int mult;

  Attractor(float c, float mass, float x, float y, float tx, float ty, int mult) {
    this.c = c;
    this.mass = mass;
    this.location = new PVector(x, y);
    velocity = new PVector(1, 0);
    acceleration = new PVector(0, 0);
    this.tx = tx;
    this.ty = ty;
    this.mult = mult;
  }

  void setLocation(float x, float y) {
    location.x = x;
    location.y = y;
  }

  void update() {
    float x = map(noise(tx), 0, 1, 0, width);
    float y = map(noise(ty), 0, 1, 0, height);

    location.x = x;
    location.y = y;
    tx += 0.01;
    ty += 0.01;
  }

  void display() {
    //ellipse(location.x, location.y, mass*20, mass*20);
    color c = color(107, 148, 158);
    fill(c);
    stroke(c);
    line(location.x, location.y, location.x + mass, location.y);
    line(location.x, location.y, location.x - mass, location.y);

    line(location.x, location.y, location.x, location.y + mass);
    line(location.x, location.y, location.x, location.y - mass);

    text("dir: " + mult, location.x + 10, location.y-10);
    text("m: " + round(mass), location.x + 10, location.y+15);
    text("c: " + this.c, location.x - 25, location.y+ mass + 15);
  }

  void attract(Particle attractee) {
    PVector gVector = PVector.sub(this.location, attractee.location);
    gVector.normalize();
    float r2 = gVector.magSq();
    gVector.mult(c*this.mass*attractee.mass/r2);
    gVector.mult(mult);
    attractee.applyForce(gVector);
  }
}

class ParticleSystem {
  ArrayList<Particle> particles;
  int particleDelta = 115;
  PVector origin;
  ArrayList<Attractor> attractors;
  PImage img;

  ParticleSystem(float x, float y, PImage img) {
    particles = new ArrayList<Particle>();
    attractors = new ArrayList<Attractor>();
    origin = new PVector(x, y);
    this.img = img;
  }

  void generateParticles() {
    for (int i=0; i<particleDelta; i++) {
      particles.add(new Particle(origin.x, origin.y, 0.1, img));
    }
  }

void attract(Particle particle) {
  for (Attractor attr : attractors) {
    attr.attract(particle);
  }
}

  void update() {
    for (int i = particles.size()-1;i>=0;i--){
      Particle particle = particles.get(i);
      attract(particle);
      particle.applyForce(new PVector(random(-0.03, 0.03), random(-0.03, 0.03)));
      particle.update();
      particle.display();
      if(particle.isExpired()){
        particles.remove(particle);
      }
    }
  }

  void attachAttractor(Attractor attractor) {
    this.attractors.add(attractor);
  }

  int getParticleCount() {
    return particles.size();
  }
}

ParticleSystem ps;
ParticleSystem ps2;
ParticleSystem ps3;
Attractor attractor;
Attractor attractor2;

boolean showAttractors = true;

void setup() {
  size(600, 500, P2D);
  blendMode(ADD);
  attractor = new Attractor(random(0.01, 0.03), random(1,50), width/2, height/2, 0, 1000, 1);
  attractor2 = new Attractor(random(0.01, 0.03), random(1,50), width/2, height/2, 2000, 3000, -1);
  PImage img = loadImage("particle1.png");
  ps = new ParticleSystem(width/2, height/2, img);
  ps.attachAttractor(attractor);
  ps.attachAttractor(attractor2);

}

void mouseClicked() {
  showAttractors = !showAttractors;
}

void draw() {
  background(0);
  ps.generateParticles();

  attractor.update();
  attractor2.update();
  ps.update();

if (showAttractors) {
  attractor.display();
  attractor2.display();
}

  textSize(14);
  fill(255);
  text("particles: " + ps.getParticleCount(), 10, 20);
}
