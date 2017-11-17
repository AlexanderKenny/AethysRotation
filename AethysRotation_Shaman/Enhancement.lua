--- Localize Vars
-- Addon
local addonName, addonTable = ...

-- AethysCore
local AC = AethysCore
local Cache = AethysCache
local Unit = AC.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell = AC.Spell
local Item = AC.Item

-- AethysRotation
local AR = AethysRotation

-- Updated from Shaman_T20M APL on 6/13/2017

-- APL Local Vars
-- Spells
if not Spell.Shaman then Spell.Shaman = {} end
Spell.Shaman.Enhancement = {
	-- Racials
	Berserking						= Spell(26297),
	BloodFury						= Spell(20572),

	-- Abilities
	CrashLightning					= Spell(187874),
	CrashLightningBuff				= Spell(187878),
	Flametongue						= Spell(193796),
	FlametongueBuff					= Spell(194084),
	Frostbrand						= Spell(196834),
	FrostbrandBuff					= Spell(196834),
	Stormstrike						= Spell(17364),
	StormbringerBuff				= Spell(201846),

	FeralSpirit						= Spell(51533),
	FuryOfAir						= Spell(197211),
	LavaLash						= Spell(60103),
	LightningBolt					= Spell(187837),
	Rockbiter						= Spell(193786),
	WindStrike						= Spell(115356),

	-- Talents
	Landslide						= Spell(197992),
	LandslideBuff					= Spell(202004),
	Ascendance						= Spell(114051),
	AscendanceBuff					= Spell(114051),
	EarthenSpike					= Spell(188089),
	EarthenSpikeDebuff				= Spell(188089),
	CrashingStorm					= Spell(192246),
	Hailstorm						= Spell(210853),
	HotHandBuff						= Spell(215785),
	Overcharge						= Spell(210727),
	Sundering						= Spell(197214),
	Windsong						= Spell(201898),

	-- Artifact
	DoomWinds						= Spell(204945),
	DoomWindsBuff					= Spell(204945),
	AlphaWolf						= Spell(198434),

	-- Utility
	WindShear						= Spell(57994)
}
local S = Spell.Shaman.Enhancement

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Enhancement = {
	-- Legendaries
	SmolderingHeart					= Item(151819),
	AkainusAbsoluteJustice			= Item(137084)
}
local I = Item.Shaman.Enhancement

-- GUI Settings
local Settings = {
	General = AR.GUISettings.General,
	Enhancement = AR.GUISettings.APL.Shaman.Enhancement
}

-- APL Main
local function APL ()
	-- Unit Update
	AC.GetEnemies(20)	-- Boulderfist, Flametongue
	AC.GetEnemies(8)	-- CrashLightning
	AC.GetEnemies(5)	-- Melee

	-- Out of Combat
	if not Player:AffectingCombat() then
		-- Opener
		if Target:Exists() and Player:CanAttack(Target) and Target:IsInRange(20) and not Target:IsDeadOrGhost() then
			if Player:Maelstrom() < 15 then
				if AR.Cast(S.Rockbiter) then return "Cast Rockbiter" end
			else
				if AR.Cast(S.LightningBolt) then return "Cast LightningBolt" end
			end
		end
		return
	end

	-- Interrupts
	if Settings.General.InterruptEnabled and Target:IsInterruptible() and Target:IsInRange(30) then
		if S.WindShear:IsCastable() then
			if AR.Cast(S.WindShear, Settings.Enhancement.OffGCDasOffGCD.WindShear) then return "Cast WindShear" end
		end
	end

	-- In Combat
	if Target:Exists() and Player:CanAttack(Target) and Target:IsInRange(5) and not Target:IsDeadOrGhost() then

		-- actions+=/variable,name=heartEquipped,value=(equipped.151819)
		-- actions+=/windstrike,if=(variable.heartEquipped|set_bonus.tier19_2pc)&(!talent.earthen_spike.enabled|(cooldown.earthen_spike.remains>1&cooldown.doom_winds.remains>1)|debuff.earthen_spike.up)
		if S.WindStrike:IsCastable() and ((I.SmolderingHeart:IsEquipped() or AC.Tier19_2Pc) and (not S.EarthenSpike:IsAvailable() or (S.EarthenSpike:Cooldown() > 1 and S.DoomWinds:Cooldown() > 1) or Target:Debuff(S.EarthenSpikeDebuff))) then
			if AR.Cast(S.WindStrike) then return "Cast WindStrike" end
		end

		-- actions.buffs=rockbiter,if=talent.landslide.enabled&!buff.landslide.up
		if S.Rockbiter:IsCastable() and (S.Landslide:IsAvailable() and not Player:Buff(S.LandslideBuff)) then
			if AR.Cast(S.Rockbiter) then return "Cast Rockbiter" end
		end

		-- actions.buffs+=/fury_of_air,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
		if S.FuryOfAir:IsCastable() and (Player:Buff(S.AscendanceBuff) or S.FeralSpirit:TimeSinceLastCast() < 10) then
			if AR.Cast(S.FuryOfAir) then return "Cast FuryOfAir" end
		end

		-- actions.buffs+=/crash_lightning,if=artifact.alpha_wolf.rank&prev_gcd.1.feral_spirit
		if S.CrashLightning:IsCastable() and (S.AlphaWolf:ArtifactEnabled() and Player:PrevGCD(1, S.FeralSpirit)) then
			if AR.Cast(S.CrashLightning) then return "Cast CrashLightning" end
		end

		-- actions.buffs+=/flametongue,if=!buff.flametongue.up
		if S.Flametongue:IsCastable() and (not Player:Buff(S.FlametongueBuff)) then
			if AR.Cast(S.Flametongue) then return "Cast Flametongue" end
		end

		-- actions+=/variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
		-- actions.buffs+=/frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck45
		if S.Frostbrand:IsCastable() and (S.Hailstorm:IsAvailable() and not Player:Buff(S.FrostbrandBuff) and (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 45))) then
			if AR.Cast(S.Frostbrand) then return "Cast Frostbrand" end
		end

		-- actions.buffs+=/flametongue,if=buff.flametongue.remains<6+gcd&cooldown.doom_winds.remains<gcd*2
		if S.Flametongue:IsCastable() and (Player:BuffRemains(S.FlametongueBuff) < 6 + Player:GCD() and S.DoomWinds:Cooldown() < Player:GCD() * 2) then
			if AR.Cast(S.Flametongue) then return "Cast Flametongue" end
		end

		-- actions.buffs+=/frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<6+gcd&cooldown.doom_winds.remains<gcd*2
		if S.Frostbrand:IsCastable() and (S.Hailstorm:IsAvailable() and Player:BuffRemains(S.FrostbrandBuff) < 6 + Player:GCD() and S.DoomWinds:Cooldown() < Player:GCD() * 2) then
			if AR.Cast(S.Frostbrand) then return "Cast Hailstorm" end
		end

		-- Racial
		-- actions.CDs+=/berserking,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
		if S.Berserking:IsCastable() and AR.CDsON() and (Player:Buff(S.AscendanceBuff) or S.FeralSpirit:TimeSinceLastCast() < 10) then
			if AR.Cast(S.Berserking, Settings.Enhancement.OffGCDasOffGCD.Berserking) then return "Cast Berserking" end
		end

		-- Racial
		-- actions.CDs+=/blood_fury,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
		if S.BloodFury:IsCastable() and AR.CDsON() and (Player:Buff(S.AscendanceBuff) or S.FeralSpirit:TimeSinceLastCast() < 10) then
			if AR.Cast(S.BloodFury, Settings.Enhancement.OffGCDasOffGCD.BloodFury) then return "Cast BloodFury" end
		end

		-- actions.CDs+=/feral_spirit
		if S.FeralSpirit:IsCastable() and AR.CDsON() then
			if AR.Cast(S.FeralSpirit, Settings.Enhancement.GCDasOffGCD.FeralSpirit) then return "Cast FeralSpirit" end
		end

		-- actions.CDs+=/doom_winds,if=debuff.earthen_spike.up&talent.earthen_spike.enabled|!talent.earthen_spike.enabled
		if S.DoomWinds:IsCastable() and AR.CDsON() and (Target:Debuff(S.EarthenSpikeDebuff) and S.EarthenSpike:IsAvailable() or not S.EarthenSpike:IsAvailable()) then
			if AR.Cast(S.DoomWinds, Settings.Enhancement.OffGCDasOffGCD.DoomWinds) then return "Cast DoomWinds" end
		end

		-- actions.CDs+=/ascendance,if=buff.doom_winds.up
		if S.Ascendance:IsCastable() and AR.CDsON() and (Player:Buff(S.DoomWindsBuff)) then
			if AR.Cast(S.Ascendance) then return "Cast Ascendance" end
		end

		-- actions+=/variable,name=furyCheck25,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>25))
		-- actions.core=earthen_spike,if=variable.furyCheck25
		if S.EarthenSpike:IsCastable() and (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 25)) then
			if AR.Cast(S.EarthenSpike) then return "Cast EarthenSpike" end
		end

		-- actions.core+=/crash_lightning,if=!buff.crash_lightning.up&active_enemies>=2
		if S.CrashLightning:IsCastable() and AR.AoEON() and (not Player:Buff(S.CrashLightningBuff) and Cache.EnemiesCount[5] >= 2) then
			if AR.Cast(S.CrashLightning) then return "Cast CrashLightning" end
		end

		-- actions.core+=/windsong
		if S.Windsong:IsCastable() then
			if AR.Cast(S.Windsong) then return "Cast Windsong" end
		end

		-- actions.core+=/crash_lightning,if=active_enemies>=8|(active_enemies>=6&talent.crashing_storm.enabled)
		if S.CrashLightning:IsCastable() and AR.AoEON() and (Cache.EnemiesCount[5] >= 8 or (Cache.EnemiesCount[5] >= 6 and S.CrashingStorm:IsAvailable())) then
			if AR.Cast(S.CrashLightning) then return "Cast CrashLightning" end
		end

		-- actions.core+=/windstrike
		if S.WindStrike:IsCastable() then
			if AR.Cast(S.WindStrike) then return "Cast WindStrike" end
		end

		-- actions+=/variable,name=furyCheck25,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>25))
		-- actions.core+=/stormstrike,if=buff.stormbringer.up&variable.furyCheck25
		if S.Stormstrike:IsCastable() and (Player:Buff(S.StormbringerBuff) and (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 25))) then
			if AR.Cast(S.Stormstrike) then return "Cast Stormstrike" end
		end

		-- actions.core+=/crash_lightning,if=active_enemies>=4|(active_enemies>=2&talent.crashing_storm.enabled)
		if S.CrashLightning:IsCastable() and AR.AoEON() and (Cache.EnemiesCount[5] >= 4 or (Cache.EnemiesCount[5] >= 2 and S.CrashingStorm:IsAvailable())) then
			if AR.Cast(S.CrashLightning) then return "Cast CrashLightning" end
		end

		-- actions+=/variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
		-- actions.core+=/lightning_bolt,if=talent.overcharge.enabled&variable.furyCheck45&maelstrom>=40
		if S.LightningBolt:IsCastable() and (S.Overcharge:IsAvailable() and (not S.FuryOfAir:IsAvailable() or S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 45) and Player:Maelstrom() >= 40) then
			if AR.Cast(S.LightningBolt) then return "Cast LightningBolt" end
		end

		-- actions+=/variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
		-- actions+=/variable,name=furyCheck80,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>80))
		-- actions.core+=/stormstrike,if=(!talent.overcharge.enabled&variable.furyCheck45)|(talent.overcharge.enabled&variable.furyCheck80)
		if S.Stormstrike:IsCastable() and ((not S.Overcharge:IsAvailable() and (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 45))) or (S.Overcharge:IsAvailable() and (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 80)))) then
			if AR.Cast(S.Stormstrike) then return "Cast Stormstrike" end
		end

		-- actions+=/variable,name=akainuAS,value=(variable.akainuEquipped&buff.hot_hand.react&!buff.frostbrand.up)
		-- actions.core+=/frostbrand,if=variable.akainuAS
		if S.Frostbrand:IsCastable() and (I.AkainusAbsoluteJustice:IsEquipped() and Player:Buff(S.HotHandBuff) and not Player:Buff(S.FrostbrandBuff)) then
			if AR.Cast(S.Frostbrand) then return "Cast Frostbrand" end
		end

		-- actions+=/variable,name=akainuEquipped,value=(equipped.137084)
		-- actions.core+=/lava_lash,if=buff.hot_hand.react&((variable.akainuEquipped&buff.frostbrand.up)|!variable.akainuEquipped)
		if S.LavaLash:IsCastable() and (Player:Buff(S.HotHandBuff) and ((I.AkainusAbsoluteJustice:IsEquipped() and Player:Buff(HotHandBuff)) or not I.AkainusAbsoluteJustice:IsEquipped())) then
			if AR.Cast(S.LavaLash) then return "Cast LavaLash" end
		end

		-- actions.core+=/sundering,if=active_enemies>=3
		if S.Sundering:IsCastable() and AR.AoEON() and (Cache.EnemiesCount[5] >= 3) then
			if AR.Cast(S.Sundering) then return "Cast Sundering" end
		end

		-- actions+=/variable,name=alphaWolfCheck,value=((pet.frost_wolf.buff.alpha_wolf.remains<2&pet.fiery_wolf.buff.alpha_wolf.remains<2&pet.lightning_wolf.buff.alpha_wolf.remains<2)&feral_spirit.remains>4)
		-- actions+=/variable,name=LightningCrashNotUp,value=(!buff.lightning_crash.up&set_bonus.tier20_2pc)
		-- actions.core+=/crash_lightning,if=active_enemies>=3|variable.LightningCrashNotUp|variable.alphaWolfCheck
		if S.CrashLightning:IsCastable() and AR.AoEON() and (Cache.EnemiesCount[5] >= 3 or (not Player:Buff(S.CrashLightningBuff) and AC.Tier20_2Pc) or (S.FeralSpirit:TimeSinceLastCast() < 11)) then
			if AR.Cast(S.CrashLightning) then return "Cast CrashLightning" end
		end

		-- actions.filler=rockbiter,if=maelstrom<120
		if S.Rockbiter:IsCastable() and (Player:Maelstrom() < 120) then
			if AR.Cast(S.Rockbiter) then return "Cast Rockbiter" end
		end

		-- actions.filler+=/flametongue,if=buff.flametongue.remains<4.8
		if S.Flametongue:IsCastable() and (Player:BuffRemains(S.FlametongueBuff) < 4.8) then
			if AR.Cast(S.Flametongue) then return "Cast Flametongue" end
		end

		-- actions.filler+=/rockbiter,if=maelstrom<=40
		if S.Rockbiter:IsCastable() and (Player:Maelstrom() <= 40) then
			if AR.Cast(S.Rockbiter) then return "Cast Rockbiter" end
		end

		-- actions+=/variable,name=OCPool60,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>60))
		-- actions.filler+=/crash_lightning,if=(talent.crashing_storm.enabled|active_enemies>=2)&debuff.earthen_spike.up&maelstrom>=40&variable.OCPool60
		if S.CrashLightning:IsCastable() and AR.AoEON() and ((S.CrashingStorm:IsAvailable() or Cache.EnemiesCount[5] >= 2) and Target:Debuff(S.EarthenSpikeDebuff) and Player:Maelstrom() >= 40 and (not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and Player:Maelstrom() > 60))) then
			if AR.Cast(S.CrashLightning) then return "Cast CrashLightning" end
		end

		-- actions.filler+=/frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8&maelstrom>40
		if S.Frostbrand:IsCastable() and (S.Hailstorm:IsAvailable() and Player:BuffRemains(S.FrostbrandBuff) < 4.8 and Player:Maelstrom() > 40) then
			if AR.Cast(S.Frostbrand) then return "Cast Frostbrand" end
		end

		-- actions.filler+=/frostbrand,if=variable.akainuEquipped&!buff.frostbrand.up&maelstrom>=75
		if S.Frostbrand:IsCastable() and (I.AkainusAbsoluteJustice:IsEquipped() and not Player:Buff(S.FrostbrandBuff) and Player:Maelstrom() >= 75) then
			if AR.Cast(S.Frostbrand) then return "Cast Frostbrand" end
		end

		-- actions.filler+=/sundering
		if S.Sundering:IsCastable() then
			if AR.Cast(S.Sundering) then return "Cast Sundering" end
		end

		-- actions+=/variable,name=OCPool70,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>70))
		-- actions+=/variable,name=furyCheck80,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>80))
		-- actions.filler+=/lava_lash,if=maelstrom>=50&variable.OCPool70&variable.furyCheck80
		if S.LavaLash:IsCastable() and (Player:Maelstrom() >= 50 and (not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and Player:Maelstrom() > 70)) and (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 80))) then
			if AR.Cast(S.LavaLash) then return "Cast LavaLash" end
		end

		-- actions.filler+=/rockbiter
		if S.Rockbiter:IsCastable() then
			if AR.Cast(S.Rockbiter) then return "Cast Rockbiter" end
		end

		-- actions+=/variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
		-- actions+=/variable,name=OCPool60,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>60))
		-- actions.filler+=/crash_lightning,if=(maelstrom>=65|talent.crashing_storm.enabled|active_enemies>=2)&variable.OCPool60&variable.furyCheck45
		if S.CrashLightning:IsCastable() and ((Player:Maelstrom() >= 65 or S.CrashingStorm:IsAvailable() or Cache.EnemiesCount[5] >= 2) and (not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and Player:Maelstrom() > 60)) and (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 45))) then
			if AR.Cast(S.CrashLightning) then return "Cast CrashLightning" end
		end

		-- actions.filler+=/flametongue
		if S.Flametongue:IsCastable() then
			if AR.Cast(S.Flametongue) then return "Cast Flametongue" end
		end
	end
end

AR.SetAPL(263, APL)
