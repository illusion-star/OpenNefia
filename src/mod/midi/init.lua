local Event = require("api.Event")
local Midi = require("mod.midi.api.Midi")
local Rand = require("api.Rand")

--local function trigger_note_on_chara_moved(chara, params)
--   if chara:is_player() then
--      local note = Rand.rnd(60) + 60
--      Midi.note_on(1, note, 90)
--   end
--end
   --
--Event.register("base.on_chara_moved", "Trigger MIDI note", trigger_note_on_chara_moved)
--
--local function trigger_note_on_damage_chara(chara, params)
--   if not chara:is_player() then
--      local note = Rand.rnd(30) + 60
--      Midi.note_on(1, note, 90, 10)
--   end
--end
   --
--Event.register("base.on_damage_chara", "Trigger MIDI note", trigger_note_on_damage_chara)
--
--Event.register("base.on_game_initialize", "Open MIDI", Midi.open)