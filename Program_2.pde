SimpleUIManager uiManager;

PImage backgroundImage = null;

Document document;

  int canvasX = 100;
  int canvasY = 50;
  int canvasWidth = 790;
  int canvasHeight = 590;
  String toolMode = "";

  int[] siglut = makeSigmoidLUT();
  
void setup(){
  size(800,600);
  uiManager = new SimpleUIManager();
  document = new Document();
  
  String[] fileMenu = {"Load Image", "Save Image"};
  String[] imageMenu = {"Black & White", "Grey Scale", "Contrast"};
  
  uiManager.addCanvas(canvasX, canvasY, canvasWidth,canvasHeight);
  
  uiManager.addMenu("File", 0, 0, fileMenu);
  uiManager.addMenu("Image", 80, 0, imageMenu);
  
  SimpleButton liveButton = uiManager.addToggleButton("Live", canvasX-80, 50);
  uiManager.addRadioButton("Line", canvasX-80, 120, "shapeButtons");
  uiManager.addRadioButton("Circle", canvasX-80, 200, "shapeButtons");
  
    SimpleButton  rectButton = uiManager.addRadioButton("Rectangle", canvasX-80, 160, "shapeButtons");
  uiManager.addRadioButton("select", canvasX-80, 280, "shapeButtons");
}

void draw() {
 background(255);
 
 if(this.backgroundImage != null)
    image(backgroundImage, canvasX + 1, canvasY + 1, backgroundImage.width,backgroundImage.height);
 
 document.drawMe();
 uiManager.drawMe();
}



void mousePressed(){
  uiManager.handleMouseEvent("mousePressed",mouseX,mouseY);
}

void mouseReleased(){
  uiManager.handleMouseEvent("mouseReleased",mouseX,mouseY);
}

void mouseClicked(){
  uiManager.handleMouseEvent("mouseClicked",mouseX,mouseY);
}

void mouseMoved(){
    uiManager.handleMouseEvent("mouseMoved",mouseX,mouseY);
}

void mouseDragged(){
   uiManager.handleMouseEvent("mouseDragged",mouseX,mouseY);
}



void simpleUICallback(UIEventData eventData){
  // first boolean is for extra data, second boolean is to show mouseMoves, which you might not want
  eventData.printMe(true, false);
  
   
  if(eventData.uiComponentType == "RadioButton"){
    
    toolMode = eventData.uiLabel;
  }

  //if(eventData.uiComponentType != "Canvas") return;
    
  switch(eventData.uiLabel){
  case "Load Image" :
    selectInput("Open image", "loadAnImage");
            break;
  case "Black & White" :
    bAndW(backgroundImage);
  case "Grey Scale" :
    greyScale(backgroundImage);
  case "Contrast"  :
    backgroundImage = applyPointProcessing(siglut, siglut, siglut, backgroundImage);
  case "Save Image" :
    backgroundImage.save("image");
}  
    
  switch(toolMode) {
          case "Rectangle": 
            drawRect(eventData);
            break;
            
          case "Line": 
            drawLine(eventData);
            break;
          
          case "select": 
            trySelection(eventData);
            break;
            //..... other tools here
        }
  

}


void drawRect(UIEventData eventData){
  PVector p = new PVector(eventData.mousex, eventData.mousey);
  if(eventData.mouseEventType == "mousePressed"){
    // start the rect here
    document.startNewShape("rect", p);
  }
  
  if(eventData.mouseEventType == "mouseDragged"){
    // end the rect here
    if( document.currentlyDrawnShape == null ) return;
    document.currentlyDrawnShape.duringMouseDrawing(p);
  }
  
  if(eventData.mouseEventType == "mouseReleased"){
    // end the rect here
    if( document.currentlyDrawnShape == null ) return;
    document.currentlyDrawnShape.endMouseDrawing(p, "rect");
    document.currentlyDrawnShape  = null;
  } 
}

void drawLine(UIEventData eventData)
{
  PVector p = new PVector(eventData.mousex, eventData.mousey);
  if(eventData.mouseEventType == "mousePressed")
  {
    document.startNewShape("line", p);
  }
  
  if(eventData.mouseEventType == "mouseDragged")
  {
    if(document.currentlyDrawnShape == null) return;
    document.currentlyDrawnShape.duringMouseDrawing(p);
  }
  
  if(eventData.mouseEventType == "mouseReleased")
  {
    if(document.currentlyDrawnShape == null) return;
    document.currentlyDrawnShape.endMouseDrawing(p, "line");
    document.currentlyDrawnShape = null;
  }
}

void trySelection(UIEventData eventData){
  if(eventData.mouseEventType != "mousePressed") return;
  
  PVector p = new PVector(eventData.mousex,eventData.mousey);
  document.trySelect(p);
  
}

int[] makeSigmoidLUT(){
  int[] lut = new int[256];
  for(int n = 0; n < 256; n++) {
    
    float p = n/255.0f;
    float val = sigmoidCurve(p);
    lut[n] = (int)(val*255);
  }
  return lut;
}

void loadAnImage(File fileNameObj){
  String pathAndFileName = fileNameObj.getAbsolutePath();
  PImage img = loadImage(pathAndFileName); 
  this.backgroundImage = img;
  if(backgroundImage.width > canvasWidth){
    this.backgroundImage.resize(canvasWidth-100, 0);
  }
  if(backgroundImage.height > canvasHeight){
    this.backgroundImage.resize(0, canvasHeight-100);
  }
}

PImage applyPointProcessing(int[] redLUT, int[] greenLUT, int[] blueLUT, PImage inputImage){
  PImage outputImage = createImage(inputImage.width,inputImage.height,RGB);
  
  inputImage.loadPixels();
  outputImage.loadPixels();
  int numPixels = inputImage.width*inputImage.height;
  for(int n = 0; n < numPixels; n++){
    
    color c = inputImage.pixels[n];
    
    int r = (int)red(c);
    int g = (int)green(c);
    int b = (int)blue(c);
    
    r = redLUT[r];
    g = greenLUT[g];
    b = blueLUT[b];
    
    outputImage.pixels[n] = color(r,g,b);
  }
  return outputImage;
}

void bAndW(PImage backgroundImage){
  for (int y = 0; y < backgroundImage.height; y++) {
      for (int x = 0; x < backgroundImage.width; x++){
        
        color thisPix = backgroundImage.get(x,y);
         
        int brightness = (int)red(thisPix) + (int)green(thisPix) + (int)blue(thisPix);
        
        if (brightness<=382)
        {
        color newColour = color(0,0,0);
        backgroundImage.set(x,y, newColour);
        }
        else
        {
        color newColour = color(255,255,255);
         backgroundImage.set(x,y, newColour);
        }
      }
    }
}

void greyScale(PImage backgroundImage){
   for (int y = 0; y < backgroundImage.height; y++) {
      for (int x = 0; x < backgroundImage.width; x++){
        color thisPix = backgroundImage.get(x,y);
        int grey = ((int)red(thisPix) + (int)green(thisPix) + (int)blue(thisPix))/3;
        
        color newColour = color(grey, grey, grey);
         backgroundImage.set(x,y, newColour);
        }
      }
    }
    
