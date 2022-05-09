--------------------------------------------------------------------------------------------------------
--
--		Hero: Spectre
--		Perk: Spectre gains phased movement for 4 seconds every time she uses an ability.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_spectre_perk", "abilities/hero_perks/npc_dota_hero_spectre_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_spectre_phased", "abilities/hero_perks/npc_dota_hero_spectre_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_spectre_perk ~= "" then npc_dota_hero_spectre_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_spectre_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_spectre_perk ~= "" then modifier_npc_dota_hero_spectre_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_npc_dota_hero_spectre_perk:OnAbilityExecuted(params)
	if params.unit == self:GetParent() then
		local phase = params.ability -- For modifier icon
		self.target = phase:GetCursorPosition() or phase:GetCursorTarget()
	end
end

function modifier_npc_dota_hero_spectre_perk:GetModifierMoveSpeedBonus_Constant(params)
	if IsClient() then return end
	if not self.target then return end
	local target = self.target
	if target.GetAbsOrigin then
		target = target:GetAbsOrigin()
	end
	local direction = self:GetParent():GetForwardVector()
	local normal = (target-self:GetParent():GetAbsOrigin()):Normalized()
	if normal:Dot(direction) > 0.5 then
		return 100
	end


end
