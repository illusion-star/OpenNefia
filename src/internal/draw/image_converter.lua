local vips = require("vips")
local ffi = require("ffi")

local image_converter = class.class("image_converter")

function image_converter:init()
   self.image_cache = {}
end

local function remove_key_color(image, key_color)
   if image:bands() == 4 then
      key_color[4] = 0
   end
   local alpha = image:equal(key_color):ifthenelse(0, 255):bandor()
   return image:bandjoin(alpha)
end

--- Converts a BMP image to one usable by LÖVE.
---
--- @tparam string image_path
--- @treturn love.graphics.Image
function image_converter:convert_single(image_path, key_color)
   local vips_image = vips.Image.new_from_file(image_path)

   if key_color then
      vips_image = remove_key_color(vips_image, key_color)
   end

   vips_image = vips_image:cast("ushort")

   local buffer = vips_image:write_to_memory()
   local image_data = love.graphics.newImageData(vips_image:width(),
                                                 vips_image:height(),
                                                 "rgba16",
                                                 ffi.string(buffer))
   return love.graphics.newImage(image_data)
end

function image_converter:crop_single(image_spec, key_color)
   love.graphics.setColor(1, 1, 1)

   local image = self:get_image(image_spec.source)
   local quad = love.graphics.newQuad(image_spec.x, image_spec.y, image_spec.width, image_spec.height,
                                      image:getWidth(), image:getHeight())
   local canvas = love.graphics.newCanvas(image_spec.width, image_spec.height)
   love.graphics.setCanvas(canvas)

   love.graphics.draw(image, quad, 0, 0)

   love.graphics.setCanvas()
   local cropped = love.graphics.newImage(canvas:newImageData())
   canvas:release()

   return cropped
end

function image_converter:get_image(image_path, key_color)
   if self.image_cache[image_path] == nil then
      self.image_cache[image_path] = image_converter.convert_single(image_path, key_color)
   end

   return self.image_cache[image_path]
end

function image_converter:draw(image_path, quad, x, y, key_color)
   local image = self:get_image(image_path, key_color)
   love.graphics.draw(image, quad, x, y)
end

return image_converter
