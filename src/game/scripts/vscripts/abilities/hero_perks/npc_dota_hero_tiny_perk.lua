--------------------------------------------------------------------------------------------------------
--
--		Hero: Tiny
--		Perk: Casting an ability that targetted a tree gives 5% tenacity, stacks diminishingly
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_tiny_perk", "abilities/hero_perks/npc_dota_hero_tiny_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_tiny_perk ~= "" then npc_dota_hero_tiny_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_tiny_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_tiny_perk ~= "" then modifier_npc_dota_hero_tiny_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end


function modifier_npc_dota_hero_tiny_perk:OnAbilityFullyCast(params)
	self.tenacity = 25
	local tenacityDuration = 60
	if params.unit == self:GetParent() then
		if params.target and params.target.IsStanding then
			self:IncrementStackCount()
			Timers:CreateTimers(tenacityDuration,function() 
				self:DecrementStackCount() 
			end)
		end
	end
end

function modifier_npc_dota_hero_tiny_perk:GetTenacity()
	local n = 1 - (self.tenacity / 100)
	return n^self:GetStackCount()
end
