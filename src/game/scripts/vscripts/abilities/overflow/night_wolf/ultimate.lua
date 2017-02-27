if night_wolf == nil then
	night_wolf = class({})
end

LinkLuaModifier( "night_wolf_p_mod", "abilities/overflow/night_wolf/ultimate_p_mod.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "night_wolf_mod", "abilities/overflow/night_wolf/ultimate_mod.lua", LUA_MODIFIER_MOTION_NONE )

function night_wolf:GetBehavior() 
	local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
	return behav
end

function night_wolf:GetIntrinsicModifierName() return "night_wolf_p_mod" end