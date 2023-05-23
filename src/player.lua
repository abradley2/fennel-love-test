local _player_sprite_sheet = love.graphics.newImage("assets/player_sprite_sheet.png")
local _player_sprite_quads = {down = {love.graphics.newQuad(0, 0, 16, 16, _player_sprite_sheet:getDimensions()), love.graphics.newQuad(0, 30, 16, 16, _player_sprite_sheet:getDimensions())}, left = {love.graphics.newQuad(30, 0, 16, 16, _player_sprite_sheet:getDimensions()), love.graphics.newQuad(30, 30, 16, 16, _player_sprite_sheet:getDimensions())}, up = {love.graphics.newQuad(60, 0, 16, 16, _player_sprite_sheet:getDimensions()), love.graphics.newQuad(60, 30, 16, 16, _player_sprite_sheet:getDimensions())}, right = {love.graphics.newQuad(90, 30, 16, 16, _player_sprite_sheet:getDimensions()), love.graphics.newQuad(90, 0, 16, 16, _player_sprite_sheet:getDimensions())}}
local function _init_player_state()
  return {x = 0, y = 0, direction = "down", ["direction-delta"] = 0, ["delta-per-frame"] = 8, speed = 2, ["sprite-quad"] = _player_sprite_quads.down[1], moving = false}
end
local _player_state = _init_player_state()
local function choose_sprite_quad(sprite_quads, delta, delta_per_frame)
  local cur_frame = (1 + math.floor((delta / delta_per_frame)))
  if sprite_quads[cur_frame] then
    return {sprite_quads[cur_frame], delta}
  else
    return choose_sprite_quad(sprite_quads, 0, delta_per_frame)
  end
end
local function run_player_state(speed, player_state, player_sprite_quads, keyboard)
  do
    local _let_2_ = choose_sprite_quad(player_sprite_quads[player_state.direction], player_state["direction-delta"], player_state["delta-per-frame"])
    local sprite_quad = _let_2_[1]
    local next_delta = _let_2_[2]
    player_state["direction-delta"] = next_delta
    player_state["sprite-quad"] = sprite_quad
  end
  if player_state.moving then
    player_state["direction-delta"] = (player_state["direction-delta"] + speed)
    local _3_ = player_state.direction
    if (_3_ == "up") then
      player_state["y"] = (player_state.y - speed)
    elseif (_3_ == "down") then
      player_state["y"] = (player_state.y + speed)
    elseif (_3_ == "left") then
      player_state["x"] = (player_state.x - speed)
    elseif (_3_ == "right") then
      player_state["x"] = (player_state.x + speed)
    else
    end
  else
  end
  return player_state
end
local function handle_player_movement(player_state, key)
  do
    local _6_ = key
    if (_6_ == "up") then
      player_state["moving"] = true
      player_state["direction"] = "up"
      player_state["direction-delta"] = 0
    elseif (_6_ == "down") then
      player_state["moving"] = true
      player_state["direction"] = "down"
      player_state["direction-delta"] = 0
    elseif (_6_ == "left") then
      player_state["moving"] = true
      player_state["direction"] = "left"
      player_state["direction-delta"] = 0
    elseif (_6_ == "right") then
      player_state["moving"] = true
      player_state["direction"] = "right"
      player_state["direction-delta"] = 0
    else
    end
  end
  return player_state
end
return {["player-sprite-sheet"] = _player_sprite_sheet, ["player-sprite-quads"] = _player_sprite_quads, ["player-state"] = _player_state, ["choose-sprite-quad"] = choose_sprite_quad, ["run-player-state"] = run_player_state, ["handle-player-movement"] = handle_player_movement}
