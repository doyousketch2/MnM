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

local cBlue  = {  62,  49, 162 }
local ltBlue = { 124, 112, 218 }
local white  = { 255, 255, 255 }

local smallFontSize   = 16
local mediumFontSize  = 20
local largeFontSize   = 30
local xlargeFontSize  = 35

local page  = 4
local entry  = 1
local codes    = require 'data.codes'
local elements   = require 'data.elements'
local attributes  = require 'data.attributes'
local metals    = require 'data.metals'
local items   = require 'data.items'

local line   = codes[page] [entry] [1]
local word    = codes[page] [entry] [2]
local keyword  = codes[page] [entry] [3]

            -- name, attr, bonus, damage
local elem  = {  { '',  '',  0,  0 },
                 { '',  '',  0,  0 }  }

             -- name, attr, bonus
local attr  = {  { '',  '',  0 },
                 { '',  '',  0 }  }

             -- name, toHit, dmg, AC
local metal  = {  { '',  0,  0,  0 },
                  { '',  0,  0,  0 }  }

            -- name, min, max, equip, restrict
local item  = {  { '',  0,  0,  1,  '' },
                 { '',  0,  0,  1,  '' }  }

local pad  = 15  -- border padding
local lpad  = pad      local rpad  = WW -pad -- left, right
local upad  = pad      local dpad  = HH -pad -- up, down

local styles  = {  'Armor', 'Wearables', '1h Weapons', '2h Weapons', 'Missile', 'Jewelry', 'Misc'  }
local style  = styles[1]

local states  = { 'keyword', 'compare' } -- game state
local state  = states[1]               --  press space to change

local Min1  = 0        local Max1  = 0
local Min2  = 0        local Max2  = 0
local AC1  = 0         local AC2  = 0
local Qual1  = 0       local Qual2  = 0
local Bonus1  = 0      local Bonus2  = 0
local Elem1  = 0       local Elem2  = 0
local Resist1  = 0     local Resist2  = 0
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function minMax( value,  min,  max )
  if value < min  then  value  = min  end
  if value > max  then  value  = max  end
  return value
end

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

key .setKeyRepeat( true ) -- hold key to repeat?  system determines interval

function Lo .keypressed( key, scancode, isrepeat )
  if scancode == 'escape'  then  eve .quit()  end

  if scancode == 'space'  then
    if state == states[#states]  then  state = states[1] -- if last,  jump to beginning
    else   s = 1
      while state ~= states[s]  do  s  = s +1  end -- scroll through list 'till find match
      state  = states[s +1] -- pick next entry
    end -- if state ==
  end -- if scancode == 'space'

  if scancode == 'left'  then  page  = page -1  end
  if scancode == 'right' then  page  = page +1  end

  page  = minMax(  page,  4,  32  ) -- MM3 codes begin on page 4 and end on page 32

  if scancode == 'up'   then  entry  = entry -1  end
  if scancode == 'down' then  entry  = entry +1  end

  entry  = minMax(  entry,  1,  #codes[page]  ) -- don't go < 1  or  > # of pages in code list

  line   = codes[page] [entry] [1]
  word    = codes[page] [entry] [2]
  keyword  = codes[page] [entry] [3]
end -- Lo .keypressed

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function scroll(  type,  num,  dir  ) -- needs to populate qualities and values lists
  if  type == 'elem' then
    list  = elements
    currentVal  = elem[num] [1]
  elseif type == 'attr' then
    list  = attributes
    currentVal  = attr[num] [1]
  elseif type == 'metal' then
    list  = metals
    currentVal  = metal[num] [1]
  else -- type == 'item'
    list  = items[style]
    currentVal  = item[num] [1]
  end -- if type ==

  local found = 0
  if dir == 'up' then

    if currentVal == list[1] [1] then
      num = 0 -- can't scroll beyond beginning
    else  v = #list                                  -- begin at end of list
      while currentVal ~= list[v] [1] do  v = v -1  end -- find item
      found  = list[v -1] -- because we're scrolling up,  pick previous item
    end -- if currentVal

  else -- scrolling down

    if currentVal == list[#list] [1] then
      num  = 0 -- can't scroll beyond end
    else  v = 1                                         -- begin
      while currentVal ~= list[v] [1] do  v = v +1  end -- find item in list
      found  = list[v +1] -- because we're scrolling down,  pick next item
    end -- if currentVal

  end -- if dir ==
  if num > 0 then -- only do if a change was found
    if  type == 'elem' then
      elem[num] [1]  = found[1] -- name
      elem[num] [2]  = found[2] -- attr
      elem[num] [3]  = found[3] -- bonus
      elem[num] [4]  = found[4] -- damage
    elseif type == 'attr' then
      attr[num] [1]  = found[1] -- name
      attr[num] [2]  = found[2] -- attr
      attr[num] [3]  = found[3] -- bonus
    elseif type == 'metal' then
      metal[num] [1]  = found[1] -- name
      metal[num] [2]  = found[2] -- toHit
      metal[num] [3]  = found[3] -- dmg
      metal[num] [4]  = found[4] -- AC
    else -- type == 'item'
      item[num] [1]  = found[1] -- name
      item[num] [2]  = found[2] -- min modifier
      item[num] [3]  = found[3] -- max mod, if used
      item[num] [4]  = found[4] -- equip 1H / 2H
      item[num] [5]  = found[5] -- restrict
    end -- if type ==
  end -- if num > 0
end -- feunction scroll()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .wheelmoved( x, y )
  local xx = mou .getX()
  local yy = mou .getY()
  if y > 0 then -- wheel up

    if yy < h5 then -- upper half of screen
      if xx < w25    then  scroll(  'elem',  1,  'up'  )
      elseif xx < w5  then  scroll(  'attr',  1,  'up'  )
      elseif xx < w66  then  scroll(  'metal',  1,  'up'  )
      else                     scroll(  'item',  1,  'up'  )
      end -- if xx <
    else -- lower half of screen
      if xx < w25    then  scroll(  'elem',  2,  'up'  )
      elseif xx < w5  then  scroll(  'attr',  2,  'up'  )
      elseif xx < w66  then  scroll(  'metal',  2,  'up'  )
      else                     scroll(  'item',  2,  'up'  )
      end -- if xx <
    end -- if yy > h5

  elseif y < 0 then -- wheel down

    if yy < h5 then -- upper half of screen
      if xx < w25    then  scroll(  'elem',  1,  'down'  )
      elseif xx < w5  then  scroll(  'attr',  1,  'down'  )
      elseif xx < w66  then  scroll(  'metal',  1,  'down'  )
      else                     scroll(  'item',  1,  'down'  )
      end -- if xx <
    else -- lower half of screen
      if xx < w25    then  scroll(  'elem',  2,  'down'  )
      elseif xx < w5  then  scroll(  'attr',  2,  'down'  )
      elseif xx < w66  then  scroll(  'metal',  2,  'down'  )
      else                     scroll(  'item',  2,  'down'  )
      end -- if xx <
    end -- if yy > h5

  end -- if y > 0
end -- Lo .wheelmoved()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .mousepressed( x, y, button, istouch )
  if x > w75 and y < w1 then -- clicked top-right corner
    if style == styles[#styles]  then  style = styles[1] -- if last, loop back to beginning
    else s = 1                                         -- start at the beginning
      while style ~= styles[s] do s = s +1 end       -- loop 'till we find match
      style  = styles[s +1]                        -- chose next style
    end -- if style ==
      item[1] [1]  = items[style] [2] [1] -- name
      item[1] [2]  = items[style] [2] [2] -- min modifier
      item[1] [3]  = items[style] [2] [3] -- max mod, if used
      item[1] [4]  = items[style] [2] [4] -- equip 1H / 2H
      item[1] [5]  = items[style] [2] [5] -- restrict

      item[2] [1]  = items[style] [2] [1] -- name
      item[2] [2]  = items[style] [2] [2] -- min modifier
      item[2] [3]  = items[style] [2] [3] -- max mod, if used
      item[2] [4]  = items[style] [2] [4] -- equip 1H / 2H
      item[2] [5]  = items[style] [2] [5] -- restrict
  end -- if x and y
end -- Lo .mousepressed()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .update( dt )

  Qual1  = attr[1] [2]
  Qual2  = attr[2] [2]

  Bonus1  = attr[1] [3]
  Bonus2  = attr[2] [3]

  Elem1  = elem[1] [2]
  Elem2  = elem[2] [2]

  Resist1  = elem[1] [3]
  Resist2  = elem[2] [3]

  local metalBonus1  = metal[1] [4]
  local metalBonus2  = metal[2] [4]

  if style == '1h Weapons' or style == '2h Weapons' or style == 'Missile' then

    local itemBonus1  = item[1] [2]
    local itemBonus2  = item[2] [2]

    local elemBonus1  = elem[1] [4]
    local elemBonus2  = elem[2] [4]

    Min1  = item[1] [2] +itemBonus1 +elemBonus1 +metalBonus1
    Min2  = item[2] [2] +itemBonus1 +elemBonus2 +metalBonus2

    Max1  = item[1] [3] +itemBonus1 +elemBonus1 +metalBonus1
    Max2  = item[2] [3] +itemBonus1 +elemBonus2 +metalBonus2

  else -- not a weapon

    local ACbonus1  = 0
    local ACbonus2  = 0

    if Qual1 == 'Armor Class' then
      ACbonus1  = Bonus1
      Bonus1  = 0
    end

    if Qual2 == 'Armor Class' then
      ACbonus2  = Bonus2
      Bonus2  = 0
    end

    AC1  = item[1] [2] + metalBonus1 + ACbonus1
    AC2  = item[2] [2] + metalBonus2 + ACbonus2

  end -- if style == weapon
end -- Lo .update()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .draw()

  if state == 'keyword'  then

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
    gra .print( 'Line:  ',   w3,  yy )
    gra .print( 'Word:  ',    w5,  yy )
    gra .print( 'Keyword:  ',  w1,  h5 +15 )

    gra .setColor( white )
    gra .setFont( largeFont )
    gra .print( page,  w2,  h2 )
    gra .print( line,  w4,  h2 )
    gra .print( word,  w6 +10,  h2 )

    gra .setFont( xlargeFont )
    gra .print( keyword,  w3,  h5 )

    gra .setFont( smallFont )
    gra .setColor( ltBlue )
    gra .print( 'CTRL+F10  releases mouse from DOSBox.',  lpad,  dpad -smallFontSize )

  elseif state == 'compare'  then

    gra .setColor( ltBlue )
    gra .setFont( mediumFont )
    gra .print( style,  w75,  upad  )
    gra .line( w1, h5,  w9, h5 ) -- centerline,  rest is somewhat symmetrical

    gra .line( w25, h25,  w25, h3 )
    gra .line( w5,  h25,   w5, h3 )
    gra .line( w66, h25,  w66, h3 )

    gra .setColor( white )
    gra .print( elem[1] [1],   lpad,    h25 )
    gra .print( attr[1] [1],   w25 +5,  h25 )
    gra .print( metal[1] [1],  w5 +5,   h25 )
    gra .print( item[1] [1],   w66 +5,  h25 )

    gra .print( elem[2] [1],   lpad,    h7 )
    gra .print( attr[2] [1],   w25 +5,  h7 )
    gra .print( metal[2] [1],  w5 +5,   h7 )
    gra .print( item[2] [1],   w66 +5,  h7 )
    gra .setColor( ltBlue )

    gra .line( w25, h7,  w25, h75 )
    gra .line( w5,  h7,   w5, h75 )
    gra .line( w66, h7,  w66, h75 )

    if style == '1h Weapons' or style == '2h Weapons' or style == 'Missile' then
      gra .print( 'Min:  ' ..Min1,  w6,  h4 +10  )
      gra .print( 'Max:  ' ..Max1,  w8,  h4 +10  )

      gra .print( 'Min:  ' ..Min2,  w6,  h5 +10  )
      gra .print( 'Max:  ' ..Max2,  w8,  h5 +10  )
    else
      gra .print( 'AC:  ' ..AC1,  w8,  h4 +10  )

      gra .print( 'AC:  ' ..AC2,  w8,  h5 +10  )
    end -- if style == weapons

    if Resist1 > 0 then
      gra .print( 'Resistance:  ' ..Resist1,  lpad,  h1 +10  )
      gra .print( '   Element:  ' ..Elem1,  lpad,  h1 -20  )
    end -- if Resist1 > 0

    if Bonus1 > 0 then
      gra .print( 'Quality:  ' ..Qual1,  lpad,  h4 -20  )
      gra .print( '  Bonus:  ' ..Bonus1,  lpad,  h4 +10  )
    end -- if Bonus1 > 0

    if Bonus2 > 0 then
      gra .print( '  Bonus:  ' ..Bonus2,  lpad,  h5 +10  )
      gra .print( 'Quality:  ' ..Qual2,  lpad,  h5 +40  )
    end -- if Bonus2 > 0

    if Resist2 > 0 then
      gra .print( 'Resistance:  ' ..Resist2,  lpad,  h8 +10  )
      gra .print( '   Element:  ' ..Elem2,  lpad,  h8 +40  )
    end -- if Resist1 > 0

  end -- if state ==
end -- Lo .draw()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .quit()
  print('Löve app exit')
end -- Lo .quit()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

