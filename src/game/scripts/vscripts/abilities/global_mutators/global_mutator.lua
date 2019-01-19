--------------------------------------------------------------------------------------------------------
--
--		Global Mutators
--
--------------------------------------------------------------------------------------------------------
-- Intrinsic modifier on the unit
LinkLuaModifier( "modifier_global_mutator", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
-- Gotta Go Fast modifiers
LinkLuaModifier( "modifier_gottagoslow_aura", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gottagoslow_effect", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gottagoquick_aura", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gottagoquick_effect", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gottagofast_aura", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gottagofast_effect", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gottagoreallyfast_aura", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gottagoreallyfast_effect", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
-- Memes modifier
LinkLuaModifier( "modifier_memes_redux", "abilities/global_mutators/memes_redux.lua" ,LUA_MODIFIER_MOTION_NONE )
-- Battle thirst
LinkLuaModifier( "modifier_battle_thirst", "abilities/global_mutators/battle_thirst.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_battle_thirst_aura", "abilities/global_mutators/battle_thirst.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_battle_thirst_effect", "abilities/global_mutators/battle_thirst.lua" ,LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_turbo_courier", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------------------------------
if global_mutator ~= "" then global_mutator = class({}) end

function global_mutator:GetIntrinsicModifierName()
    return "modifier_global_mutator"
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_global_mutator				
--------------------------------------------------------------------------------------------------------
if modifier_global_mutator ~= "" then modifier_global_mutator = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_global_mutator:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_global_mutator:IsHidden()
	return true
end

--------------------------------------------------------------------------------------------------------
function modifier_global_mutator:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_global_mutator:CheckState()
	local states = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return states
end
--------------------------------------------------------------------------------------------------------
if IsServer() then
--------------------------------------------------------------------------------------------------------
	function modifier_global_mutator:OnCreated()
		-- Gotta Go Fast
		if OptionManager:GetOption("gottaGoFast") == 1 then
			local thinker = CreateModifierThinker(self:GetParent(),self:GetAbility(),"modifier_gottagoquick_aura",{},Vector(0,0,0),20,false)
		elseif OptionManager:GetOption("gottaGoFast") == 2 then
			local thinker = CreateModifierThinker(self:GetParent(),self:GetAbility(),"modifier_gottagofast_aura",{},Vector(0,0,0),20,false)
		elseif OptionManager:GetOption("gottaGoFast") == 3 then
			local thinker = CreateModifierThinker(self:GetParent(),self:GetAbility(),"modifier_gottagoreallyfast_aura",{},Vector(0,0,0),20,false)
		elseif OptionManager:GetOption("gottaGoFast") == 4 then
			local thinker = CreateModifierThinker(self:GetParent(),self:GetAbility(),"modifier_gottagoslow_aura",{},Vector(0,0,0),20,false)
		end
		-- Memes Redux
		if OptionManager:GetOption("memesRedux") == 1 then
			local memer = CreateModifierThinker(self:GetParent(),self:GetAbility(),"modifier_memes_redux",{},Vector(0,0,0),20,false)
		end
		-- Battle Thirst
		if OptionManager:GetOption("battleThirst") == 1 then
			local battler = CreateModifierThinker(self:GetParent(),self:GetAbility(),"modifier_battle_thirst",{},Vector(0,0,0),20,false)
		end
	end
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_gottagoslow_aura				
--------------------------------------------------------------------------------------------------------
if modifier_gottagoslow_aura ~= "" then modifier_gottagoslow_aura = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_aura:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_aura:IsHidden()
	return true
end

--------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_aura:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_aura:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_aura:GetModifierAura()	return "modifier_gottagoslow_effect" end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_aura:GetAuraRadius() return 80000 end
----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_gottagoslow_effect				
--------------------------------------------------------------------------------------------------------
if modifier_gottagoslow_effect ~= "" then modifier_gottagoslow_effect = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_effect:IsDebuff()
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_effect:GetTexture()
	return "custom/mutator_gottagoslow"
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoslow_effect:GetModifierMoveSpeedBonus_Percentage()
	return -25
end


--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_gottagoquick_aura				
--------------------------------------------------------------------------------------------------------
if modifier_gottagoquick_aura ~= "" then modifier_gottagoquick_aura = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_aura:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_aura:IsHidden()
	return true
end

--------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_aura:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_aura:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_aura:GetModifierAura()	return "modifier_gottagoquick_effect" end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_aura:GetAuraRadius() return 80000 end
----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_gottagoquick_effect				
--------------------------------------------------------------------------------------------------------
if modifier_gottagoquick_effect ~= "" then modifier_gottagoquick_effect = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_effect:IsDebuff()
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_effect:GetTexture()
	return "custom/mutator_gottagoquick"
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoquick_effect:GetModifierMoveSpeedBonus_Percentage()
	return 15
end


--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_gottagofast_aura				
--------------------------------------------------------------------------------------------------------
if modifier_gottagofast_aura ~= "" then modifier_gottagofast_aura = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_gottagofast_aura:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_gottagofast_aura:IsHidden()
	return true
end

--------------------------------------------------------------------------------------------------------
function modifier_gottagofast_aura:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_gottagofast_aura:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_aura:GetModifierAura()	return "modifier_gottagofast_effect" end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_aura:GetAuraRadius() return 80000 end
----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_gottagofast_effect				
--------------------------------------------------------------------------------------------------------
if modifier_gottagofast_effect ~= "" then modifier_gottagofast_effect = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_effect:IsDebuff()
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_effect:GetTexture()
	return "custom/mutator_gottagofast"
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_MAX
	}
	return funcs
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_effect:GetModifierMoveSpeedBonus_Percentage()
	return 50
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_effect:GetModifierMoveSpeed_Limit()
	return 1000
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagofast_effect:GetModifierMoveSpeed_Max()
	return 1000
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_gottagoreallyfast_aura				
--------------------------------------------------------------------------------------------------------
if modifier_gottagoreallyfast_aura ~= "" then modifier_gottagoreallyfast_aura = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_aura:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_aura:IsHidden()
	return true
end

--------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_aura:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_aura:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_aura:GetModifierAura()	return "modifier_gottagoreallyfast_effect" end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_aura:GetAuraRadius() return 80000 end
----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_gottagoreallyfast_effect				
--------------------------------------------------------------------------------------------------------
if modifier_gottagoreallyfast_effect ~= "" then modifier_gottagoreallyfast_effect = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_effect:IsDebuff()
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_effect:GetTexture()
	return "custom/mutator_gottagoreallyfast"
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_MAX
	}
	return funcs
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_effect:GetModifierMoveSpeed_Absolute()
	return 1000
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_effect:GetModifierMoveSpeed_Limit()
	return 1000
end
----------------------------------------------------------------------------------------------------------
function modifier_gottagoreallyfast_effect:GetModifierMoveSpeed_Max()
	return 1000
end
----------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_gottagofast_effect				
--------------------------------------------------------------------------------------------------------
if modifier_turbo_courier ~= "" then modifier_turbo_courier = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_turbo_courier:IsDebuff()
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_turbo_courier:GetTexture()
	return "custom/mutator_turbocourier"
end
function modifier_turbo_courier:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end
function modifier_turbo_courier:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end
----------------------------------------------------------------------------------------------------------
function modifier_turbo_courier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX,
		MODIFIER_PROPERTY_FIXED_DAY_VISION,
		MODIFIER_PROPERTY_FIXED_NIGHT_VISION
	}
	return funcs
end
function modifier_turbo_courier:GetFixedDayVision()
	return 32
end
function modifier_turbo_courier:GetFixedNightVision()
	return 32
end
----------------------------------------------------------------------------------------------------------
function modifier_turbo_courier:GetModifierMoveSpeedBonus_Percentage()
	return 900
end
----------------------------------------------------------------------------------------------------------
function modifier_turbo_courier:GetModifierMoveSpeed_Limit()
	return 8000
end
----------------------------------------------------------------------------------------------------------
function modifier_turbo_courier:GetModifierMoveSpeed_AbsoluteMax()
	return 8000
end

function modifier_turbo_courier:OnCreated()
	if IsClient() then return end
	self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_bloodseeker_thirst", {})
end