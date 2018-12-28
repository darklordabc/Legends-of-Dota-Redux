sled_penguin_passive = class({})

LinkLuaModifier( "modifier_sled_penguin_passive", "abilities/modifiers/modifier_sled_penguin_passive.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sled_penguin_movement", "abilities/modifiers/modifier_sled_penguin_movement.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_sled_penguin_crash", "abilities/modifiers/modifier_sled_penguin_crash.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_sled_penguin_impairment", "abilities/modifiers/modifier_sled_penguin_impairment.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function sled_penguin_passive:GetIntrinsicModifierName()
	return "modifier_sled_penguin_passive"
end