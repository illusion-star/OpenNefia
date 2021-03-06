local IHud = require("api.gui.hud.IHud")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiBar = require("api.gui.hud.UiBar")
local UiBuffs = require("api.gui.hud.UiBuffs")
local UiClock = require("api.gui.hud.UiClock")
local UiFpsCounter = require("api.gui.hud.UiFpsCounter")
local UiGoldPlatinum = require("api.gui.hud.UiGoldPlatinum")
local UiLevel = require("api.gui.hud.UiLevel")
local UiMessageWindow = require("api.gui.hud.UiMessageWindow")
local UiMinimap = require("api.gui.hud.UiMinimap")
local UiStatsBar = require("api.gui.hud.UiStatsBar")
local UiStatusEffects = require("api.gui.hud.UiStatusEffects")
local UiSkillTracker = require("api.gui.hud.UiSkillTracker")
local WidgetContainer = require("api.gui.WidgetContainer")
local save = require("internal.global.save")

local MainHud = class.class("MainHud", IHud)
MainHud:delegate("input", IInput)

function MainHud:init()
   self.input = InputHandler:new()

   self.widgets = WidgetContainer:new()

   self.widgets:add(UiMessageWindow:new(), "hud_message_window")
   self.widgets:add(UiStatusEffects:new(), "hud_status_effects")
   self.widgets:add(UiClock:new(), "hud_clock")
   self.widgets:add(UiSkillTracker:new(), "hud_skill_tracker")
   self.widgets:add(UiGoldPlatinum:new(), "hud_gold_platinum")
   self.widgets:add(UiLevel:new(), "hud_level")
   self.widgets:add(UiStatsBar:new(), "hud_stats_bar")
   self.widgets:add(UiMinimap:new(), "hud_minimap")
   self.widgets:add(UiBuffs:new(), "hud_buffs")

   local position, refresh
   position = function(self, x, y, width, height)
      return math.floor((width - 84) / 2) - 100, height - (72 + 16) - 12
   end
   refresh = function(self, player)
      self:set_data(player.hp, player:calc("max_hp"))
   end
   self.widgets:add(UiBar:new("hud_hp_bar", 0, 0, true), "hud_hp_bar", { position = position, refresh = refresh })

   position = function(self, x, y, width, height)
      return math.floor((width - 84) / 2) + 40, height - (72 + 16) - 12
   end
   refresh = function(self, player)
      self:set_data(player.mp, player:calc("max_mp"))
   end
   self.widgets:add(UiBar:new("hud_mp_bar", 0, 0, true), "hud_mp_bar", { position = position, refresh = refresh })

   self.widgets:add(UiFpsCounter:new(), "fps_counter")
end

function MainHud:make_keymap()
   return {}
end

function MainHud:relayout(x, y, width, height)
   self.width = width or self.width
   self.height = height or self.height
   self.x = x or self.x
   self.y = y or self.y

   self.widgets:relayout(self.x, self.y, self.width, self.height)
end

function MainHud:refresh(player)
   if player == nil then
      return
   end

   self.widgets:refresh(player)
end

function MainHud:draw()
   self.widgets:draw()
end

function MainHud:update(dt)
   self.widgets:update(dt)

   if self.widgets.updated and self.x then
      self.widgets:relayout(self.x, self.y, self.width, self.height)
      self.widgets.updated = false
   end
end

return MainHud
