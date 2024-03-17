import java.util.*;

// Integer holding the gamestate. 0 = start screen, 1 = game, 2 = game over
int gameState = 1;

// Window dimensions
int windowHeight = 500;
int windowWidth = 500;

// Boolean variables to check which direction the spaceship is supposed to be moving
boolean moveUp = false;
boolean moveDown = false;
boolean moveLeft = false;
boolean moveRight = false;

// Boolean variables to check which direction the spaceship is already moving
boolean goingUp = false;
boolean goingLeft = false;

// Queue that will hold all bullets
Queue<Bullet> bullets = new LinkedList<>();
boolean isShooting = false;

// Create an instance of a spaceship
SpaceShip spaceShip = new SpaceShip();

// An array list of stars
ArrayList<Star> stars = new ArrayList<>();

Planet planet = new Planet();

MainGameScreen mainGameScreen = new MainGameScreen();
GameOverScreen gameOverScreen = new GameOverScreen();

/* In Processing version 3 and later, the window size needs to be set from settings
 When I tried to set it from setup(), it was giving me errors */
void settings() {
  size(windowWidth, windowHeight); 
}

void setup() {
  frameRate(60);
  
  // Add some stars into the array list
  for (int i = 0; i < 100; i++) {
    stars.add(new Star()); 
  }
}

// DRAW FUNCTION
void draw() {
  // If the player began the game
  if (gameState == 0) {
    return;
    
  }  else if (gameState == 1) {
    mainGameScreen.display();
    
  }  else if (gameState == 2) {
    gameOverScreen.display();
  }
}
// END OF DRAW FUNCTION

void keyPressed() {
  if (gameState == 0) {
    
  }
  
  else if (gameState == 1) {
    if (key == UP || key == 'w') {
      moveUp = goingUp = true;
      moveDown = false;
    } else if (key == DOWN || key == 's') {
      moveUp = goingUp = false;
      moveDown = true;
    } else if (key == LEFT || key == 'a') {
      moveLeft = goingLeft = true;
      moveRight = false;
    } else if (key == RIGHT || key == 'd') {
      moveLeft = goingLeft = false;
      moveRight = true;
    }
   
    if (key == ' ') {
      spaceShip.shoot();
     }
  }  
  
  else if (gameState == 2) {
    if (key == ENTER) {
      gameState = 1;
    }
  }
}

void keyReleased() {
  if (gameState == 1) {
    if (key == UP || key == 'w') {
      goingUp = moveUp = false;
    } else if (key == DOWN || key == 's') {
      moveDown = false;
    } else if (key == LEFT || key == 'a') {
      goingLeft = moveLeft = false;
    } else if (key == RIGHT || key == 'd') {
      moveRight = false;
    }
    
    if (key == ' ') {
      isShooting = false;
    }
  }
}

class MainGameScreen {
  void display() {
    background(#0a205a);  // Paint the background deep space blue
    
    for (Star star: stars) {
      star.update();
      star.display();
    }
    
    for (Bullet bullet: bullets) {
      bullet.update();
      bullet.display();
    }
    
    planet.update();
    planet.display();
    
    spaceShip.display();  // Render the spaceship
    
    // Screen limit lines
    stroke(153);
    line(0, 265, 500, 265);
    line(0, windowHeight - 45 - 10, 500,windowHeight - 45 - 10);
    line(windowWidth - 30 - 15, 0, windowWidth - 30 - 15, 500);
    line(15, 0, 15, 500);

    // If user is pressing up but not down...
    if (moveUp && !moveDown) {
      spaceShip.moveUp();  // Move up
      if (moveLeft) spaceShip.moveLeft();  // ... and left, if they are also pressing left (diagonally)
      else if (moveRight) spaceShip.moveRight();  // ... or right, if they are also pressing right (diagonally)
    }

    // If user is pressing down but not up...
    else if (!moveUp && moveDown) {
      spaceShip.moveDown();  // Move up
      if (moveLeft) spaceShip.moveLeft();  // ... and left, if they are also pressing left (diagonally)
      else if (moveRight) spaceShip.moveRight();  // ... or right, if they are also pressing right (diagonally)
    }

    // If the user is pressing both up AND down...
    else if (moveUp && moveDown) {
      if (goingUp) spaceShip.moveUp();  // Go up if the ship is going up
      else spaceShip.moveDown();  // Else, go down
    }

    // If the user is pressing left but not right, move left
    else if (moveLeft && !moveRight) {
      spaceShip.moveLeft();
    }

    // If the user is pressing right but not left, move right
    else if (!moveLeft && moveRight) {
      spaceShip.moveRight();
    }

    // // If the user is pressing both left AND right...
    else if (moveLeft && moveRight) {
      if (goingLeft) spaceShip.moveLeft();  // Go left if the ship is going left
      else spaceShip.moveRight();  // Else, go right
    }
  }
}

class GameOverScreen {
  void display() {
    background(#0a205a);  // Paint the background deep space blue
    for (Star star: stars) {
      
      star.update();
      star.display();
    }
    
    textSize(50);
    fill(#FFFFFF);
    textAlign(CENTER);
    text("Game Over!", windowWidth / 2, 210); 
    
    textSize(30);
    textAlign(CENTER);
    text("Press ENTER to retry.", windowWidth / 2, 260);
  }
}

class SpaceShip {
  // Set the dimensions of the ship
  int shipWidth = 30;
  int shipHeight = 45;

  // Center the ship by setting appropriate coordinates
  float baseX = (windowWidth - shipWidth) / 2;
  float baseY = windowHeight - 70;

  // Renders the spaceship
  void display() {
    // Main body of the rocket
    stroke(#000000);
    fill(#DFE0E2);
    rect(baseX, baseY, shipWidth, shipHeight);

    // Red triangle on top
    stroke(#E73B24);
    fill(#E73B24);
    // triangle(xLeftPoint, yLeftPoint, xMiddlePoint, yMiddlePoint, xRightPoint, yRightPoint)
    triangle(baseX, baseY,
      ((baseX + baseX + shipWidth) / 2), baseY - 15,
      baseX + shipWidth, baseY);

    // Left triangle on the bottom
    stroke(#000000);
    fill(#DFE0E2);
    triangle(baseX - 15, (baseY + shipHeight),
      baseX, (baseY + 25),
      baseX, (baseY + shipHeight));

    // Right triangle on the bottom
    triangle(baseX + shipWidth, (baseY + shipHeight),
      (baseX + shipWidth), (baseY) + 25,
      (baseX + shipWidth + 15), (baseY + shipHeight));

    //Trapezoid on the bottom
    quad(baseX + 5, baseY + shipHeight, // Top-left vertex (x1, y1)
      baseX + shipWidth - 5, baseY + shipHeight, // Top-right vertex (x2, y2)
      baseX + shipWidth + 5, baseY + shipHeight + 10, // Bottom-right vertex (x3, y3)
      baseX - 5, baseY + shipHeight + 10); // Bottom-left vertex (x4, y4)

    // Blue line on the body
    fill(#0AB9E5);
    rect(baseX + 10, baseY + 20, 10, shipHeight - 20);
  }

  // Move the spaceship up
  void moveUp() {
    baseY -= 2;
    baseY = constrain(baseY, 265, windowHeight);  // Checks so that the ship doesn't go past the approx. middle of screen
  }

  // Move the spaceship down
  void moveDown() {
    baseY += 2;
    baseY = constrain(baseY, 265, windowHeight - shipHeight - 10);  // Checks so that the ship doesn't go outside the screen
  }

  // Move the spaceship left
  void moveLeft() {
    baseX -= 2;
    baseX = constrain(baseX, 15, windowWidth);  // Checks so that the ship doesn't go outside the screen
  }

  // Move the spaceship right
  void moveRight() {
    baseX += 2;
    baseX = constrain(baseX, 15, windowWidth - shipWidth - 15);  // Checks so that the ship doesn't go outside the screen
  }
  
  void shoot() {
    if (isShooting == true) {
      return;
    }
    
    isShooting = true;
    bullets.add(new Bullet(
              (baseX + (shipWidth / 2)), 
              (baseY - 15)));
    isShooting = false;
  }
}

class Star {
  float starSize = random(0, 5);
  float positionX = random(0, windowWidth);
  float positionY = random(0, windowHeight);
  float speed = random(0, 2);
  
  float r = random(0,255);
  float g = random(0,255);
  float b = random(0,255);
  
  void update() {
    positionY += speed;
    // If the star goes beyond the bottom of the window, reset it to the top
    if (positionY > windowHeight) {
      positionY = 0;
      positionX = random(0, windowWidth);
    }
  }

  void display() {
    noStroke();
    fill(r, g, b);
    square(positionX, positionY, starSize);
  }
}

class Bullet {
  // Bullet dimensions
   float bulletHeight = 10;
   float bulletWidth = 3;
   
   // Bullet position depends on the spaceship position
   float positionX;
   float positionY;
   
   float speed = 4;
   
   // Initialize a new bullet
   Bullet (float posX, float posY) {
     positionX = posX;
     positionY = posY;
   }
   
   // The bullet is moving up by 'speed' units each frame
   void update() {
     positionY -= speed;
   }
   
   void display() {
    noStroke();
    fill(#FFFFFF);
    rect(positionX, positionY, bulletWidth, bulletHeight);
  }
}

class Planet {
  float planetSize = random(50, 150);
  
  float positionX = random(0, windowWidth);
  float positionY = -planetSize + (planetSize / 2);
  
  float speed = random(0.5, 2);
  
  void update() {
    positionY += speed;
    // If the planet goes beyond the bottom of the window, reset it to the top
    if (positionY > windowHeight) {
      positionY = -planetSize + (planetSize / 2);
      positionX = random(0, windowWidth);
      planetSize = random(50, 150);
    }
  }

  void display() {
    noStroke();
    fill(#FFFFFF);
    circle(positionX, positionY, planetSize);
  }
}

/*
for asteroids:
 x = random (0, width);
 y = y +v;
 v = v+g;
 if (y > height) {
 y = 0;
 y = random(0, width);
 v = 1;
 }
 */
