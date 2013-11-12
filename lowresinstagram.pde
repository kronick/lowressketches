import org.json.*;

JSONObject json;
ArrayList<PImage> images;
ArrayList<String> urls;
ArrayList<ArrayList<Pixel>> pixelGrid;

int current_image = -1;

void setup() {
  size(600,600);
  //rectMode(CENTER);
  smooth();
  
  try {
    //json = new JSONObject(join(loadStrings("https://api.instagram.com/v1/tags/surf/media/recent?access_token=1183582.f59def8.a6413ff6a91f4ed5820d35c828d425e9"), "\n"));
    json = new JSONObject(join(loadStrings("instagram.json"), "\n"));
    urls = new ArrayList<String>();
    
    // Create PImages for some of the pics
    images = new ArrayList<PImage>();
    for(int i=0; i<20; i++) {
      urls.add(json.getJSONArray("data").getJSONObject(i).getJSONObject("images").getJSONObject("standard_resolution").getString("url"));
      println(urls.get(i));
      images.add(requestImage(urls.get(i)));
    }
  }
  catch(JSONException e) {
    println(e);
  }
  
  
  // Create a grid of pixels
  int resolution_x = 8;
  int resolution_y = 8;
  
  pixelGrid = new ArrayList<ArrayList<Pixel>>();
  for(int i=0; i<resolution_x; i++) {
    ArrayList<Pixel> row = new ArrayList<Pixel>();
    for(int j=0; j<resolution_y; j++) {
      row.add(new Pixel(new PVector(height/resolution_y * i, width/resolution_x * j), width/resolution_x));
    }
    pixelGrid.add(row);
  }
}

void draw() {
  background(0);
  noStroke();
  
  for(int i=0; i<pixelGrid.size(); i++) {
    for(int j=0; j<pixelGrid.get(i).size(); j++) {
      pixelGrid.get(i).get(j).update(millis() / 1000.0f);
      pixelGrid.get(i).get(j).draw();
    }
  }
  
  if(current_image == -1 && images.get(0).width > 0) {
    changeImage(images.get(0));
    current_image = 0;
  }
  
  //if(current_image >= 0)
  //  image(images.get(current_image % images.size()), 0,0, 100, 100);
    
}

void changeImage(PImage img) {
  println("updating pixels");
  // Update the pixels to the next image  
  img.loadPixels();
  int res_x = img.width / pixelGrid.size();
  int res_y = img.height / pixelGrid.get(0).size();
  for(int i=0; i<pixelGrid.size(); i++) {
    for(int j=0; j<pixelGrid.get(i).size(); j++) {
      pixelGrid.get(i).get(j).setTarget(averagePixels(img.get(i*res_x, j*res_y, res_x, res_y)));
    }
  }
}

color averagePixels(PImage img) {
  img.loadPixels();
  long r,g,b;
  r = g = b = 0;
  for(int i=0; i<img.pixels.length; i++) {
      r += red(img.pixels[i]);
      g += green(img.pixels[i]);
      b += blue(img.pixels[i]);
  }
  return color(r / img.pixels.length, g / img.pixels.length, b / img.pixels.length);
}
   
   
public class Pixel {
  PVector position;
  color currentColor;
  color oldColor;
  color targetColor;
  
  float w, h;
  
  float switching_time = 2;
  float lastChangeTime = 0;
  float timer = 0;
  
  public Pixel(PVector p, float s) {
    position = p.get();
    w = s; h = s;
    currentColor = oldColor = targetColor = color(random(0,255), random(0,255), random(0,255));
  }
  
  public void update(float t) {
     // lerp towards the new color
    timer = t;
    currentColor = lerpColor(oldColor, targetColor, constrain((t-lastChangeTime) / switching_time, 0,1));
    //currentColor = targetColor; 
  }
  public void draw() {
    fill(currentColor);
    float bezel = 2;
    rect(position.x + bezel/2, position.y + bezel/2, w-bezel,h-bezel);
    //ellipse(position.x + w/2, position.y + h/2, w/2,h/2);
  }
  public void setTarget(color c) {
    oldColor = targetColor;
    targetColor = c;
    lastChangeTime = millis() / 1000.0f;
    println(lastChangeTime);
  }
  
}

void keyPressed() {
  if(key == CODED && keyCode == RIGHT) {
    changeImage(images.get(++current_image % images.size()));
  }
  if(key == CODED && keyCode == LEFT) {
    changeImage(images.get(--current_image % images.size()));
  }
}
