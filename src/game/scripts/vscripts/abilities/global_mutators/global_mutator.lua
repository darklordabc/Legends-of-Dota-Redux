--------------------------------------------------------------------------------------------------------
--
--		Global Mutators
--
--------------------------------------------------------------------------------------------------------
local OptionManager = require('optionmanager')
-- Intrinsic modifier on the unit
LinkLuaModifier( "modifier_global_mutator", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
-- Gotta Go Fast modifiers
LinkLuaModifier( "modifier_gottagofast_aura", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gottagofast_effect", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gottagoreallyfast_aura", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gottagoreallyfast_effect", "abilities/global_mutators/global_mutator.lua" ,LUA_MODIFIER_MOTION_NONE )

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
		if OptionManager:GetOption("gottaGoFast") == 1 then
			local thinker = CreateModifierThinker(self:GetParent(),self:GetAbility(),"modifier_gottagofast_aura",{},Vector(0,0,0),20,false)
		elseif OptionManager:GetOption("gottaGoFast") == 2 then
			local thinker = CreateModifierThinker(self:GetParent(),self:GetAbility(),"modifier_gottagoreallyfast_aura",{},Vector(0,0,0),20,false)
		end
	end
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