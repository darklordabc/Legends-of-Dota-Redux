--------------------------------------------------------------------------------------------------------
--
--		Hero: Treant
--		Perk: Treant self-casts Living Armor and Nature's Guise when casting them on allies.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_treant_perk", "abilities/hero_perks/npc_dota_hero_treant_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_treant_perk == nil then npc_dota_hero_treant_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_treant_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_treant_perk == nil then modifier_npc_dota_hero_treant_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsHidden()
	if IsClient() then
		if not self.check then
			local netTable = CustomNetTables:GetTableValue( "heroes", self:GetParent():GetName().."_perk" )
			if netTable then
				self.hasValidAbility = netTable.hasValidAbility
			end
			self.check = true
		end
	end
	return (not self.hasValidAbility)
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:OnCreated()
	if IsServer() then
	
		self.validAbility = self:GetParent():FindAbilityByName("treant_living_armor") 
		if self.validAbility then self.hasValidAbility = (not self.validAbility:IsHidden()) end
		
		self.validAbility2 = self:GetParent():FindAbilityByName("treant_natures_guise") 
		if self.validAbility2 then self.hasValidAbility = (not self.validAbility2:IsHidden()) end
			
		if self.hasValidAbility or self.validAbility2 then 
		   CustomNetTables:SetTableValue( "heroes", self:GetParent():GetName().."_perk", { hasValidAbility = true } )
		end
	
	end

end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end
--------------------------------------------------------------------------------------------------------
local Timers = require('easytimers')

function modifier_npc_dota_hero_treant_perk:OnAbilityExecuted(params)
	if params.unit == self:GetParent() then
		if params.ability:GetName() == "treant_living_armor" then
			local armor = params.ability
			local duration = armor:GetSpecialValueFor("duration")
			self:GetParent():AddNewModifier(self:GetParent(), armor, "modifier_treant_living_armor", {duration = duration})
		end
		if params.ability:GetName() == "treant_natures_guise" then
			local guise = params.ability
			local duration = guise:GetSpecialValueFor("duration")
			self:GetParent():AddNewModifier(self:GetParent(), guise, "modifier_treant_natures_guise", {duration = duration})
		end
	end
end
