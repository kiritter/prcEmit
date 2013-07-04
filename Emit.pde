final int FRAME_NUM_FIRST = 30 * 5;
final int FRAME_NUM_EMIT = 30 * 15;

final int NUM_SMALL_PARTICLES = 10;
final int NUM_MEDIUM_PARTICLES = 1250;

final int RADIUS_BLACKBALL = 80;

PVector center;
ArrayList<Life> smallParticles;
ArrayList<Life> mediumParticles;

//--------------------------------------------------
void setup(){
  initWindow();
  initObjects();
}
void initWindow() {
  size(640, 480);
  smooth();
  frameRate(30);
}
void initObjects() {
  center = new PVector(width/2, height/2);
  smallParticles = new ArrayList<Life>();
  mediumParticles = new ArrayList<Life>();
}

//--------------------------------------------------
void draw(){
  background(0);

  addSmallParticles();

  if (frameCount == FRAME_NUM_FIRST || (frameCount - FRAME_NUM_FIRST) % FRAME_NUM_EMIT == 0) {
    addMediumParticles();
  }
  if (frameCount > FRAME_NUM_FIRST && (frameCount - FRAME_NUM_FIRST) % (FRAME_NUM_EMIT + 20) == 0) {
    addMediumParticles();
  }

  drawSmallParticles();
  drawMediumParticles();
  drawBlackBall();
}

void keyPressed() {
  if (key == 'r') {
    saveFrame("output/frame-####.png");
  }
}

//--------------------------------------------------
void addSmallParticles() {
  float radian;
  PVector position, velocity;
  color c;
  float life, lifedelta, lifeborder;
  
  for (int i = 0; i < NUM_SMALL_PARTICLES; i++) {
    radian = random(0, TWO_PI);
    position = new PVector(center.x + cos(radian) * RADIUS_BLACKBALL, center.y + sin(radian) * RADIUS_BLACKBALL);
    velocity = new PVector(cos(radian) * 0.3, sin(radian) * 0.3);
    c = color(random(0, 255), random(0, 255), random(0, 255));
    life = random(15, 100);
    lifedelta = random(0.5, 1.5);
    lifeborder = 999;
    smallParticles.add(new Particle(Particle.TYPE_SMALL, position, velocity, c, life, lifedelta, lifeborder));
  }
}
void addMediumParticles() {
  float radian;
  PVector position, velocity;
  color c;
  float life, lifedelta, lifeborder;

  float emitcenterradian = random(0, TWO_PI);
  PVector emitcenter = new PVector(center.x + cos(emitcenterradian) * RADIUS_BLACKBALL, center.y + sin(emitcenterradian) * RADIUS_BLACKBALL);

  for (int i = 0; i < NUM_MEDIUM_PARTICLES; i++) {
    radian = random(emitcenterradian - PI + QUARTER_PI, emitcenterradian + PI - QUARTER_PI);
    position = new PVector(emitcenter.x + cos(radian), emitcenter.y + sin(radian));
    velocity = new PVector(cos(radian) * random(0.3, 3), sin(radian) * random(0.3, 3));
    c = color(random(0, 255), random(0, 255), random(0, 255));
    life = random(150, 300);
    lifedelta = random(0.5, 1.5);
    lifeborder = 50;
    mediumParticles.add(new Particle(Particle.TYPE_MEDIUM, position, velocity, c, life, lifedelta, lifeborder));
  }
}

//--------------------------------------------------
void drawSmallParticles() {
  drawLives(smallParticles);
}
void drawMediumParticles() {
  drawLives(mediumParticles);
}
void drawLives(ArrayList<Life> lives) {
  Life life;
  int len = lives.size() - 1;
  for (int i = len; i >= 0; i--) {
    life = lives.get(i);
    if (life.isDead()) {
      lives.remove(i);
    }else{
      life.run();
    }
  }
}
void drawBlackBall() {
  noStroke();
  fill(0);
  ellipse(center.x, center.y, RADIUS_BLACKBALL * 2, RADIUS_BLACKBALL * 2);
}

//--------------------------------------------------
abstract class Life {
  float life;
  float lifedelta;

  final void run() {
    updateLife();
    update();
    display();
  }
  final void updateLife() {
    life -= lifedelta;
  }
  abstract void update();
  abstract void display();
  final boolean isDead() {
    if (life <= 0) {
      return true;
    } else {
      return false;
    }
  }
}

//--------------------------------------------------
class Particle extends Life {
  static final int TYPE_SMALL = 1;
  static final int TYPE_MEDIUM = 2;
  int type;
  float lifeborder;
  PVector position;
  PVector velocity;
  color c;
  final int PIXEL_BORDER = 3;

  Particle(int type, PVector position, PVector velocity, color c, float life, float lifedelta, float lifeborder) {
    this.type = type;
    this.life = life;
    this.lifedelta = lifedelta;
    this.lifeborder = lifeborder;
    this.position = position;
    this.velocity = velocity;
    this.c = c;
  }

  void update() {
    if (this.type == TYPE_MEDIUM) {
      this.velocity.add(new PVector(random(-1, 1), random(-1, 1)));
      this.velocity.limit(2);
    }

    this.position.add(this.velocity);
  }

  void display() {
    int x = (int)this.position.x;
    int y = (int)this.position.y;
    pixelPlus(x, y);
    if (this.life > this.lifeborder) {
      pixelPlus(x-1, y);
      pixelPlus(x+1, y);
      pixelPlus(x, y-1);
      pixelPlus(x, y+1);
    }
  }
  void pixelPlus(int x, int y) {
    color nowc = get(x, y);
    color newc = color(red(nowc) + red(this.c), green(nowc) + green(this.c), blue(nowc) + blue(this.c));
    set(x, y, newc);
  }
}
