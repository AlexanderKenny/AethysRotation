--- Localize Vars
-- Addon
local addonName, addonTable = ...;

-- AethysCore
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;

-- AethysRotation
local AR = AethysRotation;

-- APL from Warrior_Arms_T20M on 6/19/2017

-- APL Local Vars
-- Spells
if not Spell.Warrior then Spell.Warrior = {}; end
Spell.Warrior.Arms = {
	-- Racials
	Berserking						= Spell(26297),
	BloodFury						= Spell(20572),
	ArcaneTorrent					= Spell(28730),

	-- Abilities
	BattleCry						= Spell(1719),
	BattleCryBuff					= Spell(1719),
	ColossusSmash					= Spell(167105),
	ColossusSmashDebuff				= Spell(208086),
	ExecutionersPrecisionBuff		= Spell(242188),

	Charge							= Spell(100),
	Bladestorm						= Spell(227847),
	Cleave							= Spell(845),
	Execute							= Spell(163201),
	MortalStrike					= Spell(12294),
	WhirlWind						= Spell(1680),
	HeroicThrow						= Spell(57755),
	Slam							= Spell(1464),

	-- Talents
	Avatar							= Spell(107574),
	AvatarBuff						= Spell(107574),
	FocusedRage						= Spell(207982),
	FocusedRageBuff					= Spell(207982),
	Overpower						= Spell(7384),
	Ravager							= Spell(152277),
	Rend							= Spell(772),
	StormBolt						= Spell(107570),
	DeadlyCalm						= Spell(227266),
	FervorOfBattle					= Spell(202316),
	SweepingStrikes					= Spell(202161),
	AngerManagement					= Spell(152278),

	-- Artifact
	Warbreaker						= Spell(209577),

	-- Defensive
	CommandingShout					= Spell(97462),
	DefensiveStance					= Spell(197690),
	DiebytheSword					= Spell(118038),
	Victorious						= Spell(32216),
	VictoryRush						= Spell(34428),

	-- Utility
	Pummel							= Spell(6552),
	Shockwave						= Spell(46968),

	ShatteredDefensesBuff			= Spell(248625),
	PreciseStrikesBuff				= Spell(209492),
	CleaveBuff						= Spell(231833),
	RendDebuff						= Spell(772),

	-- Legendaries
	StoneHeartBuff					= Spell(225947)
}
local S = Spell.Warrior.Arms;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Arms = {
	-- Legendaries
	TheGreatStormsEye = Item(151823),
};
local I = Item.Warrior.Arms;

-- GUI Settings
local Settings = {
	General = AR.GUISettings.General,
	Arms = AR.GUISettings.APL.Warrior.Arms
}

-- APL Main
local function APL ()
	-- Unit Update
	AC.GetEnemies(30)	-- HeroicThrow
	AC.GetEnemies(8)	-- WhirlWind
	AC.GetEnemies(5)	-- Melee

	-- Out of Combat
	if not Player:AffectingCombat() then
		-- Opener
		if Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost() then
			if S.ColossusSmash:IsCastable() and (Target:IsInRange(5)) then
				if AR.Cast(S.ColossusSmash) then return "Cast Charge" end
			else
				if AR.Cast(S.HeroicThrow) then return "Cast HeroicThrow" end
			end
		end
		return
	end

	-- Interrupts
	if Settings.General.InterruptEnabled and Target:IsInterruptible() and Target:IsInRange(5) then
		if S.Pummel:IsCastable() then
			if AR.Cast(S.Pummel, Settings.Commons.OffGCDasOffGCD.Pummel) then return "Cast Pummel"; end
		end
	end

	-- In Combat
	if Target:Exists() and Player:CanAttack(Target) and Target:IsInRange(5) and not Target:IsDeadOrGhost() then

		-- Racial
		-- actions+=/blood_fury,if=buff.battle_cry.up|target.time_to_die<=16
		if S.BloodFury:IsCastable() and (Player:Buff(S.BattleCry)) then
			if AR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.BloodFury) then return "Cast BloodFury" end
		end

		-- Racial
		-- actions+=/berserking,if=buff.battle_cry.up|target.time_to_die<=11
		if S.Berserking:IsCastable() and (Player:Buff(S.BattleCry)) then
			if AR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Berserking) then return "Cast Berserking" end
		end

		-- Racial
		-- actions+=/arcane_torrent,if=buff.battle_cry_deadly_calm.down&rage.deficit>40&cooldown.battle_cry.remains
		if S.ArcaneTorrent:IsCastable() and (not Player:Buff(S.DeadlyCalm) and Player:RageDeficit() > 40 and S.BattleCry:Cooldown() > 0) then
			if AR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.ArcaneTorrent) then return "Cast ArcaneTorrent" end
		end

		-- actions+=/avatar,if=gcd.remains<0.25&(buff.battle_cry.up|cooldown.battle_cry.remains<15)|target.time_to_die<=20
		if S.Avatar:IsCastable() and (Player:Buff(S.BattleCryBuff) or S.BattleCry:Cooldown() < 15) then
			if AR.Cast(S.Avatar, Settings.Arms.OffGCDasOffGCD.Avatar) then return "Cast Avatar" end
		end

		-- actions+=/battle_cry,if=target.time_to_die<=6|(!talent.ravager.enabled|prev_gcd.1.ravager)&!gcd.remains&target.debuff.colossus_smash.remains>=5&(!cooldown.bladestorm.remains|!set_bonus.tier20_4pc)&(!talent.rend.enabled|dot.rend.remains>4)
		if S.BattleCry:IsCastable() and ((not S.Ravager:IsAvailable() or Player:PrevGCD(1, S.Ravager)) and Target:DebuffRemains(S.ColossusSmashDebuff) >= 5 and (not S.Bladestorm:Cooldown() or not AC.Tier20_4Pc) and (not S.Rend:IsAvailable() or Target:DebuffRemains(S.Rend) > 4)) then
			if AR.Cast(S.BattleCry, Settings.Arms.OffGCDasOffGCD.BattleCry) then return "Cast BattleCry" end
		end

		-- actions+=/run_action_list,name=cleave,if=spell_targets.whirlwind>=2&talent.sweeping_strikes.enabled
		if Cache.EnemiesCount[5] >= 2 and S.SweepingStrikes:IsAvailable() then
			-- actions.cleave=mortal_strike
			if S.MortalStrike:IsCastable() then
				if AR.Cast(S.MortalStrike) then return "Cast MortalStrike" end
			end

			-- actions.cleave+=/execute,if=buff.stone_heart.react
			if S.Execute:IsCastable() and (Player:Buff(S.StoneHeartBuff)) then
				if AR.Cast(S.Execute) then return "Cast Execute" end
			end

			-- actions.cleave+=/colossus_smash,if=buff.shattered_defenses.down&buff.precise_strikes.down
			if S.ColossusSmash:IsCastable() and (not Player:Buff(S.ShatteredDefensesBuff) and not Player:Buff(S.PreciseStrikesBuff)) then
				if AR.Cast(S.ColossusSmash) then return "Cast ColossusSmash" end
			end

			-- actions.cleave+=/warbreaker,if=buff.shattered_defenses.down
			if S.Warbreaker:IsCastable() and (not Player:Buff(S.ShatteredDefensesBuff)) then
				if AR.Cast(S.Warbreaker) then return "Cast Warbreaker" end
			end

			-- actions.cleave+=/focused_rage,if=rage>100|buff.battle_cry_deadly_calm.up
			if S.FocusedRage:IsCastable() and (Player:Rage() > 100 or (Player:Buff(S.BattleCryBuff) and S.DeadlyCalm:IsAvailable())) then
				if AR.Cast(S.FocusedRage) then return "Cast FocusedRage" end
			end

			-- actions.cleave+=/whirlwind,if=talent.fervor_of_battle.enabled&(debuff.colossus_smash.up|rage.deficit<50)&(!talent.focused_rage.enabled|buff.battle_cry_deadly_calm.up|buff.cleave.up)
			if S.WhirlWind:IsCastable() and (S.FervorOfBattle:IsAvailable() and (Target:Debuff(S.ColossusSmashDebuff) or Player:RageDeficit() < 50) and (not S.FocusedRage:IsAvailable() or (Player:Buff(S.BattleCryBuff) and S.DeadlyCalm:IsAvailable()) or Player:Buff(S.CleaveBuff))) then
				if AR.Cast(S.WhirlWind) then return "Cast WhirlWind" end
			end

			-- actions.cleave+=/rend,if=remains<=duration*0.3
			if S.Rend:IsCastable() and (Target:DebuffRemains(S.RendDebuff) <= Target:DebuffDuration(S.RendDebuff) * 0.3) then
				if AR.Cast(S.Rend) then return "Cast Rend" end
			end

			-- actions.cleave+=/bladestorm
			if S.Bladestorm:IsCastable() then
				if AR.Cast(S.Bladestorm) then return "Cast Bladestorm" end
			end

			-- actions.cleave+=/cleave
			if S.Cleave:IsCastable() then
				if AR.Cast(S.Cleave) then return "Cast Cleave" end
			end

			-- actions.cleave+=/whirlwind,if=rage>40|buff.cleave.up
			if S.WhirlWind:IsCastable() and (Player:Rage() > 40 or Player:Buff(S.CleaveBuff)) then
				if AR.Cast(S.WhirlWind) then return "Cast WhirlWind" end
			end

			-- actions.cleave+=/shockwave
			if S.Shockwave:IsCastable() then
				if AR.Cast(S.Shockwave) then return "Cast Shockwave" end
			end

			-- actions.cleave+=/storm_bolt
			if S.StormBolt:IsCastable() then
				if AR.Cast(S.StormBolt) then return "Cast StormBolt" end
			end
		end

		-- actions+=/run_action_list,name=aoe,if=spell_targets.whirlwind>=5&!talent.sweeping_strikes.enabled
		if AR.AoEON() and (Cache.EnemiesCount[5] >= 5 and not S.SweepingStrikes:IsAvailable()) then
			-- actions.aoe=mortal_strike,if=cooldown_react
			if S.MortalStrike:IsCastable() then
				if AR.Cast(S.MortalStrike) then return "Cast MortalStrike" end
			end

			-- actions.aoe+=/execute,if=buff.stone_heart.react
			if S.Execute:IsCastable() and (Player:Buff(S.StoneHeartBuff)) then
				if AR.Cast(S.Execute) then return "Cast Execute" end
			end

			-- actions.aoe+=/colossus_smash,if=cooldown_react&buff.shattered_defenses.down&buff.precise_strikes.down
			if S.ColossusSmash:IsCastable() and (not Player:Buff(S.ShatteredDefensesBuff) and not Player:Buff(S.PreciseStrikesBuff)) then
				if AR.Cast(S.ColossusSmash) then return "Cast ColossusSmash" end
			end

			-- actions.aoe+=/warbreaker,if=buff.shattered_defenses.down
			if S.Warbreaker:IsCastable() and (not Player:Buff(S.ShatteredDefensesBuff)) then
				if AR.Cast(S.Warbreaker) then return "Cast Warbreaker" end
			end

			-- actions.aoe+=/whirlwind,if=talent.fervor_of_battle.enabled&(debuff.colossus_smash.up|rage.deficit<50)&(!talent.focused_rage.enabled|buff.battle_cry_deadly_calm.up|buff.cleave.up)
			if S.WhirlWind:IsCastable() and (S.FervorOfBattle:IsAvailable() and (Target:Debuff(S.ColossusSmashDebuff) or Player:RageDeficit() < 50) and (not S.FocusedRage:IsAvailable() or (Player:Buff(S.BattleCryBuff) and S.DeadlyCalm:IsAvailable()) or Player:Buff(S.CleaveBuff))) then
				if AR.Cast(S.WhirlWind) then return "Cast WhirlWind" end
			end

			-- actions.aoe+=/rend,if=remains<=duration*0.3
			if S.Rend:IsCastable() and (Target:DebuffRemains(S.RendDebuff) <= Target:DebuffDuration(S.RendDebuff) * 0.3) then
				if AR.Cast(S.Rend) then return "Cast Rend" end
			end

			-- actions.aoe+=/bladestorm
			if S.Bladestorm:IsCastable() then
				if AR.Cast(S.Bladestorm) then return "Cast Bladestorm" end
			end

			-- actions.aoe+=/cleave
			if S.Cleave:IsCastable() then
				if AR.Cast(S.Cleave) then return "Cast Cleave" end
			end

			-- actions.aoe+=/execute,if=rage>90
			if S.Execute:IsCastable() and (Player:Rage() > 90) then
				if AR.Cast(S.Execute) then return "Cast Execute" end
			end

			-- actions.aoe+=/whirlwind,if=rage>=40
			if S.WhirlWind:IsCastable() and (Player:Rage() >= 40) then
				if AR.Cast(S.WhirlWind) then return "Cast WhirlWind" end
			end

			-- actions.aoe+=/shockwave
			if S.Shockwave:IsCastable() then
				if AR.Cast(S.Shockwave) then return "Cast Shockwave" end
			end

			-- actions.aoe+=/storm_bolt
			if S.StormBolt:IsCastable() then
				if AR.Cast(S.StormBolt) then return "Cast StormBolt" end
			end
		end

		-- actions+=/run_action_list,name=execute,target_if=target.health.pct<=20&spell_targets.whirlwind<5
		if Target:HealthPercentage() < 20 and Cache.EnemiesCount[5] < 5 then
			-- actions.execute=bladestorm,if=buff.battle_cry.up&(set_bonus.tier20_4pc|equipped.the_great_storms_eye)
			if S.Bladestorm:IsCastable() and (Player:Buff(S.BattleCryBuff) and (AC.Tier20_4Pc or I.TheGreatStormsEye:IsEquipped())) then
				if AR.Cast(S.Bladestorm) then return "Cast Bladestorm" end
			end

			-- actions.execute+=/ravager,if=cooldown.battle_cry.remains<=gcd&debuff.colossus_smash.remains>6
			if S.Ravager:IsCastable() and (S.BattleCry:Cooldown() <= Player:GCD() and Target:DebuffRemains(S.ColossusSmashDebuff) > 6) then
				if AR.Cast(S.Ravager) then return "Cast Ravager" end
			end

			-- actions.execute+=/colossus_smash,if=buff.shattered_defenses.down&(buff.battle_cry.down|buff.battle_cry.remains>gcd.max)
			if S.ColossusSmash:IsCastable() and (not Player:Buff(S.ShatteredDefensesBuff) and (not Player:Buff(S.BattleCryBuff) or Player:BuffRemains(S.BattleCryBuff) > Player:GCD())) then
				if AR.Cast(S.ColossusSmash) then return "Cast ColossusSmash" end
			end

			-- actions.execute+=/warbreaker,if=(raid_event.adds.in>90|!raid_event.adds.exists)&cooldown.mortal_strike.remains<=gcd.remains&buff.shattered_defenses.down&buff.executioners_precision.stack=2
			if S.Warbreaker:IsCastable() and (S.MortalStrike:Cooldown() <= Player:GCDRemains() and not Player:Buff(S.ShatteredDefensesBuff) and Player:BuffStack(S.ExecutionersPrecisionBuff) == 2) then
				if AR.Cast(S.Warbreaker) then return "Cast Warbreaker" end
			end

			-- actions.execute+=/focused_rage,if=rage.deficit<35
			if S.FocusedRage:IsCastable() and (Player:RageDeficit() < 35) then
				if AR.Cast(S.FocusedRage) then return "Cast FocusedRage" end
			end

			-- actions.execute+=/rend,if=remains<5&cooldown.battle_cry.remains<2&(cooldown.bladestorm.remains<2|!set_bonus.tier20_4pc)
			if S.Rend:IsCastable() and (Target:DebuffRemains(S.RendDebuff) < 5 and S.BattleCry:Cooldown() < 2 and (S.Bladestorm:Cooldown() < 2 or not AC.Tier20_4Pc)) then
				if AR.Cast(S.Rend) then return "Cast Rend" end
			end

			-- actions.execute+=/mortal_strike,if=buff.executioners_precision.stack=2&buff.shattered_defenses.up
			if S.MortalStrike:IsCastable() and (Player:BuffStack(S.ExecutionersPrecisionBuff) == 2 and Player:Buff(S.ShatteredDefensesBuff)) then
				if AR.Cast(S.MortalStrike) then return "Cast MortalStrike" end
			end

			-- actions.execute+=/overpower,if=rage<40
			if S.Overpower:IsCastable() and (Player:Rage() < 40)then
				if AR.Cast(S.Overpower) then return "Cast Overpower" end
			end

			-- actions.execute+=/execute
			if S.Execute:IsCastable() then
				if AR.Cast(S.Execute) then return "Cast Execute" end
			end

			-- actions.execute+=/overpower
			if S.Overpower:IsCastable() then
				if AR.Cast(S.Overpower) then return "Cast Overpower" end
			end

			-- actions.execute+=/bladestorm,interrupt=1,if=(raid_event.adds.in>90|!raid_event.adds.exists|spell_targets.bladestorm_mh>desired_targets)&!set_bonus.tier20_4pc
			if S.Bladestorm:IsCastable() and (not AC.Tier20_4Pc) then
				if AR.Cast(S.Bladestorm) then return "Cast Bladestorm" end
			end
		end

		-- actions+=/run_action_list,name=single,if=target.health.pct>20
		if Target:HealthPercentage() >= 20 then
			-- actions.single=bladestorm,if=buff.battle_cry.up&set_bonus.tier20_4pc
			if S.Bladestorm:IsCastable() and (Player:Buff(S.BattleCryBuff) and AC.Tier20_4Pc) then
				if AR.Cast(S.Bladestorm) then return "Cast Bladestorm" end
			end

			-- actions.single+=/ravager,if=cooldown.battle_cry.remains<=gcd&debuff.colossus_smash.remains>6
			if S.Ravager:IsCastable() and (S.BattleCry:Cooldown() <= Player:GCD() and Target:DebuffRemains(S.ColossusSmashDebuff) > 6) then
				if AR.Cast(S.Ravager) then return "Cast Ravager" end
			end

			-- actions.single+=/colossus_smash,if=buff.shattered_defenses.down
			if S.ColossusSmash:IsCastable() and (not Player:Buff(S.ShatteredDefensesBuff)) then
				if AR.Cast(S.ColossusSmash) then return "Cast ColossusSmash" end
			end

			-- actions.single+=/warbreaker,if=(raid_event.adds.in>90|!raid_event.adds.exists)&((talent.fervor_of_battle.enabled&debuff.colossus_smash.remains<gcd)|!talent.fervor_of_battle.enabled&((buff.stone_heart.up|cooldown.mortal_strike.remains<=gcd.remains)&buff.shattered_defenses.down))
			if S.Warbreaker:IsCastable() and ((S.FervorOfBattle:IsAvailable() and Target:DebuffRemains(S.ColossusSmashDebuff) < Player:GCD()) or not S.FervorOfBattle:IsAvailable() and ((Player:Buff(S.StoneHeartBuff) or S.MortalStrike:Cooldown() <= Player:GCDRemains()) and not Player:Buff(S.ShatteredDefensesBuff))) then
				if AR.Cast(S.Warbreaker) then return "Cast Warbreaker" end
			end

			-- actions.single+=/focused_rage,if=!buff.battle_cry_deadly_calm.up&buff.focused_rage.stack<3&!cooldown.colossus_smash.up&(rage>=130|debuff.colossus_smash.down|talent.anger_management.enabled&cooldown.battle_cry.remains<=8)
			if S.FocusedRage:IsCastable() and (not (Player:Buff(S.BattleCryBuff) and S.DeadlyCalm:IsAvailable()) and Player:BuffStack(S.FocusedRage) < 3 and not S.ColossusSmash:Cooldown() and (Player:Rage() >= 130 or Target:Debuff(S.ColossusSmashDebuff) or S.AngerManagement:IsAvailable() and S.BattleCry:Cooldown() <= 8)) then
				if AR.Cast(S.FocusedRage) then return "Cast FocusedRage" end
			end

			-- actions.single+=/rend,if=remains<=0|remains<5&cooldown.battle_cry.remains<2&(cooldown.bladestorm.remains<2|!set_bonus.tier20_4pc)
			if S.Rend:IsCastable() and (Target:DebuffRemains(S.RendDebuff) <= 0 and S.BattleCry:Cooldown() < 2 and (S.Bladestorm:Cooldown() < 2 or not AC.Tier20_4Pc)) then
				if AR.Cast(S.Rend) then return "Cast Rend" end
			end

			-- actions.single+=/execute,if=buff.stone_heart.react
			if S.Execute:IsCastable() and (Player:Buff(S.StoneHeartBuff)) then
				if AR.Cast(S.Execute) then return "Cast Execute" end
			end

			-- actions.single+=/mortal_strike,if=buff.shattered_defenses.up|buff.executioners_precision.down
			if S.MortalStrike:IsCastable() and (Player:Buff(S.ShatteredDefensesBuff) or not Player:Buff(S.ExecutionersPrecisionBuff)) then
				if AR.Cast(S.MortalStrike) then return "Cast MortalStrike" end
			end

			-- actions.single+=/overpower,if=buff.battle_cry.down
			if S.Overpower:IsCastable() and (not Player:Buff(S.BattleCry)) then
				if AR.Cast(S.Overpower) then return "Cast Overpower" end
			end

			-- actions.single+=/rend,if=remains<=duration*0.3
			if S.Rend:IsCastable() and (Target:DebuffRemains(S.RendDebuff) <= Target:DebuffDuration(S.RendDebuff) * 0.3) then
				if AR.Cast(S.Rend) then return "Cast Rend" end
			end

			-- actions.single+=/whirlwind,if=spell_targets.whirlwind>1|talent.fervor_of_battle.enabled
			if S.WhirlWind:IsCastable() and (Cache.EnemiesCount[5] > 1 or S.FervorOfBattle:IsAvailable()) then
				if AR.Cast(S.WhirlWind) then return "Cast WhirlWind" end
			end

			-- actions.single+=/slam,if=spell_targets.whirlwind=1&!talent.fervor_of_battle.enabled
			if S.Slam:IsCastable() and (Cache.EnemiesCount[5] == 1 and not S.FervorOfBattle:IsAvailable()) then
				if AR.Cast(S.Slam) then return "Cast Slam" end
			end

			-- actions.single+=/overpower
			if S.Overpower:IsCastable() then
				if AR.Cast(S.Overpower) then return "Cast Overpower" end
			end

			-- actions.single+=/bladestorm,if=(raid_event.adds.in>90|!raid_event.adds.exists)&!set_bonus.tier20_4pc
			if S.Bladestorm:IsCastable() and (not AC.Tier20_4Pc) then
				if AR.Cast(S.Bladestorm) then return "Cast Bladestorm" end
			end
		end
	end
end

AR.SetAPL(71, APL);
