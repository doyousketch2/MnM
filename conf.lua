function love .conf(t)
  local w  = t .window
  local m  = t .modules
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  w .title  = 'Löve MnM'
  w .icon   = 'icon.png'

  w .width  = 600
  w .height = 400
  w .vsync  = true                     -- Enable vertical sync  (boolean)

  t .version  = '0.10.2'               -- Löve version this game was made for

  t .identity  = 'MnM'                 -- Name of the save directory
  t .externalstorage  = false          -- Read & write from external storage on Android
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- enable a module if you need to use its functions.
-- disable unused modules for slight speed-up in load time, and reduction in memory use.

  m .window  = true       -- Modify and retrieve information about the program's window.
  m .timer   = true       -- High-resolution timing functionality,
                          --- Disabling will result 0 delta time in love.update
  m .event   = true       -- Manage events, like keypresses.
  m .math    = true       -- System-independent mathematical functions.

  m .keyboard  = true     -- Interface to user's keyboard.
  m .mouse     = true     --             user's mouse.
  m .touch     = true     --            touch-screen presses.
  m .joystick  = false    --           connected joysticks.

  m .image     = true     -- Decode encoded image data.
  m .graphics  = true     -- Draw lines, shapes, text, Images and other Drawable objects onto screen.
                          --- Its secondary responsibilities include:
                          --- loading Images and Fonts into memory,   managing screen geometry,
                          --- creating drawable objects,  such as ParticleSystems or Canvases.

  m .sound    = false     -- Decode sound files.  It can't play sounds, see love.audio for that.
  m .audio    = false     -- Output sound to user's speakers.

  m .video    = false     -- Decode, control, and stream video files.
  m .physics  = false     -- Simulate 2D rigid body physics in a realistic manner,  based on Box2D

  m .system   = false     -- Information about user's system.
  m .thread   = false     -- Allows you to work with threads.

--  font                  ** Allows you to work with fonts.
--  filesystem            ** Interface to user's filesystem.
end
