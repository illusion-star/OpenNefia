local IMouseInput = require("api.gui.IMouseInput")

local internal = require("internal")

local MouseHandler = class("MouseHandler", IMouseInput)

function MouseHandler:init()
   self.bindings = {}
   self.this_frame = {}
   self.forwards = nil
   self.movement = nil
end

function MouseHandler:receive_mouse_button(x, y, button, pressed)
   self.this_frame[button] = {x = x, y = y, pressed = pressed}
end

function MouseHandler:receive_mouse_movement(x, y, dx, dy)
   self.movement = {x = x, y = y, dx = dx, dy = dy}
end

function MouseHandler:bind_mouse(bindings)
   self.bindings = bindings
end

function MouseHandler:forward_to(handler)
   assert_is_an(IMouseInput, handler)
   self.forwards = handler
end

function MouseHandler:focus()
   internal.input.set_mouse_handler(self)
end

function MouseHandler:halt_input()
end

function MouseHandler:run_mouse_action(button, x, y, pressed)
   local func = self.bindings[button]
   if func then
      func(v.x, v.y, v.pressed)
   elseif self.forwards then
      self.forwards:run_mouse_action(button, x, y, pressed)
   end
end

function MouseHandler:run_mouse_movement_action(x, y, dx, dy)
   local func = self.bindings["moved"]
   if func then
      func(x, y, dx, dy)
   elseif self.forwards then
      self.forwards:run_mouse_movement_action(x, y, dx, dy)
   end
end

function MouseHandler:run_actions()
   local ran = {}
   for k, v in pairs(self.this_frame) do
      self:run_mouse_action(k, v.x, v.y, v.pressed)
   end

   if self.movement then
      self:run_mouse_movement_action(self.movement.x,
                                     self.movement.y,
                                     self.movement.dx,
                                     self.movement.dy)
   end

   self.this_frame = {}
   self.movement = nil
end

return MouseHandler
