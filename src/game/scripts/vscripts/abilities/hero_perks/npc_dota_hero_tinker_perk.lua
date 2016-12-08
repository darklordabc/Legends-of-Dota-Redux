--------------------------------------------------------------------------------------------------------
--
--		Hero: Tinker
--		Perk: When Tinker uses Scientific spells, there is a 7% chance for them to be instantly refreshed.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_tinker_perk", "abilities/hero_perks/npc_dota_hero_tinker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_tinker_perk ~= "" then npc_dota_hero_tinker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_tinker_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_tinker_perk ~= "" then modifier_npc_dota_hero_tinker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:OnCreated()
	self.refreshChance = 7
	self.prng = -3
	self.particle = "particles/units/heroes/hero_tinker/tinker_rearm.vpcf"
end


function modifier_npc_dota_hero_tinker_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end


function modifier_npc_dota_hero_tinker_perk:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		if params.ability:HasAbilityFlag("scientific") then
			if RollPercentage(self.refreshChance + self.prng) then
				params.ability:EndCooldown()
				self.prng = -3
				local particle = ParticleManager:CreateParticle(self.particle, PATTACH_POINT_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			else
				self.prng = self.prng + 1
			end
		end
	end
end