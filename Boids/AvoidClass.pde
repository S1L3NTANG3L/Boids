class Avoid {
   PVector pos;
   
   Avoid (float xx, float yy) {
     pos = new PVector(xx,yy);
   }
   
   void go () {   
   }
   
   void draw () {
     fill(#A2BAF5);
     ellipse(pos.x, pos.y, 15, 15);
   }
}
