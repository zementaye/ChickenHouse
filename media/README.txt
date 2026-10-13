Drop your media here. The site works without it (placeholders show) and fills in as files appear.

HERO
  hero.mp4 / hero.webm   short silent loop for the home page
  hero-poster.jpg        still shown while the video loads
  img/hero-shawarma.jpg  shawarma photo on a dark background, floats over the flames

"LET IT FALL" SCENE (transparent PNG cut-outs, one item per file)
  img/slice.png    one piece of grilled chicken (reused 4 times, some flipped)
  img/onion.png    one onion ring
  img/tomato.png   one tomato wedge
  img/bread.png    flatbread, seen from above, where the pieces land

"ALL HEAT. ALL YOURS." SCENE
  img/plate.png    the two shawarma halves cut out (transparent PNG); the white plate is drawn by the site
  img/fries.png    a small handful of fries (transparent PNG, reused 5 times)

MENU AND HOME PHOTOS (normal photos, 4:5 portrait)
  img/classics.jpg fried.jpg grilled.jpg wings.jpg burger.jpg sides.jpg kitchen.jpg

Cut-outs: shoot on a plain background, then remove it with remove.bg, Photopea or Canva
and save as PNG or WebP with transparency.
Fast way to make the hero loop: install ffmpeg once (winget install Gyan.FFmpeg), then run
  powershell -ExecutionPolicy Bypass -File .\tools\make-media.ps1 -InputFile "D:\Chrome_Downloads\clip.mp4" -Start 3 -Length 6
