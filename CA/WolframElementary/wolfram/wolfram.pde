
class CA {
  int[] ruleset = {0,1,1,1,0,1,1,0,0};
  int w = 15;
  int generation = 0;
  ArrayList<int[]> history = new ArrayList<int[]>();
  int width;
  int height;

  CA(int width, int height) {
    this.width = width;
    this.height = height;
    int[] cells = new int[width/w];

    for (int i = 0; i < cells.length; i++) {
      cells[i] = 0;
    }
    cells[cells.length/2] = 1;
    history.add(cells);
  }

  void generate() {
    int[] currentGen = history.get(history.size()-1);
    int[] nextGen = new int[currentGen.length];
    int len = currentGen.length;

    for (int i = 0; i<len-1; i++) {

      int left, middle, right;

      if (i <= 0) 
        left = currentGen[len-1];
      else
        left = currentGen[i-1];

      middle = currentGen[i];

      if (i >= len-1)
        right = currentGen[0];
      else 
      right = currentGen[i+1];

      nextGen[i] = rules(left, middle, right);
    }

    if (history.size() > height/w) {
      history.remove(0);
    }

    history.add(nextGen);
    generation ++;
  }

  int rules(int a, int b, int c) {
    String s = "" + a + b + c;
    int index = Integer.parseInt(s, 2);
    return ruleset[index];
  }

  void render() {
    for (int gen = 0; gen < history.size(); gen++) {
      int[] cells = history.get(gen);
      for (int i = 0; i < cells.length; i++) {
        if (cells[i] == 0) fill(255);
        else fill(0);
        stroke(0);
        rect(i*w, gen*w, w, w);
      }
    }
  }
}

CA ca = new CA(1920, 1200);

void setup() {
  fullScreen();
}


void draw() {
  ca.generate();
  ca.render();
}