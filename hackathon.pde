import ddf.minim.*;

Minim minimi;
AudioInput aui;
Wor wor;
float[] auihis = new float[8 * 1024];
boolean shoani = false;
boolean invcol = false;



void setup() {
   fullScreen(); 
    minimi = new Minim(this);
    aui = minimi.getLineIn();
    wor = new Wor(width, height);
    int numani = 1024;
    for (int i = 0; i < numani; i++) wor.addnewani(random(wor.wid), random(wor.hei));
    background(255);
}


int col(int r, int g, int b) {
  return invcol ? color(255 - r, 255 - g, 255 -b) : color(r, g, b);    
}

int flocol(float val) {
  val = max(min(val, 1.0), -1.0);
  if (val < 0.0) return col(0, 0, int(-val * 255));
  else return col(int(val * 255), 0, 0);
}

int twoflocol(float val, float occ) {
  val = constrain(val, -1, 1); occ = constrain(occ, 0, 1);
  int ava = int(abs(val) * 255); int aoc = int(abs(occ) * 255);
  if (val < 0.0) return col(aoc, aoc / 3, ava);
  else return col(ava, aoc / 3, aoc);
}

int x = 0; 
double totval = 0.0;
float aveval = 0.0;
long numste = 0;

float sensitivity = 20.0;
float sca = 5.0;


void draw() {
    int aubusi = aui.bufferSize();
    int auhile = auihis.length;
    for (int i = auhile - 1; i >= 1; i--) { auihis[i] = auihis[i - 1]; }
    float locsum = 0.0;
    for (int i = 0; i < min(aubusi, height); i++) {
        float lefval = constrain(aui.left.get(i), -1, 1);
        float rigval = constrain(aui.right.get(i), -1, 1);
        
        wor.ethfie[0][i] = constrain(lefval * sensitivity, -1, 1);
        wor.ethfie[wor.wid - 1][i] = constrain(rigval * sensitivity, -1, 1);
        locsum += lefval + rigval;
    }
    auihis[0] = locsum / 5;
    
    for (Ani ani : wor.anilis) {
          ani.x += auihis[min(max((int) (ani.x / 15), 0), auhile - 1)] * sca;// ani.y += rigval * sca; 
    }
    wor.dra();
    wor.evo();
}

float shopar = 0.0;
float squaco = 1.0;
float squasi = 0.0;

void keyPressed(KeyEvent kev) {
   if (keyCode == UP) {
       sensitivity *= 1.1;
   }
   if (keyCode == DOWN) {
       sensitivity /= 1.1;
   }
   if (keyCode == LEFT) { 
      shopar += 0.01;
      squaco = sq(cos(shopar));
      squasi = sq(sin(shopar));
   }
   if (keyCode == RIGHT) {
      shopar -= 0.01; 
       squaco = sq(cos(shopar));
       squasi = sq(sin(shopar));
   }
   if (keyCode == 32) {
      shoani = !shoani; 
   }
}


class Wor {
   float[][] ethfie;
   float[][] derfie;
   float[][] accfie;
   float[][] occfie;
   int wid; int hei;
   Ani[] anilis = new Ani[0];
   Wor(int _wid, int _hei) {
     wid = _wid; hei = _hei;
     ethfie = new float[wid][hei];
     derfie = new float[wid][hei];
     accfie = new float[wid][hei];
     occfie = new float[wid][hei];
     inisin();
   }
   void inisin() {
      for (int x = 0; x < wid; x++) {
          for (int y = 0; y < hei; y++) {
              ethfie[x][y] = 0.5 * sin(5 * x * TWO_PI / wid) + 0.5 * sin(5 * y * TWO_PI / hei);
          }  
      }
   }
   
   void dra() {
      loadPixels();
      for (int x = 0; x < wid; x++) {
          for (int y = 0; y < hei; y++) {
            float ethval = ethfie[x][y];
            float occval = occfie[x][y];       
              pixels[x + y * width] = twoflocol(ethval * squaco, occval * squasi);
          }  
      }
      updatePixels();
      if (shoani) for (Ani ani : anilis) ani.dra();
   }
   
   
   void evo() {
     for (Ani ani : anilis) ani.evo(); 
     for (int x = 1; x + 1 < wid; x++) {
         for (int y = 1; y + 1 < hei; y++) {
            accfie[x][y] = 0.25 * (ethfie[x + 1][y] + ethfie[x - 1][y] + ethfie[x][y + 1] + ethfie[x][y - 1]) - ethfie[x][y]; 
            derfie[x][y] += accfie[x][y];
         }
     }
     for (int x = 0; x < wid; x++) {
        for (int y = 0; y < hei; y++) {
           ethfie[x][y] += derfie[x][y];
           
        }
     }
     
     for (int x = 0; x < wid; x++) {
        for (int y = 0; y < hei; y++) {
           occfie[x][y] = min(occfie[x][y], 10);
           occfie[x][y] *= 0.96; 
        }
     }
     
     for (Ani ani : anilis) {
        for (int dx = -20; dx <= 20; dx++) {
            for (int dy = -20; dy <= 20; dy++) {
                int x = (int) (ani.x + dx); int y = (int) (ani.y + dy);
                if (x < 0 || x >= wid || y < 0 || y >= hei) continue;
                float dis = sq(dx) + sq(dy) + 5;
                occfie[x][y] += 1.0 / dis;
            }
        }
     }
    

   }
   
   void addani(Ani ani) { anilis = (Ani[]) append(anilis, ani); }
   void addnewani(float x, float y) {
     Ani ani = new Ani(x, y, this); addani(ani);
   }
   float geteth(float x, float y) {
      if (x < 0) x = 0; if (x >= wid) x = wid - 1; if (y < 0) y = 0; if (y >= hei) y = hei - 1;
      return ethfie[int(x)][int(y)];
   }
   float getdex(float x, float y) { return geteth(x + 1, y) - geteth(x - 1, y); }
   float getdey(float x, float y) { return geteth(x, y + 1) - geteth(x, y - 1); } 
}

class Ani {
   float x;
   float y;
   float vex;
   float vey;
   float rad;
   float ste = 1.0;
   float dam = 0.9999;
   Wor wor;
   
   Ani(float _x, float _y, Wor _wor) { x = _x; y = _y; vex = vey = 0.0; wor = _wor; }
   
   float squaredis(float pox, float poy) {
      return sq(x - pox) + sq(y - poy); 
   }
   
   void evo() {
     x += ste * vex;
     y += ste * vey;
     vex *= dam;
     vey *= dam;
     vex -= wor.getdex(x, y);
     vey -= wor.getdey(x, y); 
     if (x < 0 || x > wor.wid) vex = -vex;
     if (y < 0 || y > wor.hei) vey = -vey;
     for (Ani ani : wor.anilis) {
        if (ani == this) continue;
        
        float dix = ani.x - x;
        
        float diy = ani.y - y;
        if (abs(dix) > 100 || abs(diy) > 100) continue;
        float squadi = sq(dix) + sq(diy);
        float fac = squadi;
        vex -= dix / fac;
        vey -= diy / fac;
     }
   }

   void dra() {
     noStroke();
     fill(col(0, 0, 0));
     ellipse(x, y, 6, 6);
   }
   
   void mov() {
     
   }
}
