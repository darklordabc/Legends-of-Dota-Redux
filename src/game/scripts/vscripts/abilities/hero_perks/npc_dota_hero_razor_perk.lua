--------------------------------------------------------------------------------------------------------
--
--		Hero: Razor
--		Perk: Reduces the manacost and cooldown of all abilities by 25% when Razor is Static Linked to an enemy. Gains free level in Unstable Current.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_razor_perk", "abilities/hero_perks/npc_dota_hero_razor_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_razor_perk ~= "" then npc_dota_hero_razor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_razor_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_razor_perk ~= "" then modifier_npc_dota_hero_razor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_razor_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_razor_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_razor_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_razor_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
if IsServer() then
	function modifier_npc_dota_hero_razor_perk:OnCreated()
		self.reduction = 25
	    local caster = self:GetCaster()
	    local unstableCurrent = caster:FindAbilityByName("razor_unstable_current")
	    if unstableCurrent then
	        unstableCurrent:UpgradeAbility(false)
	    else 
	        unstableCurrent = caster:AddAbility("razor_unstable_current")
	        unstableCurrent:SetStolen(true)
	        unstableCurrent:SetActivated(true)
	        unstableCurrent:SetLevel(1)
	    end
	end
	function modifier_npc_dota_hero_razor_perk:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		}
		return funcs
	end
	--------------------------------------------------------------------------------------------------------
	function modifier_npc_dota_hero_razor_perk:OnAbilityFullyCast(params)
		if params.unit == self:GetParent() and self:GetParent():HasModifier("modifier_razor_static_link") then
			local cooldown = params.ability:GetCooldownTimeRemaining() * (100 - self.reduction)/100
			params.ability:EndCooldown()
			params.ability:StartCooldown(cooldown)
			local cost = params.ability:GetManaCost(-1) * (self.reduction)/100
			self:GetParent():GiveMana(cost)
		end
	end
end