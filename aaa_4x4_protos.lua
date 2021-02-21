--- 4x4 Protos
---

local BeatClock = require 'beatclock'
local MusicUtil = require "musicutil"

local clk = BeatClock.new()

g = grid.connect()
m = midi.connect()

function reset_grid_before_draw()
  g:all(0)
  
  for x = 1,4 do
    g:led(x, 3, 2)
    for y = 5,8 do
      g:led(x, y, 2)
    end
  end  

  for x = 13,16 do
    g:led(x, 3, 2)
    for y = 5,8 do
      g:led(x, y, 2)
    end
  end  
end

reset_grid_before_draw()
g:refresh()