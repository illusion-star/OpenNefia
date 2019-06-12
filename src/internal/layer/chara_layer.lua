local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local sparse_batch = require("internal.draw.sparse_batch")

local chara_layer = class("chara_layer", IDrawLayer)

function chara_layer:init(width, height)
   local coords = Draw.get_coords()
   local tile_atlas, chara_atlas, item_atlas = require("internal.global.atlases").get()

   self.chara_batch = sparse_batch:new(width, height, chara_atlas, coords)
   self.batch_inds = {}
   self.scroll = nil
   self.scroll_frames = 0
   self.scroll_max_frames = 0
   self.scroll_consecutive = 0
   self.coords = coords
end

function chara_layer:relayout()
end

function chara_layer:reset()
   self.batch_inds = {}
end

function chara_layer:calc_scroll(map)
   local scroll = {}

   for uid, dat in pairs(self.batch_inds) do
      local c = map:get_object("base.chara", uid)
      if c.x ~= dat.x or c.y ~= dat.y then
         local dx = c.x - dat.x
         local dy = c.y - dat.y

         if math.abs(dx) <= 1 and math.abs(dy) <= 1 then
            scroll[#scroll+1] = { ind = self.batch_inds[uid].ind, dx = -dx, dy = -dy}
         end

         dat.x = c.x
         dat.y = c.y
      end
   end

   return scroll
end

function chara_layer:scroll_one()
   if self.scroll_frames % 1 == 0 then
   for _, scroll in ipairs(self.scroll) do
      local p = 1 - (self.scroll_frames/self.scroll_max_frames)
      local sx, sy = (scroll.dx - (p * scroll.dx)) * 48, (scroll.dy - (p * scroll.dy)) * 48
      self.chara_batch:set_tile_offsets(scroll.ind, sx, sy)
   end
   end
   self.scroll_frames = self.scroll_frames - 1

   return self.scroll_frames == 0
end

function chara_layer:update(dt, screen_updated)
   print("upd",screen_updated,self.scroll_consecutive)
   if not screen_updated then
      self.scroll_consecutive = 0
      return false
   end

   self.chara_batch.updated = true

   local map = Map.current()
   assert(map ~= nil)

   if self.scroll then
      local finished = self:scroll_one()

      if finished then
         for _, scroll in ipairs(self.scroll) do
            self.chara_batch:set_tile_offsets(scroll.ind, 0, 0)
         end
         self.scroll = nil
         return false
      end

      -- keep scrolling
      return true
   end

   -- Calculate scroll now before the position of all character
   -- sprites are updated.
   local scroll = self:calc_scroll(map)

   for _, c in map:iter_charas() do
      local show = c.state == "Alive" and map:is_in_fov(c.x, c.y)
      local hide = not show
         and self.batch_inds[c.uid] ~= nil
         and self.batch_inds[c.uid].ind ~= 0

      if show then
         local batch_ind = self.batch_inds[c.uid]
         if batch_ind == nil or batch_ind.ind == 0 then
            local ind = self.chara_batch:add_tile {
               tile = c.image,
               x = c.x,
               y = c.y
            }
            self.batch_inds[c.uid] = { ind = ind, x = c.x, y = c.y }
         else
            local tile, px, py = self.chara_batch:get_tile(batch_ind)

            if px ~= c.x or py ~= c.y or tile ~= c.image then
               self.chara_batch:remove_tile(batch_ind.ind)
               local ind = self.chara_batch:add_tile {
                  tile = c.image,
                  x = c.x,
                  y = c.y
               }
               self.batch_inds[c.uid] = { ind = ind, x = c.x, y = c.y }
            end
         end
      elseif hide then
         self.chara_batch:remove_tile(self.batch_inds[c.uid].ind)
         self.batch_inds[c.uid] = nil
      end
   end

   if #scroll > 0 then
      self.scroll_consecutive = self.scroll_consecutive + 1
      self.scroll = scroll

      local max = 10

      self.scroll_max_frames = max
      self.scroll_frames = self.scroll_max_frames
      self:scroll_one()
      print("scrollone",self.scroll_consecutive)
      return true
   else
      self.scroll_consecutive = 0
   end

   return false
end

function chara_layer:draw(draw_x, draw_y)
   self.chara_batch:draw(draw_x, draw_y)
end

return chara_layer
