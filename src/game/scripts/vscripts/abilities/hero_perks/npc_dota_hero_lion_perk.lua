--------------------------------------------------------------------------------------------------------
--
--		Hero: Lion
--		Perk: For Lion, killing a hero with a spell refunds the mana cost of that spell and lowers its cooldown by 75%.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_lion_perk", "abilities/hero_perks/npc_dota_hero_lion_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_lion_perk ~= "" then npc_dota_hero_lion_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_lion_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lion_perk ~= "" then modifier_npc_dota_hero_lion_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lion_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lion_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lion_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lion_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lion_perk:DeclareFunctions()
	return {
	MODIFIER_EVENT_ON_TAKEDAMAGE,
	MODIFIER_EVENT_ON_HERO_KILLED  
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lion_perk:OnTakeDamage(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = keys.inflictor
		local target = keys.target
		local attacker = keys.attacker
		if attacker == caster then
			if ability and not ability:HasAbilityFlag("attack_modifier") then 
				self.ability = ability 
			else
				self.ability = nil
			end
		end
	end
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lion_perk:OnHeroKilled(keys)
	if IsServer() then
		local caster = self:GetCaster() 
		local target = keys.target
		local attacker = keys.attacker

		if attacker == caster and self.ability then
			local ability = caster:FindAbilityByName(self.ability:GetName())
			if ability and not ability:HasAbilityFlag("attack_modifier") then
				local prt = ParticleManager:CreateParticle('particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf', PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:ReleaseParticleIndex(prt)
				-- Refunds manacost
				ability:RefundManaCost()
				-- Reduces remaining cooldown by 75%
				local cooldownReduction = 0.75
				local cooldown = ability:GetCooldownTimeRemaining() * (1-cooldownReduction)
				if cooldown > 0 then
					ability:EndCooldown()
					ability:StartCooldown(cooldown)
				end
			end
		end
	end
	return true
end
--------------------------------------------------------------------------------------------------------
