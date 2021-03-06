local Const = {}

--- Number of hours before killed citizens are respawned.
Const.CITIZEN_RESPAWN_HOURS = 48

Const.MAX_CHARAS_ALLY = 16
Const.MAX_CHARAS_ADVENTURER = 40
Const.MAX_CHARAS_SAVED = Const.MAX_CHARAS_ALLY + Const.MAX_CHARAS_ADVENTURER
Const.MAX_CHARAS = 245
Const.MAX_CHARAS_OTHER = Const.MAX_CHARAS - Const.MAX_CHARAS_SAVED

Const.KARMA_BAD = -30
Const.KARMA_GOOD = 20

Const.MAP_RENEW_MAJOR_HOURS = 120
Const.MAP_RENEW_MINOR_HOURS = 24

Const.RESIST_GRADE = 50

Const.MAX_ENCHANTMENTLEVEL = 4
Const.MAX_ENCHANTMENTS = 15

Const.WEAPON_WEIGHT_LIGHT = 1500
Const.WEAPON_WEIGHT_HEAVY = 4000

Const.FATIGUE_HEAVY = 0
Const.FATIGUE_MODERATE = 25
Const.FATIGUE_LIGHT = 50

Const.MAX_SKILL_LEVEL = 2000
Const.MAX_SKILL_POTENTIAL = 400
Const.MAX_SKILL_EXPERIENCE = 1000
Const.POTENTIAL_DECAY_RATE = 0.9

-- >>>>>>>> shade2/init.hsp:88 	#define global initYear		517 ..
Const.INITIAL_YEAR = 517
Const.INITIAL_MONTH = 8
Const.INITIAL_DAY = 12
-- <<<<<<<< shade2/init.hsp:90 	#define global initDay		12 ..

Const.SKILL_POINT_EXPERIENCE_GAIN = 400

-- >>>>>>>> elona122/shade2/init.hsp:19 	#define global defImpEnemy	0 ..
Const.IMPRESSION_ENEMY = 0
Const.IMPRESSION_HATE = 25
Const.IMPRESSION_NORMAL = 50
Const.IMPRESSION_PARTY = 53
Const.IMPRESSION_AMIABLE = 75
Const.IMPRESSION_FRIEND = 100
Const.IMPRESSION_FELLOW = 150
Const.IMPRESSION_MARRY = 200
Const.IMPRESSION_SOULMATE = 300
-- <<<<<<<< elona122/shade2/init.hsp:27 	#define global defImpSoulMate	300 ..

return Const
