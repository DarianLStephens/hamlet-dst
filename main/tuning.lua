-- INTERIOR ROOM SIZES
TUNING.ROOM_TINY_WIDTH   = 15
TUNING.ROOM_TINY_DEPTH   = 10

TUNING.ROOM_SMALL_WIDTH  = 18
TUNING.ROOM_SMALL_DEPTH  = 12

TUNING.ROOM_MEDIUM_WIDTH = 24
TUNING.ROOM_MEDIUM_DEPTH = 16

TUNING.ROOM_LARGE_WIDTH  = 26
TUNING.ROOM_LARGE_DEPTH  = 18


TUNING.SCORPION_HEALTH = 200
TUNING.SCORPION_DAMAGE = 20
TUNING.SCORPION_ATTACK_PERIOD = 3
TUNING.SCORPION_TARGET_DIST = 4
TUNING.SCORPION_INVESTIGATETARGET_DIST = 6
TUNING.SCORPION_WAKE_RADIUS = 4
TUNING.SCORPION_FLAMMABILITY = .33
TUNING.SCORPION_SUMMON_WARRIORS_RADIUS = 12
TUNING.SCORPION_EAT_DELAY = 1.5
TUNING.SCORPION_ATTACK_RANGE = 3		
TUNING.SCORPION_STING_RANGE = 2		

TUNING.SCORPION_WALK_SPEED = 3
TUNING.SCORPION_RUN_SPEED = 5

TUNING.SPEAR_TRAP_HEALTH = 100
TUNING.SPEAR_TRAP_DAMAGE = TUNING.BASE_SURVIVOR_ATTACK

TUNING.SNAKE_SPEED = 3
TUNING.SNAKE_TARGET_DIST = 8
TUNING.SNAKE_KEEP_TARGET_DIST= 15
TUNING.SNAKE_HEALTH = 100
TUNING.SNAKE_DAMAGE = 10
TUNING.SNAKE_ATTACK_PERIOD = 3
TUNING.SNAKE_POISON_CHANCE = 0.25
TUNING.SNAKE_POISON_START_DAY = 3 -- the day that poison TUNING.SNAKEs have a chance to show up
TUNING.SNAKEDEN_REGEN_TIME = 3--*TUNING.SEG_TIME
TUNING.SNAKEDEN_RELEASE_TIME = 5
TUNING.SNAKE_JUNGLETREE_CHANCE = 0.5 -- chance of a normal TUNING.SNAKE
TUNING.SNAKE_JUNGLETREE_POISON_CHANCE = 0.25 -- chance of a poison TUNING.SNAKE
TUNING.SNAKE_JUNGLETREE_AMOUNT_TALL = 2 -- num of times to try and spawn a TUNING.SNAKE from a tall tree
TUNING.SNAKE_JUNGLETREE_AMOUNT_MED = 1 -- num of times to try and spawn a TUNING.SNAKE from a normal tree
TUNING.SNAKE_JUNGLETREE_AMOUNT_SMALL = 1 -- num of times to try and spawn a TUNING.SNAKE from a small tree
TUNING.SNAKEDEN_MAX_SNAKES = 3
TUNING.SNAKEDEN_CHECK_DIST = 20
TUNING.SNAKEDEN_TRAP_DIST = 2

TUNING.DECO_RUINS_BEAM_WORK = 6

TUNING.PIG_RUINS_DART_DAMAGE = TUNING.BASE_SURVIVOR_ATTACK --wilson_attack
TUNING.ROCKS_MINE_GIANT = 10

TUNING.MAGNIFYING_GLASS_DAMAGE = TUNING.BASE_SURVIVOR_ATTACK *.125
TUNING.CORK_BAT_DAMAGE = TUNING.BASE_SURVIVOR_ATTACK * 1.5
TUNING.BRUSH_DAMAGE = TUNING.BASE_SURVIVOR_ATTACK*.8
	    
TUNING.TRUSTY_SHOOTER_DAMAGE_HIGH = 60
TUNING.TRUSTY_SHOOTER_DAMAGE_MEDIUM = 45
TUNING.TRUSTY_SHOOTER_DAMAGE_LOW = TUNING.BASE_SURVIVOR_ATTACK

TUNING.TRUSTY_SHOOTER_ATTACK_RANGE_HIGH = 11
TUNING.TRUSTY_SHOOTER_ATTACK_RANGE_MEDIUM = 9
TUNING.TRUSTY_SHOOTER_ATTACK_RANGE_LOW = 7

TUNING.TRUSTY_SHOOTER_HIT_RANGE_HIGH = 13
TUNING.TRUSTY_SHOOTER_HIT_RANGE_MEDIUM = 11
TUNING.TRUSTY_SHOOTER_HIT_RANGE_LOW = 9

TUNING.TRUSTY_SHOOTER_TIERS = 
		{
			AMMO_HIGH = {
				"gears",
			    "purplegem",
				"bluegem",
				"redgem",
				"orangegem",
				"yellowgem",
				"greengem",
			    "oinc10",
			    "oinc100",
			    "nightmarefuel",
			    "gunpowder",
			    "relic_1",
			    "relic_2",
			    "relic_3",
			    "relic_4",
			    "relic_5",
			},

			AMMO_LOW = 
			{
				"feather_crow",
				"feather_robin",
				"feather_robin_winter",
				"feather_thunder",
				"ash",
				"beardhair",
				"beefalowool",
				"butterflywings",
				"clippings",
				"cutgrass",
				"cutreeds",
				"foliage",
				"palmleaf",
				"papyrus",
				"petals",
				"petals_evil",
				"pigskin",
				"silk",
				"seaweed",
			}
		}


TUNING.LITTLE_HAMMER_DAMAGE = TUNING.BASE_SURVIVOR_ATTACK*0.3
TUNING.LITTLE_HAMMER_USES = 10
TUNING.SHEARS_DAMAGE = TUNING.BASE_SURVIVOR_ATTACK * .5
TUNING.SHEARS_USES = 20

TUNING.MAGNIFYING_GLASS_USES = 10
		
TUNING.RUINS_BAT_SPEED_MULT = 0.1

TUNING.TORCH_ATTACK_IGNITE_PERCENT = 1

TUNING.SPRING_COMBAT_MOD = 1.33

TUNING.PIG_DAMAGE = 33
TUNING.PIG_HEALTH = 250
TUNING.PIG_ATTACK_PERIOD = 3
TUNING.PIG_TARGET_DIST = 16
TUNING.PIG_LOYALTY_MAXTIME = 2.5*TUNING.TOTAL_DAY_TIME
TUNING.PIG_LOYALTY_PER_HUNGER = TUNING.TOTAL_DAY_TIME/25
TUNING.PIG_MIN_POOP_PERIOD = TUNING.SEG_TIME * .5

TUNING.SPIDER_LOYALTY_MAXTIME = 2.5*TUNING.TOTAL_DAY_TIME
TUNING.SPIDER_LOYALTY_PER_HUNGER = TUNING.TOTAL_DAY_TIME/25

TUNING.WEREPIG_DAMAGE = 40
TUNING.WEREPIG_HEALTH = 350
TUNING.WEREPIG_ATTACK_PERIOD = 2

TUNING.PIG_GUARD_DAMAGE = 33
TUNING.PIG_GUARD_HEALTH = 300
TUNING.PIG_GUARD_ATTACK_PERIOD = 1.5
TUNING.PIG_GUARD_TARGET_DIST = 8
TUNING.PIG_GUARD_DEFEND_DIST = 20 

TUNING.PIG_BANDIT_DAMAGE = 33
TUNING.PIG_BANDIT_HEALTH = 250
TUNING.PIG_BANDIT_ATTACK_PERIOD = 3
TUNING.PIG_BANDIT_TARGET_DIST = 16
TUNING.PIG_BANDIT_LOYALTY_MAXTIME = 2.5*TUNING.TOTAL_DAY_TIME
TUNING.PIG_BANDIT_LOYALTY_PER_HUNGER = TUNING.TOTAL_DAY_TIME/25
TUNING.PIG_BANDIT_MIN_POOP_PERIOD = TUNING.SEG_TIME * .5
TUNING.PIG_BANDIT_TARGET_DIST = 16

TUNING.CITY_PIG_GUARD_TARGET_DIST = 20

TUNING.PIG_RUN_SPEED = 5
TUNING.PIG_WALK_SPEED = 3

TUNING.WEREPIG_RUN_SPEED = 7
TUNING.WEREPIG_WALK_SPEED = 3

TUNING.PIG_BANDIT_RUN_SPEED = 7
TUNING.PIG_BANDIT_WALK_SPEED = 3

TUNING.ROBOT_TARGET_DIST = 15
TUNING.ROBOT_RIBS_DAMAGE = TUNING.BASE_SURVIVOR_ATTACK
TUNING.ROBOT_RIBS_HEALTH = 1000
TUNING.ROBOT_LEG_DAMAGE = TUNING.BASE_SURVIVOR_ATTACK*2

TUNING.LASER_DAMAGE = 20

TUNING.ANCIENT_HULK_DAMAGE = 200
TUNING.ANCIENT_HULK_MINE_DAMAGE = 100
TUNING.ANCIENT_HULK_MELEE_RANGE = 5.5
TUNING.ANCIENT_HULK_ATTACK_RANGE = 5.5

TUNING.IRON_LORD_DAMAGE = TUNING.BASE_SURVIVOR_ATTACK*2
TUNING.IRON_LORD_TIME = 3*60

TUNING.INFUSED_IRON_PERISHTIME = TUNING.TOTAL_DAY_TIME*2

TUNING.RUINS_ENTRANCE_VINES_HACKS = 4
TUNING.RUINS_DOOR_VINES_HACKS = 2