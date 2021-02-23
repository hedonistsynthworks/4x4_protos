--- 4x4 Protos
---

local BeatClock = require 'beatclock'
local MusicUtil = require "musicutil"

local clk = BeatClock.new()

engine.name = "Timber"

g = grid.connect()
m = midi.connect()

function reset_grid_before_draw()
  g:all(0)
  
  for x = 1,4 do
    g:led(x, 3, 5)
    for y = 5,8 do
      g:led(x, y, 5)
    end
  end  

  for x = 13,16 do
    g:led(x, 3, 5)
    for y = 5,8 do
      g:led(x, y, 5)
    end
  end  
end

reset_grid_before_draw()
g:refresh()

-- 4x5 sequencer boio
--[[

A B C D 
1 2 3 4
5 6 7 8
9 101112
13141516

Letters select channel, A-C are gates (drum samples here) and D is melody gate+cv (synth engine here)

Melody channel has modal input, press step then press note

--]]


local grid_1_state = {
  channels = {
    {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
    {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
    {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  },
  note_entry = false,
  current_channel = 1,
  position = 1
}

function configure_sampler()
  engine.loadSample(1, _path.dust.."/audio/common/909/909-BD.wav")
  engine.loadSample(2, _path.dust.."/audio/common/909/909-CP.wav")
  engine.loadSample(3, _path.dust.."/audio/common/909/909-CH.wav")
  for i = 1,3 do
    engine.playMode(i, 3)
    engine.ampAttack(i, 0)
  end
end

function grid_1_light_step(step, on_brightness)
  dec = step - 1
  x = dec % 4
  y = math.floor((dec - x) / 4)
  brightness = 0
  if step == grid_1_state.position
  then
    brightness = 8
  elseif grid_1_state.current_channel <= 3 and grid_1_state.channels[grid_1_state.current_channel][step]
  then
    brightness = on_brightness
  end
  g:led(x + 1, y + 5, brightness)
end

function grid_1_light_steps()
  for i = 1,16 do
    grid_1_light_step(i, 15)
  end
end

function grid_1_draw()
  reset_grid_before_draw()
  g:led(grid_1_state.current_channel, 3, 15)
  grid_1_light_steps()
  g:refresh()
end

function on_grid_1_channel_key(x)
  grid_1_state.current_channel = x
end

function on_grid_1_step_key(step)
  if grid_1_state.current_channel <= 3 then
    grid_1_state.channels[grid_1_state.current_channel][step] = not grid_1_state.channels[grid_1_state.current_channel][step]
  end
end

function on_grid_1_key(x,y,z)
  if y == 3 
  then
    on_grid_1_channel_key(x)
  else
    step = ((y - 5) * 4) + x
    on_grid_1_step_key(step)
  end
  grid_1_draw()
end

function on_grid_2_key(x,y,z)
end

g.key = function(x,y,z) 
  if z == 0 and x <= 4 and (y == 3 or y >= 5) then
    on_grid_1_key(x,y,z)
  end

  if z == 0 and x >= 13 and (y == 3 or y >= 5) then
    on_grid_2_key(x,y,z)
  end

end

function play(position)
  for track = 1,3 do
    if grid_1_state.channels[track][position]
    then
      engine.noteOn(track, MusicUtil.note_num_to_freq(60), 127, track)
    end
  end
end

function step()
  grid_1_state.position = (grid_1_state.position % 16) + 1
  grid_1_draw()
  play(grid_1_state.position)
end

function init()
  configure_sampler()
  clk:add_clock_params()
  clk.on_step = step

  clk:start()
end