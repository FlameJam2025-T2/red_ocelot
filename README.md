# 🚀 Red Ocelot

> **Version: 1.1.1 update:**: laser shader tweak, fixed occasional crash from missing cluster (further investigation reqired)
> **Version: 1.1.0 update:**: new laser shader, fixed reset bug when clicking on high score, fixed scoreboard positioning
> **UPDATE:** Patched build to fix shader crashing and terrible performance (at higher resolutions).

## 📝 DESCRIPTION

Red Ocelot is a fast-paced space shooter where you pilot a rocket ship between clusters of enemies scattered across the galaxy.

Use your skills to dodge, weave, and destroy enemy formations!

This game was made for Flame Jam 2025, on the theme of "The Space Race."

## 🌠 THEME TIE IN

This game requires you to race against yourself, to clear the galaxy of enemies as quickly as possible. Is this necessary? Or are you a xenophobic terrorist? You can decide for yourself.

**Diversifier**  
Shaders, shaders are used to generate the gorgeous starfield background.

*by @srapop and @zeyus (TEAM2)*

We customized a starfield shader to bring the universe to life and composed original music for the full immersive experience.

## 🎮 HOW TO PLAY

- Either use the **arrow keys** to rotate and move the rocket or use the joystick
- Press the **spacebar**, or use the on-screen fire button to fire lasers at enemies
- Travel from cluster to cluster and eliminate as many threats as possible in the shortest possible time
- Try and beat your previous times
- Try to survive as long as you can and rack up as many points as possible!

## 🌐 WHERE TO PLAY

Here on itch.io or on github pages:

[https://flamejam2025-t2.github.io/red_ocelot/](https://flamejam2025-t2.github.io/red_ocelot/)

Android and OSX builds are available, and if someone wants it we can build a linux and windows version.

## 👏 STATEMENT

All sounds were created by [zeyus](https://soundcloud.com/zeyus)

Shader rendering code was based on [renancaraujo's flame_shaders](https://github.com/renancaraujo/turi/tree/main/lib/game/flame_shaders)

Starfield shader based on: [golfing starfield + dark dust 3](https://www.shadertoy.com/view/7dVGz1) by [FabriceNeyret2](https://www.shadertoy.com/user/FabriceNeyret2)

[https://github.com/renancaraujo/turi/blob/main/lib/game/flame_shaders/components.dart](https://github.com/renancaraujo/turi/blob/main/lib/game/flame_shaders/components.dart)

Monsters and UFO were made by RUOK

[https://opengameart.org/content/space-monster-pixel-art-set](https://opengameart.org/content/space-monster-pixel-art-set)

Coding and development were done using Flutter, Flame and Forge2D, with lots of caffeine!

## ⚠️ LIMITATIONS

This game, although super fun to make and a great learning experience, due to time constraints didn't have the complete feature-set we wanted.

Ideally the monsters would be replaced with our own art, and there should be sound effects for hits and explosions. Also would be nice if the monsters fought back.

I started implementing some real-time audio generation (using multi-freq sine and square waves) which would allow for game-state dependent audio...this would be amazing, but unfortunately I only got the audio working right at the end, so we were limited to what we'd already done.

Finally, there's an incredible looking laser shader that was inteded to replace the 3point bullet stream, but shaders turned out to be difficult to get working well, I think it would be possible now, based on all the knew knowledge, but there wasn't time to go back to it.

---

*Red Ocelot - Flame game jam 2025 - Team 2*
