__fnl_global__GAME_2dWIDTH, __fnl_global__GAME_2dHEIGHT = love.window.getMode()
local player = require("src.player")
local world = require("src.world")
local _keyboard = {right = false, up = false, left = false, down = false}
love.update = function(dt)
  local speed_delta = (dt / 0.0166)
  return player["run-player-state"](((player["player-state"]).speed * speed_delta), player["player-state"], player["player-sprite-quads"], _keyboard)
end
love.keypressed = function(key)
  if ("escape" == key) then
    love.event.quit()
  else
  end
  _keyboard[key] = true
  return player["handle-player-movement"](player["player-state"], key)
end
love.keyreleased = function(key)
  _keyboard[key] = false
  if ((((false or (true == _keyboard.up)) or (true == _keyboard.down)) or (true == _keyboard.left)) or (true == _keyboard.right)) then
    local function _2_()
      if _keyboard.up then
        return player["handle-player-movement"]("up")
      else
        return nil
      end
    end
    local function _4_()
      if _keyboard.down then
        return player["handle-player-movement"]("down")
      else
        return nil
      end
    end
    local function _6_()
      if _keyboard.left then
        return player["handle-player-movement"]("left")
      else
        return nil
      end
    end
    local function _8_()
      if _keyboard.right then
        return player["handle-player-movement"]("right")
      else
        return nil
      end
    end
    return ((((false or _2_()) or _4_()) or _6_()) or _8_())
  else
    player["player-state"]["moving"] = false
    player["player-state"]["direction-delta"] = 0
    return nil
  end
end
love.draw = function()
  for _, tile in pairs(world.tiles) do
    love.graphics.draw(world["overworld-sprite-sheet"], tile.quad, tile.x, tile.y, 0, 1)
  end
  return love.graphics.draw(player["player-sprite-sheet"], (player["player-state"])["sprite-quad"], (player["player-state"]).x, (player["player-state"]).y, 0, 1)
end
return love.draw
