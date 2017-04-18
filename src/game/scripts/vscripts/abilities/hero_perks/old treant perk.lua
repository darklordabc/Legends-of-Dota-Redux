--------------------------------------------------------------------------------------------------------
--
--		Hero: Treant
--		Perk: Treant receives 3 charges of living armor. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_treant_perk", "abilities/hero_perks/npc_dota_hero_treant_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_charges", "abilities/modifiers/modifier_charges.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_treant_perk ~= "" then npc_dota_hero_treant_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_treant_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_treant_perk ~= "" then modifier_npc_dota_hero_treant_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsHidden()
	return false
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
		self.hook = self:GetCaster():FindAbilityByName("treant_living_armor")
		if self.hook then
			self:StartIntervalThink(0.1)
		end
	end
end

function modifier_npc_dota_hero_treant_perk:OnIntervalThink()
	if not self.activated then
		if self.hook:GetLevel() > 0 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self.hook, "modifier_charges",
				{
					max_count = 3,
					start_count = 1,
					replenish_time = self.hook:GetCooldown(-1)
				}
			)
			self.activated = true
		end
	end
end

function modifier_npc_dota_hero_treant_perk:OnRefresh()
	if IsServer() then
		--self.damagecooldown = self.hook:GetCooldown(-1) -- Time before hook does damage again.
		local modifier = self:GetParent():FindModifierByName("modifier_charges")
		if modifier and modifier.kv.replenish_time ~= self.hook:GetCooldown(-1) then
			modifier.kv.replenish_time = self.hook:GetCooldown(-1)
		end
	end
end

function modifier_npc_dota_hero_treant_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end


function modifier_npc_dota_hero_treant_perk:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		if params.ability == self.hook then
			self:ForceRefresh()
		end
	end
end
