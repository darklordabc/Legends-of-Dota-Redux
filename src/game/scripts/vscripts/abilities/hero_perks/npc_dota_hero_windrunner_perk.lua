--------------------------------------------------------------------------------------------------------
--
--		Hero: Windranger
--		Perk: If Windranger has no passives, all her active spells will refund 20% mana and have 20% reduced cooldowns.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_windrunner_perk", "abilities/hero_perks/npc_dota_hero_windrunner_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_windrunner_perk ~= "" then npc_dota_hero_windrunner_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_windrunner_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_windrunner_perk ~= "" then modifier_npc_dota_hero_windrunner_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:OnCreated(keys)
	if IsServer() then
		self.noPassives = true
		local caster = self:GetCaster()
		
		for i = 0, 15 do 
			local ability = caster:GetAbilityByIndex(i)
			if ability and ability:IsPassive() and ability:GetName() ~= "npc_dota_hero_windrunner_perk" and not string.find(ability:GetName(),"special_bonus") then
				self.noPassives = false
				break
			end
		end
		if self.noPassives then 
			local cooldownReductionPercent = 20
			local manaReductionPercent = 20

			self.cooldownReduction = 1 - (cooldownReductionPercent / 100)
			self.manaReduction = manaReductionPercent / 100
		end
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:DeclareFunctions()
	local funcs = {
	  MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:OnAbilityFullyCast(keys)
  if IsServer() and self.noPassives then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability then
      hero:GiveMana(ability:GetManaCost(ability:GetLevel() - 1) * self.manaReduction)
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
