local Anim = require("mod.elona_sys.api.Anim")
local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Map = require("api.Map")
local TreasureMapWindow = require("mod.elona.api.gui.TreasureMapWindow")
local Event = require("api.Event")
local Input = require("api.Input")
local Save = require("api.Save")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.tools.api.Itemgen")

local function per_curse_state(curse_state, doomed, cursed, none, blessed)
   if curse_state == "doomed" then
      return doomed
   elseif curse_state == "cursed" then
      return cursed
   elseif curse_state == "blessed" then
      return blessed
   end

   return none
end

data:add {
   _id = "milk",
   _type = "elona_sys.magic",
   elona_id = 1101,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         Gui.play_sound("base.atk_elec")
         if Effect.is_cursed(params.curse_state) then
            if target:is_player() then
               Gui.mes("magic.milk.cursed.self")
            else
               Gui.mes_c("magic.milk.cursed.other", "SkyBlue")
            end
         elseif target:is_player() then
            Gui.mes("magic.milk.self")
         else
            Gui.mes_c("magic.milk.other", "SkyBlue")
         end
      end

      if params.curse_state == "blessed" then
         Effect.modify_height(target, Rand.rnd(5) + 1)
      elseif Effect.is_cursed(params.curse_state) then
         Effect.modify_height(target, (Rand.rnd(5) + 1) * -1)
      end

      target.nutrition = target.nutrition + 1000 * math.floor(params.power / 100)
      if target:is_player() then
         Effect.show_eating_message(target)
      end

      Effect.apply_food_curse_state(target, params.curse_state)
      local anim = Anim.load("elona.anim_elec", target.x, target.y)
      Gui.start_draw_callback(anim)

      return true
   end
}

data:add {
   _id = "effect_ale",
   _type = "elona_sys.magic",
   elona_id = 1102,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if Effect.is_cursed(params.curse_state) then
            Gui.mes_c("magic.alcohol.cursed", "SkyBlue")
         else
            Gui.mes_c("magic.alcohol.normal", "SkyBlue")
         end
      end

      target:apply_effect("elona.drunk", params.power)
      Effect.apply_food_curse_state(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "effect_sulfuric",
   _type = "elona_sys.magic",
   elona_id = 1102,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if target:is_player() then
            Gui.mes("magic.acid.self")
         end
         Gui.mes("magic.acid.apply", target)
      end

      if target.is_pregnant then
         target.is_pregnant = false
         if target:is_in_fov() then
            Gui.mes("magic.common.melts_alien_children", target)
         end
      end

      target:damage_hp(params.power * per_curse_state(params.curse_state, 500, 400, 100, 50) / 1000,
                       "elona.acid",
                       {element="elona.acid", element_power=params.power})

      return true
   end
}

data:add {
   _id = "effect_water",
   _type = "elona_sys.magic",
   elona_id = 1103,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if target:is_player() then
            Gui.mes("magic.water.self")
         else
            Gui.mes("magic.water.other")
         end
      end

      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "effect_soda",
   _type = "elona_sys.magic",
   elona_id = 1146,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         Gui.mes("magic.restore_stamina.dialog")
         Gui.mes("magic.restore_stamina.apply", target)
      end

      target:heal_stamina(25)
      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "effect_cupsule",
   _type = "elona_sys.magic",
   elona_id = 1147,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         Gui.mes("magic.restore_stamina_greater.dialog")
         Gui.mes("magic.restore_stamina_greater.apply", target)
      end

      target:heal_stamina(100)
      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "effect_dirty_water",
   _type = "elona_sys.magic",
   elona_id = 1130,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if target:is_player() then
            Gui.mes("magic.dirty_water.self")
         else
            Gui.mes("magic.dirty_water.other")
         end
      end

      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "effect_love_potion",
   _type = "elona_sys.magic",
   elona_id = 1135,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      if Effect.is_cursed(params.curse_state) then
         if params.target:is_player() then
         else
            Gui.mes("magic.love_potion.cursed", params.target)
            Skill.modify_impression(params.target, -15)
         end
         return true, { obvious = false }
      end

      local function love_miracle(chara)
         if Rand.one_in(2) or chara:is_player() then
            return
         end
         Gui.mes_c("misc.love_miracle.uh", "SkyBlue")
         if Rand.one_in(2) then
            local item = Item.create("elona.egg", chara.x, chara.y, {}, chara:current_map())
            if item then
               item.params = { chara_id = chara._id }
               local weight = chara:calc("weight")
               item.weight = weight * 10 + 250
               item.value = math.clamp(math.floor(weight * weight / 10000), 200, 40000)
            end
         else
            local item = Item.create("elona.bottle_of_milk", chara.x, chara.y, {}, chara:current_map())
            if item then
               item.params = { chara_id = chara._id }
            end
         end

         Gui.play_sound("base.atk_elec")
         local anim = Anim.load("elona.anim_elec", chara.x, chara.y)
         Gui.start_draw_callback(anim)
      end

      params.target:set_emotion_icon("elona.heart", 3)

      if params.triggered_by == "potion_spilt" or params.triggered_by == "potion_thrown" then
         Gui.mes("magic.love_potion.spill", params.target)
         Skill.modify_impression(params.target, math.clamp(params.power / 15, 0, 15))
         params.target:apply_effect("elona.dimming", 100)
         love_miracle(params.target)
         return true
      end

      if params.target:is_player() then
         Gui.mes("magic.love_potion.self", params.target)
      else
         Gui.mes("magic.love_potion.other", params.target)
         love_miracle(params.target)
         Skill.modify_impression(params.target, math.clamp(params.power / 4, 0, 25))
      end

      params.target:apply_effect("elona.dimming", 500)
      return true
   end
}

local function find_treasure_location(map)
   local cardinal = {
      {  1,  0 },
      { -1,  0 },
      {  0,  1 },
      {  0, -1 },
   }

   local point = function()
      local tx = 4 + Rand.rnd(map:width() - 8)
      local ty = 3 + Rand.rnd(map:width() - 6)
      return tx, ty
   end

   local filter = function(tx, ty)
      -- TODO
      if map.id == "elona.north_tyris" then
         if tx >= 50 and ty >= 39 and tx <= 73 and ty <= 54 then
            return false
         end
      end

      for _, pos in ipairs(cardinal) do
         local tile = map:tile(tx + pos[1], ty + pos[2])
         if tile.field_type == "elona.sea" or tile.is_solid then
            return false
         end
      end

      return true
   end

   return fun.tabulate(point):take(1000):filter(filter):nth(1)
end

data:add {
   _id = "effect_treasure_map",
   _type = "elona_sys.magic",
   elona_id = 1136,

   type = "effect",
   params = {
      "source",
      "item",
   },

   cast = function(self, params)
      local source = params.source
      local item = params.item
      local map = params.source:current_map()
      if not Map.is_world_map(map) then
         Gui.mes("magic.map.need_global_map")
         --return true
      end

      if Effect.is_cursed(params.curse_state) and Rand.one_in(5) then
         Gui.mes("magic.map.cursed")
         item.amount = item.amount - 1
         local item_map = item:current_map()
         if item_map then
            item_map:refresh_tile(item.x, item.y)
         end
         return true
      end

      local item_map = item:containing_map()
      if item.params.treasure_map == nil then
         item:separate()

         local tx, ty = find_treasure_location(item_map)
         if tx then
            item.params.treasure_map = { x = tx, y = ty }
         end
      end

      Gui.mes("magic.map.apply")

      TreasureMapWindow:new(item_map,
                            item.params.treasure_map.x,
                            item.params.treasure_map.y)
         :query()

      return true
   end
}

local function proc_treasure_map(map, params)
   local chara = params.chara
   local _type = params.type

   local filter = function(item)
      return item._id == "elona.treasure_map"
         and type(item.params.treasure_map) == "table"
         and item.params.treasure_map.x == chara.x
         and item.params.treasure_map.y == chara.y
   end
   local treasure_map = chara:iter_inventory():filter(filter):nth(1)

   if treasure_map then
      Gui.play_sound("base.chest1")
      Gui.mes_c("activity.dig_spot.something_is_there", "Yellow")
      Input.query_more()
      Gui.play_sound("base.ding2")

      Item.create("elona.small_medal", chara.x, chara.y, { amount = 2 + Rand.rnd(2) }, map)
      Item.create("elona.platinum_coin", chara.x, chara.y, { amount = 1 + Rand.rnd(3) }, map)
      Item.create("elona.gold_piece", chara.x, chara.y, { amount = Rand.rnd(10000) + 20001 }, map)
      for i = 1, 4 do
         local level = Calc.calc_object_level(chara:calc("level") + 10, map)
         local quality = Calc.calc_object_quality(Enum.Quality.Great)
         if i == 1 then
            quality = Enum.Quality.Godly
         end
         local category = Rand.choice(Filters.fsetchest)
         Itemgen.create(chara.x, chara.y, { level = level, quality = quality, categories = {category} }, map)
      end

      Gui.mes("common.something_is_put_on_the_ground")
      treasure_map.amount = treasure_map.amount - 1
      Save.save_game() -- TODO autosave
   end
end

Event.register("elona.on_search_finish", "Proc treasure map", proc_treasure_map)

data:add {
   _id = "effect_salt",
   _type = "elona_sys.magic",
   elona_id = 1142,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      if target.race == "elona.snail" then
         if target:is_in_fov() then
            Gui.mes_c("magic.salt.snail", "Red", target)
         end
         if target.hp > 10 then
            target:damage_hp(target.hp - Rand.rnd(10), "elona.acid")
         else
            target:damage_hp(Rand.rnd(20000), "elona.acid")
         end
      elseif target:is_in_fov() then
         Gui.mes_c("magic.salt.apply", "SkyBlue")
      end

      return true
   end
}

data:add {
   _id = "effect_elixir",
   _type = "elona_sys.magic",
   elona_id = 1120,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      Gui.mes_c("magic.prayer", "Yellow", target)

      target:set_effect_turns("elona.poison", 0)
      target:set_effect_turns("elona.sleep", 0)
      target:set_effect_turns("elona.confusion", 0)
      target:set_effect_turns("elona.blindness", 0)
      target:set_effect_turns("elona.paralysis", 0)
      target:set_effect_turns("elona.choking", 0)
      target:set_effect_turns("elona.dimming", 0)
      target:set_effect_turns("elona.drunk", 0)
      target:set_effect_turns("elona.bleeding", 0)
      target:set_effect_turns("elona.sleep", 0)
      target.hp = target:calc("max_hp")
      target.mp = target:calc("max_mp")
      target.stamina = target:calc("max_stamina")

      local cb = Anim.heal(target.x, target.y, "base.heal_effect", "base.heal1")
      Gui.start_draw_callback(cb)

      return true
   end
}
