--------------------------------------------------------------------------------------------------------
--
--		Hero: Pudge
--		Perk: Pudge receives 2 charges of Meat Hook. When Meat Hook deals damage, Pudge receives a debuff which prevents Meat Hook from dealing damage.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_pudge_perk", "abilities/hero_perks/npc_dota_hero_pudge_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_charges", "abilities/modifiers/modifier_charges.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_npc_dota_hero_pudge_hook_no_damage", "abilities/hero_perks/npc_dota_hero_pudge_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_pudge_perk ~= "" then npc_dota_hero_pudge_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_pudge_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_pudge_perk ~= "" then modifier_npc_dota_hero_pudge_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:OnCreated()
	if IsServer() then
		self.hook = self:GetCaster():FindAbilityByName("pudge_meat_hook")
		if self.hook then
			self:StartIntervalThink(0.1)
			self.damagecooldown = self.hook:GetCooldown(-1) -- Time before hook does damage again.
		end
	end
end

function modifier_npc_dota_hero_pudge_perk:OnIntervalThink()
	if not self.activated then
		if self.hook:GetLevel() > 0 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self.hook, "modifier_charges",
				{
					max_count = 2,
					start_count = 1,
					replenish_time = self.hook:GetCooldown(-1)
				}
			)
			self.activated = true
		end
	end
end

function modifier_npc_dota_hero_pudge_perk:OnRefresh()
	if IsServer() then
		self.damagecooldown = self.hook:GetCooldown(-1) -- Time before hook does damage again.
		local modifier = self:GetParent():FindModifierByName("modifier_charges")
		if modifier and modifier.kv.replenish_time ~= self.hook:GetCooldown(-1) then
			modifier.kv.replenish_time = self.hook:GetCooldown(-1)
		end
	end
end

function modifier_npc_dota_hero_pudge_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end


function modifier_npc_dota_hero_pudge_perk:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		if params.ability:GetName() == "item_refresher" then
			self:GetParent():RemoveModifierByName("modifier_npc_dota_hero_pudge_hook_no_damage")
		elseif params.ability == self.hook then
			self:ForceRefresh()
		end
	end
end

function modifier_npc_dota_hero_pudge_perk:OnTakeDamage(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			if params.inflictor == self.hook then
				local hook = params.inflictor
				if not self:GetParent():HasModifier("modifier_npc_dota_hero_pudge_hook_no_damage") then
					self:GetParent():AddNewModifier(self:GetParent(), hook, "modifier_npc_dota_hero_pudge_hook_no_damage",{duration = self.damagecooldown})
				end
			end
		end
	end
end

function PerkPudge(filterTable)
	local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    local ability_index = filterTable["entindex_inflictor_const"]
    if not victim_index or not attacker_index or not ability_index then
        return true
    end
    local attacker = EntIndexToHScript( attacker_index )
    local victim = EntIndexToHScript( victim_index )
    local ability = EntIndexToHScript( ability_index )
	local targetPerk = attacker:FindAbilityByName(attacker:GetName() .. "_perk")
	if targetPerk and targetPerks_damage[targetPerk:GetName()] then
		if ability:GetName() == "pudge_meat_hook" and attacker:HasModifier("modifier_npc_dota_hero_pudge_hook_no_damage") then
			filterTable["damage"] = 0
		end
	end
 end
 
 if modifier_npc_dota_hero_pudge_hook_no_damage ~= "" then modifier_npc_dota_hero_pudge_hook_no_damage = class({}) end
