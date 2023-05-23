local json = require("src.util.json")
local overworld_sprite_sheet = love.graphics.newImage("assets/overworld_sprite_sheet.png")
local function read_map(map_file)
  local f = io.open(map_file)
  local data = f:read("*all")
  local map_json = json.decode(data)
  f:close()
  return {["sprite-layer"] = (map_json.layers[1]).data, height = map_json.height, width = map_json.width, ["tile-height"] = map_json.tileheight, ["tile-width"] = map_json.tilewidth}
end
local area_x50_y50 = read_map("src/map/area_50_50.tmj")
local sprite_sheet_column_count = 9
local column_count = 16
local tile_width = 16
local tile_height = 16
local tileset_margin = 1
local tileset_spacing = 1
local function to_tiles(tiles, _tile_idx_3f, _all_tiles_3f)
  local tile_idx = (_tile_idx_3f or 1)
  local tile = tiles[tile_idx]
  local all_tiles = (_all_tiles_3f or {})
  if (nil == tile) then
    return all_tiles
  else
    local sprite_row_zidx = math.floor(((tile - 1) / sprite_sheet_column_count))
    local sprite_col_zidx = (math.fmod(tile, sprite_sheet_column_count) - 1)
    local map_row_zidx = math.floor(((tile_idx - 1) / column_count))
    local map_col_zidx = math.fmod((tile_idx - 1), column_count)
    local x = (map_col_zidx * tile_width)
    local y = (map_row_zidx * tile_height)
    local x_offset = (tileset_margin + ((tileset_spacing * sprite_col_zidx) + (tile_height * sprite_col_zidx)))
    local y_offset = (tileset_margin + ((tileset_spacing * sprite_row_zidx) + (tile_width * sprite_row_zidx)))
    do end (all_tiles)[tile_idx] = {quad = love.graphics.newQuad(x_offset, y_offset, tile_width, tile_height, overworld_sprite_sheet:getDimensions()), tile = tile, ["tile-width"] = tile_width, ["tile-height"] = tile_height, x = x, y = y}
    return to_tiles(tiles, (tile_idx + 1), all_tiles)
  end
end
local tiles = to_tiles((area_x50_y50)["sprite-layer"])
return {tiles = tiles, ["overworld-sprite-sheet"] = overworld_sprite_sheet}
