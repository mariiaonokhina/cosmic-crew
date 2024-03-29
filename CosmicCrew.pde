import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.util.*;

// Integer holding the gamestate. 0 = start screen, 1 = game, 2 = game over
int gameState = 0;

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
ArrayList<Bullet> bullets = new ArrayList<>();
boolean isShooting = false;

// Create an instance of a spaceship
SpaceShip spaceShip = new SpaceShip();

// An array list of stars
ArrayList<Star> stars = new ArrayList<>();

// An array list of asteroids
ArrayList<Asteroid> asteroids = new ArrayList<>();

// An array list of coins
ArrayList<Coin> coins = new ArrayList<>();

int highScore, score = 0;
boolean hitHighScore = false;

StartGameScreen startGameScreen = new StartGameScreen();
MainGameScreen mainGameScreen = new MainGameScreen();
GameOverScreen gameOverScreen = new GameOverScreen();

PShape asteroid;

Minim minim;
AudioPlayer gameMusic, gameOverMusic, asteroidHitSound, collisionSound, shootingSound, coinPickupSound, newHighScoreSound;

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

  // Add some asteroids into the array list
  for (int i = 0; i < 4; i++) {
    asteroids.add(new Asteroid());
  }

  for (int i = 0; i < 2; i++) {
    coins.add(new Coin());
  }

  // Use free images from svgrepo.com for asteroids
  asteroid = loadShape("asteroid.svg");

  minim = new Minim(this);

  // Load sound files
  gameMusic = minim.loadFile("mixkit-space-game-668.mp3");
  shootingSound = minim.loadFile("mixkit-short-laser-gun-shot-1670.wav");
  asteroidHitSound = minim.loadFile("mixkit-arcade-game-explosion-2759.wav");
  collisionSound = minim.loadFile("mixkit-pixel-chiptune-explosion-1692.wav");
  gameOverMusic = minim.loadFile("mixkit-falling-game-over-1942.wav");
  coinPickupSound = minim.loadFile("mixkit-game-success-alert-2039.wav");
}

// DRAW FUNCTION
void draw() {
  // Play background music on start screen or game screen
  if (gameState == 0 || gameState == 1) {
    if (!gameMusic.isPlaying()) gameMusic.loop();
  }

  if (gameState == 0) {
    startGameScreen.display();
  } else if (gameState == 1) {
    mainGameScreen.display();
  } else if (gameState == 2) {
    gameOverScreen.display();

    if (gameMusic.isPlaying()) {
      gameMusic.pause(); // Stop the music when the game is over
      gameMusic.rewind(); // Rewind the music to the start for the next game
    }
  }
}
// END OF DRAW FUNCTION

void keyPressed() {
  if (gameState == 0) {
    if (key == ENTER) {
      gameState = 1;
    }
  } else if (gameState == 1) {
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
  } else if (gameState == 2) {
    if (key == ENTER) {
      gameState = 1;

      asteroids.clear();
      bullets.clear();

      spaceShip = new SpaceShip();

      // Add some asteroids into the array list
      for (int i = 0; i < 4; i++) {
        asteroids.add(new Asteroid());
      }

      goingLeft = goingUp = moveUp = moveLeft = moveRight = moveDown = false;
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

void mousePressed() {
  if (gameState == 0 &&
    mouseX >= 175 && mouseX <= 325 &&
    mouseY >= 325 && mouseY <= 375) {
    gameState = 1;
  }
}

class StartGameScreen {
  void display() {
    background(#0a205a);

    textSize(50);
    fill(#FFFFFF);

    textAlign(CENTER, CENTER);
    text("Cosmic Crew!", windowWidth / 2, 75);

    textSize(22);
    text("WASD to move the space ship.", windowWidth / 2, 130);

    text("Shoot at asteroids by pressing SPACE BAR.", windowWidth / 2, 180);

    text("Don't let asteroids hit you or the bottom of screen!", windowWidth / 2, 230);

    text("Collect coins to beat your high score!", windowWidth / 2, 280);

    rect(175, 325, 150, 50);

    fill(#000000);
    text("START", windowWidth / 2, 350);
  }
}

class MainGameScreen {
  void display() {
    background(#0a205a);  // Paint the background deep space blue

    for (Star star : stars) {
      star.update();
      star.display();
    }

    Iterator<Coin> iterator = coins.iterator();
    while (iterator.hasNext()) {
      Coin coin = iterator.next();
      coin.update();
      coin.display();

      // Check if the spaceship collected the coin
      boolean hitCoin = didCollide(coin.getCenterX(), coin.getCenterY(),
        coin.getCoinRadius(),
        spaceShip.getBoundRectX(), spaceShip.getBoundRectY(),
        spaceShip.getShipWidth(), spaceShip.getShipHeight());

      if (hitCoin) {
        score += 15; // Increase score

        if (score > highScore) {
          hitHighScore = true;
        }

        // Play the coin pickup sound
        if (coinPickupSound.isPlaying()) {
          coinPickupSound.pause();
          coinPickupSound.rewind();
        } else {
          coinPickupSound.rewind(); // Ensure it's at the start if not already playing
        }
        coinPickupSound.play();

        iterator.remove(); // Remove the collected coin
      }
    }
    
    if (coins.size() != 2) {
      coins.add(new Coin());
    }

    Iterator<Bullet> bulletIterator = bullets.iterator();
    while (bulletIterator.hasNext()) {
      Bullet bullet = bulletIterator.next();
      bullet.update();
      bullet.display();

      boolean bulletHit = false;

      // Check collision with asteroids
      Iterator<Asteroid> asteroidIterator = asteroids.iterator();
      while (asteroidIterator.hasNext()) {
        Asteroid asteroid = asteroidIterator.next();

        // For simplicity, use point-circle detection. Treat the top of the bullet as a point
        if (dist(bullet.positionX, bullet.positionY, asteroid.getCenterX(), asteroid.getCenterY()) < asteroid.getAsteroidRadius()) {
          asteroidIterator.remove(); // Remove the asteroid

          // Add new asteroid to array list
          asteroids.add(new Asteroid());

          bulletHit = true;

          if (asteroidHitSound.isPlaying()) {
            asteroidHitSound.pause();
            asteroidHitSound.rewind();
          } else {
            asteroidHitSound.rewind(); // Ensure it's at the start if not already playing
          }
          asteroidHitSound.play(); // Play the sound

          score += 15;

          if (score > highScore) {
            hitHighScore = true;
          }

          break; // Stop checking for this bullet since it hit an asteroid
        }
      }

      if (bulletHit) {
        bulletIterator.remove(); // Remove the bullet if it hit an asteroid
      }
    }

    for (Asteroid asteroid : asteroids) {
      asteroid.update();
      asteroid.display();

      // Check if the spaceship touches any asteroid or planet
      boolean hitAsteroid = didCollide(asteroid.getCenterX(), asteroid.getCenterY(),
        asteroid.getAsteroidRadius(),
        spaceShip.getBoundRectX(), spaceShip.getBoundRectY(),
        spaceShip.getShipWidth(), spaceShip.getShipHeight());

      if (hitAsteroid) {
        if (collisionSound.isPlaying()) {
          collisionSound.pause();
          collisionSound.rewind();
        } else {
          collisionSound.rewind(); // Ensure it's at the start if not already playing
        }
        collisionSound.play(); // Play the sound

        gameState = 2;

        if (gameOverMusic.isPlaying()) {
          gameOverMusic.pause();
          gameOverMusic.rewind();
        } else {
          gameOverMusic.rewind(); // Ensure it's at the start if not already playing
        }
        gameOverMusic.play(); // Play the sound
      }
    }

    if (score < 0) {
      if (gameOverMusic.isPlaying()) {
        gameOverMusic.pause();
        gameOverMusic.rewind();
      } else {
        gameOverMusic.rewind(); // Ensure it's at the start if not already playing
      }
      gameOverMusic.play(); // Play the sound
      gameState = 2;
    }

    spaceShip.display();  // Render the spaceship

    textSize(50);
    fill(#FFFFFF);
    text(score, windowWidth - 80, 50);

    if (hitHighScore) {
      fill(#FF0000);
      textSize(20);
      text("NEW HIGH SCORE", windowWidth - 80, 80);
    }

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

boolean didCollide(float circleX, float circleY, float r, float rectX, float rectY, float rectWidth, float rectHeight) {
  // Temporary variables to set edges for testing
  float testX = circleX;
  float testY = circleY;

  // Which edge is closest?
  if (circleX < rectX) testX = rectX;
  else if (circleX > rectX + rectWidth) testX = rectX + rectWidth;

  if (circleY < rectY) testY = rectY;
  else if (circleY > rectY + rectHeight) testY = rectY + rectHeight;

  // Get distance from closest edges
  float distX = circleX - testX;
  float distY = circleY - testY;
  float distance = sqrt((distX*distX) + (distY*distY));

  // If the distance is less than the radius, collision!
  if (distance <= r) {
    return true;
  }
  return false;
}

class GameOverScreen {
  void display() {
    if (score > highScore) highScore = score;

    score = 0;
    hitHighScore = false;

    background(#0a205a);  // Paint the background deep space blue
    for (Star star: stars) {
      star.update();
      star.display();
    }

    textSize(50);
    fill(#FFFFFF);
    text("Game Over!", windowWidth / 2, 210);

    textSize(30);
    text("Your high score: " + highScore, windowWidth / 2, 260);
    text("Press ENTER to retry.", windowWidth / 2, 305);
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
    if (isShooting) baseY -= 3;
    else baseY -= 4;
    
    baseY = constrain(baseY, 265, windowHeight);  // Checks so that the ship doesn't go past the approx. middle of screen
  }

  // Move the spaceship down
  void moveDown() {
    if (isShooting) baseY += 3;
    else baseY += 4;
    
    baseY = constrain(baseY, 265, windowHeight - shipHeight - 10);  // Checks so that the ship doesn't go outside the screen
  }

  // Move the spaceship left
  void moveLeft() {
    if (isShooting) baseX -= 3;
    else baseX -= 4;
    
    baseX = constrain(baseX, 15, windowWidth);  // Checks so that the ship doesn't go outside the screen
  }

  // Move the spaceship right
  void moveRight() {
   if (isShooting) baseX += 3;
   else baseX += 4;
   
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

    // If shooting sound already playing, stop it and rewind
    if (shootingSound.isPlaying()) {
      shootingSound.pause();
      shootingSound.rewind();
    } else {
      shootingSound.rewind(); // Ensure it's at the start if not already playing
    }
    shootingSound.play(); // Play the sound

    isShooting = false;
  }

  // For simplicity, we'll be checking collision as if spaceship were a rectangle
  float getBoundRectX() {
    return baseX - 15;
  }

  float getBoundRectY() {
    return baseY - 15;
  }

  float getShipHeight() {
    // Add ship height to the height of triangle on top + height of trapezoid on the bottom
    return shipHeight + 15 + 10;
  }

  float getShipWidth() {
    // Add ship width to the width of both "flaps" of the space ship on the sides
    return shipWidth + 15 + 15;
  }
}

class Star {
  float starSize = random(0, 5);
  float positionX = random(0, windowWidth);
  float positionY = random(0, windowHeight);
  float speed = random(0, 2);

  float r = random(0, 255);
  float g = random(0, 255);
  float b = random(0, 255);

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

class Coin {
  float coinSize = 30;

  float positionX = random(0 + coinSize, windowWidth - coinSize);
  float positionY = random(-50, -coinSize + (coinSize / 2));

  float speed = random(0.5, 3);

  void update() {
    positionY += speed;

    // If the coin goes beyond the bottom of the window, reset it to the top
    if (positionY - coinSize > windowHeight) {
      positionY = random(-50, -coinSize + (coinSize / 2));
    }
  }

  void display() {
    strokeWeight(4);
    stroke(#E9AD03);
    fill(#F3C70D);
    circle(positionX, positionY, coinSize);
    fill(000000);
    textSize(30);
    text("C", positionX, positionY);
    noStroke();
    noFill();
    strokeWeight(1);
  }

  float getCenterX() {
    return positionX;
  }

  float getCenterY() {
    return positionY;
  }

  float getCoinRadius() {
    return coinSize / 2;
  }
}

class Asteroid {
  float asteroidSize = random(30, 70);
  float positionX = random(0 + asteroidSize, windowWidth - asteroidSize);
  float positionY = random(-200, -asteroidSize);
  float speed = random(1.5, 2.5);

  void update() {
    positionY += speed;

    if (positionY > windowHeight) {
      resetAsteroidPosition();
    }
  }

  void resetAsteroidPosition() {
    boolean overlaps;
    do {
      overlaps = false;

      // Generate a new position for this asteroid
      positionY = random(-200, -asteroidSize);
      positionX = random(0 + asteroidSize, windowWidth - asteroidSize);

      // Check for overlaps with other asteroids
      for (Asteroid asteroid : asteroids) {
        if (asteroid != this) {
          float distance = dist(positionX + asteroidSize / 2, positionY + asteroidSize / 2,
            asteroid.positionX + asteroid.asteroidSize / 2, asteroid.positionY + asteroid.asteroidSize / 2);
          if (distance < (asteroidSize / 2 + asteroid.asteroidSize / 2)) {
            overlaps = true;
            break;
          }
        }
      }
    } while (overlaps);

    if (!overlaps) {
      playCollisionSound();
    }
  }

  void playCollisionSound() {
    score -= 30;  // Decrease the score

    if (collisionSound.isPlaying()) {
      collisionSound.pause();
      collisionSound.rewind();
    } else {
      collisionSound.rewind(); // Ensure it's at the start if not already playing
    }
    collisionSound.play(); // Play the sound
  }

  void display() {
    shape(asteroid, positionX, positionY, asteroidSize, asteroidSize);
  }

  float getCenterX() {
    return positionX + asteroidSize / 2;
  }

  float getCenterY() {
    return positionY + asteroidSize / 2;
  }

  float getAsteroidRadius() {
    return asteroidSize / 2;
  }
}
