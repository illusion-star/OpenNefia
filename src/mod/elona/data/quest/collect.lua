local Gui = require("api.Gui")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Quest = require("mod.elona_sys.api.Quest")
local Event = require("api.Event")
local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Itemgen = require("mod.tools.api.Itemgen")
local Filters = require("mod.elona.api.Filters")
local I18N = require("api.I18N")

local collect = {
   _id = "collect",
   _type = "elona_sys.quest",

   elona_id = 1011,
   ordering = 10000,
   client_chara_type = 3,
   reward = "elona.supply",
   reward_fix = 60,

   min_fame = 0,
   chance = 14,

   params = {
      target_chara_uid = "number",
      target_name = "string",
      target_item_id = "string"
   },

   difficulty = function()
      return Chara.player():calc("level") / 3
   end,

   deadline_days = function() return Rand.rnd(3) + 2 end,

   generate = function(self, client, start, map)
      local target_chara, target_item

      local charas = Rand.shuffle(map:iter_charas():to_list())

      for _, chara in ipairs(charas)  do
         if chara.uid ~= client.uid then
            if Chara.is_alive(chara, map)
               and chara:base_reaction_towards(Chara.player()) > 0
               and (chara:find_role("elona.guard") or chara:find_role("elona.citizen"))
            then
               local category = Rand.choice(Filters.fsetcollect)
               local item = Itemgen.create(nil, nil, { level = 40, quality = 2, categories = {category} }, chara)
               if item then
                  item.count = 0 -- TODO
                  target_chara = chara
                  target_item = item
                  break
               end
            end
         end
      end

      if not target_chara then
         return false, "No target character found."
      end

      self.params = {
         target_chara_uid = target_chara.uid,
         target_name = target_chara.name,
         target_item_id = target_item._id
      }

      return true
   end,
   locale_data = function(self)
      return {
         item_name = I18N.get("item.info." .. self.params.target_item_id .. ".name"),
         target_name = self.params.target_name
      }
   end
}
data:add(collect)

local function collect_quest_for(chara)
   local function is_quest_client(q)
      return q._id == "elona.collect" and q.client_uid == chara.uid
   end
   return Quest.iter():filter(is_quest_client):nth(1)
end

local function find_item(chara, item_id)
   return chara:iter_inventory():filter(function(i) return i._id == item_id end):nth(1)
end

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_collect",

   root = "talk.npc.quest_giver",
   nodes = {
      trade = function(t)
         Gui.mes_c("TODO", "Yellow")
      end,
      give = function(t)
         -- TODO generalize with dialog argument
         local quest = collect_quest_for(t.speaker)
         assert(quest)

         local item = find_item(Chara.player(), quest.params.target_item_id)

         Gui.mes("talk.npc.common.hand_over", item)
         local sep = assert(item:move_some(1, t.speaker))
         t.speaker.item_to_use = sep

         Chara.player():refresh_weight()

         return Quest.complete(quest, t.speaker)
      end
   }
}

local function add_collect_dialog_choice(speaker, _, choices)
   local function has_collect_quest(q)
      return q._id == "elona.collect" and q.params.target_chara_uid == speaker.uid
   end
   if Quest.iter():any(has_collect_quest) then
      Dialog.add_choice("elona.quest_collect:trade", "talk.npc.common.choices.trade", choices)
   end
   return choices
end

Event.register("elona.calc_dialog_choices", "Add trade option for character with collect quest",
               add_collect_dialog_choice, {priority = 210000})

local function add_give_dialog_choice(speaker, _, choices)
   local quest = collect_quest_for(speaker)
   if quest then
      local item = find_item(Chara.player(), quest.params.target_item_id)
      if item then
         Dialog.add_choice("elona.quest_collect:give", I18N.get("talk.npc.quest_giver.choices.here_is_item", item), choices)
      end
   end
   return choices
end

Event.register("elona.calc_dialog_choices", "Add give option for collect quest client",
               add_give_dialog_choice)
