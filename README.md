# Cosmic Crew - a game about space
- Cosmic Crew is a game for people who are in love with space. 
- By using **WASD**  keys, the player must move their spaceship, while collecting coins and dodging the asteroids. 
- Failure to dodge an asteroid will result in a game over. 
- Also, if the player lets asteroids reach the bottom of the screen, it will result in a deduction of points and game over if the score goes below zero. 
- The user is able to prevent the asteroids reaching the bottom of the screen by pressing space bar to shoot.
- This game does not have an ending at this stage of the game.

Time spent: **30** hours spent in total

## Features:

- [X] **Colorful stars that move on the background**
- [X] **Coins that can be picked up by the user to increase score**
- [X] **Asteroids that appear randomly**
- [X] **Colliding with an asteroid will lead to game over**
- [X] **Asteroid hitting the bottom of the screen will result in point deduction**
- [X] **Clicking the next button displays a random new card**

## Planned features

- Bound the spaceship and asteroids as complex shapes instead of circles and rectangles
- Add planets that will be undestroyable but will destroy the spaceship
- Powerups, for example, red lasers that can destroy asteroids in a certain radius, speed boost, and time freeze
- Speed up the game and/or add move asteroids as the game progresses
- Add a certain goal for the player, like a quest
- Change of background as the game progresses, for example, new planets are added, galaxies, etc

## Video Walkthrough

Here's a walkthrough of implemented required features:

<img src='public/Website Walkthrough.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />


GIF created with LiceCap.

## Notes

* Some challenges that I encountered included the collision logic. I made the spaceship from different shapes, which was very complicated to bound and check when it hits an asteroid or a coin. I used the following tutorial to implement collision detection. For simplicity, I approximated asteroids as circles, even though they are not perfect circles, and bounded the spaceship as a rectangle. The collision logic works, however, sometimes it detects a collision from being close to an asteroid due to the approximation of the shape.
	Another challenge I encountered is rendering asteroids that do not overlap. I’ve spent a lot of time on this; however, the asteroids still overlap sometimes, and I decided to leave it as it is in this alpha version of the game.

## License

    Copyright [2023] [Mariia Onokhina]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
