--------------------------------------------------------------------------------------------------------
--
--		Hero: invoker
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_invoker_perk", "abilities/hero_perks/npc_dota_hero_invoker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_invoker_perk == nil then npc_dota_hero_invoker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_invoker_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_invoker_perk == nil then modifier_npc_dota_hero_invoker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_invoker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_invoker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_invoker_perk:OnCreated()
	self.abilityTable = {}
	self.intPerAbility = 5
end

function modifier_npc_dota_hero_invoker_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		
	}
	return funcs
end

function modifier_npc_dota_hero_invoker_perk:OnAbilityExecuted(params)
	if IsServer() then
		local castAbility = false
		for k,v in pairs(self.abilityTable) do
			if v == params.ability then
				castAbility = true
				break
			end
		end
		if params.unit == self:GetParent() and not castAbility and not (params.ability:IsItem() or params.ability:IsToggle()) then
			table.insert(self.abilityTable, params.ability)
			self:SetStackCount(self:GetStackCount() + self.intPerAbility)
		elseif castAbility then
			self.abilityTable = {}
			self:SetStackCount(0)
		end
	end
end

function modifier_npc_dota_hero_invoker_perk:GetModifierBonusStats_Intellect(params)
	return self:GetStackCount()
end
