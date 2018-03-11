--------------------------------------------------------------------------------------------------------
--
--		Hero: Axe
--		Perk: Culling Blade kills will chop the remaining cooldown times of Axe's abilities in half, or by 30 seconds if the remaining cooldown exceeds 1 minute. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_axe_perk", "abilities/hero_perks/npc_dota_hero_axe_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_axe_perk ~= "" then npc_dota_hero_axe_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_axe_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_axe_perk ~= "" then modifier_npc_dota_hero_axe_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:OnCreated()
	self.cooldownReductionPct = 50
	self.cooldownReduction = 1 - (self.cooldownReductionPct / 100)
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:DeclareFunctions()
	return {
	MODIFIER_EVENT_ON_TAKEDAMAGE,
	MODIFIER_EVENT_ON_HERO_KILLED  
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:OnTakeDamage(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = keys.inflictor
		local target = keys.target
		local attacker = keys.attacker
		if attacker == caster then
			if ability then 
				self.ability = ability 
			else
				self.ability = nil
			end
		end
	end
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_axe_perk:OnHeroKilled(keys)
	if IsServer() then
		local caster = self:GetCaster() 
		local target = keys.target
		local attacker = keys.attacker

		if attacker == caster and self.ability then
			local ability = caster:FindAbilityByName(self.ability:GetName())
			if ability and ability:GetName() == "axe_culling_blade" then
				-- Reduces remaining cooldown by 75%
				local cooldownReduction = self.cooldownReduction
				for i = 0, 15 do 
					local ability = caster:GetAbilityByIndex(i)
					if ability and not ability:IsCooldownReady() then
						local cooldown = ability:GetCooldownTimeRemaining() * cooldownReduction
						if cooldown > 30 then cooldown = ability:GetCooldownTimeRemaining() - 30 end
						ability:EndCooldown()
						ability:StartCooldown(cooldown)
					end
				end
			end
		end
	end
	return true
end
--------------------------------------------------------------------------------------------------------
