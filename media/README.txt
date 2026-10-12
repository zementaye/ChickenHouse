Drop your media here. The site works without it (green placeholders) and fills in as files appear.

  hero.mp4 / hero.webm   short silent loop for the home page
  hero-poster.jpg        still shown while the video loads
  img/classics.jpg fried.jpg grilled.jpg wings.jpg burger.jpg sides.jpg kitchen.jpg

Fast way: install ffmpeg once (winget install Gyan.FFmpeg), then in PowerShell from the project folder run
  powershell -ExecutionPolicy Bypass -File .\tools\make-media.ps1 -InputFile "D:\Chrome_Downloads\clip.mp4" -Start 3 -Length 6
(start at second 3, 6 second loop). It writes the hero files and 7 stills into img\.
Rename the best stills to the names above.
