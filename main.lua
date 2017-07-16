--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  Löve MnM         GNU GPLv3                @Doyousketch2

-- global abbreviations,  can be used in any module.
Lo   = love
-- look in conf.lua to enable necessary modules.
aud  = Lo .audio             mou  = Lo .mouse
eve  = Lo .event             phy  = Lo .physics
fil  = Lo .filesystem        sou  = Lo .sound
fon  = Lo .Font              sys  = Lo .system
gra  = Lo .graphics          thr  = Lo .thread
ima  = Lo .image             tim  = Lo .timer
joy  = Lo .joystick          tou  = Lo .touch
key  = Lo .keyboard          vid  = Lo .video
mat  = Lo .math              win  = Lo .window
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WW  = gra .getWidth()        HH  = gra .getHeight()
-- screen divisions:  quarter,  third,  and tenth
w25  = WW *0.25                     w33  = WW *0.333
w1   = WW *0.1     w2  = WW *0.2     w3  = WW *0.3
w4   = WW *0.4     w5  = WW *0.5     w6  = WW *0.6
w7   = WW *0.7     w8  = WW *0.8     w9  = WW *0.9
w66  = WW *0.667                    w75  = WW *0.75
--                  { w5, h5 }  = center of screen
h25  = HH *0.25                     h33  = HH *0.333
h1   = HH *0.1     h2  = HH *0.2     h3  = HH *0.3
h4   = HH *0.4     h5  = HH *0.5     h6  = HH *0.6
h7   = HH *0.7     h8  = HH *0.8     h9  = HH *0.9
h66  = HH *0.667                    h75  = HH *0.75
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- local vars used within this file,  or function scope.
local cBlue   = {  62,  49, 162 }
local ltBlue = { 124, 112, 218 }
local white  = { 255, 255, 255 }

local smallFontSize   = 16
local mediumFontSize  = 20
local largeFontSize   = 30
local xlargeFontSize  = 35

local page  = 4
local entry  = 1
local codes  = require 'data.codes'

local line  = codes [page] [entry] [1]
local word   = codes [page] [entry] [2]
local keyword  = codes [page] [entry] [3]

local pad  = 15  -- border padding
local lpad  = pad     local rpad  = WW -pad -- left, right
local upad  = pad     local dpad  = HH -pad -- up, down
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .load( arg )
  print('Löve app begin')
  gra .setBackgroundColor( cBlue )
  gra .setColor( ltBlue )

  smallFont   = gra .newFont( smallFontSize )
  mediumFont  = gra .newFont( mediumFontSize )
  largeFont   = gra .newFont( largeFontSize )
  xlargeFont  = gra .newFont( xlargeFontSize )

  gra .setFont( smallFont )
end -- Lo .load(arg)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Scancodes are international
-- see scancodes.txt in the data dir for reference.

key .setKeyRepeat( true ) -- hold key to repeat?  system determines interval

function Lo .keypressed( key, scancode, isrepeat )

  if scancode == 'left'  then  page  = page -1  end
  if scancode == 'right' then  page  = page +1  end

  if page < 4  then  page  = 4  end
  if page > 32  then  page  = 32  end

  if scancode == 'up'   then  entry  = entry -1  end
  if scancode == 'down' then  entry  = entry +1  end

  if entry < 1  then  entry  = 1  end
  if entry > #codes[page]  then  entry  = #codes[page]  end

  line   = codes [page] [entry] [1]
  word    = codes [page] [entry] [2]
  keyword  = codes [page] [entry] [3]
end -- Lo .keypressed

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .update( dt )
end -- Lo .update(dt)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .draw()
  gra .print( 'arrow keys',  w8 +15,  upad )
  gra .setFont( mediumFont )

  local xx  = w2 -10
  local yy  = h1 +10
  if page > 9  then  xx  = w2  end
  gra .print( '<->',  xx,  yy )

  local xx  = w4
  if line > 9  then  xx  = w4 +10  end
  gra .print( '/\\',  xx,  yy ) --  /\   backslash is an escape char in lua,
  gra .print( '\\/',  xx,  h3 ) --  \/   so two backslashes show up as one in text.

  local yy  = h2 +10
  gra .print( 'Page:  ',  w1,  yy )
  gra .print( 'Line:  ',  w3,  yy )
  gra .print( 'Word:  ',  w5,  yy )
  gra .print( 'Keyword:  ',  w1,  h5 +15 )

  gra .setColor( white )
  gra .setFont( largeFont )
  gra .print( page,  w2,  h2 )
  gra .print( line, w4,  h2 )
  gra .print( word,  w6 +10,  h2 )

  gra .setFont( xlargeFont )
  gra .print( keyword,  w3,  h5 )

  gra .setFont( smallFont )
  gra .setColor( ltBlue )
  gra .print( 'CTRL+F10  releases mouse from DOSBox.',  lpad,  dpad -smallFontSize )
end -- Lo .draw()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .quit()
  print('Löve app exit')
end -- Lo .quit()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

