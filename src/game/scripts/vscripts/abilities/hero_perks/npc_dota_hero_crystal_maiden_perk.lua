--------------------------------------------------------------------------------------------------------
--
--		Hero: crystal_maiden
--		Perk: Crystal Maiden gains +2 MS for every Support skill she has. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_crystal_maiden_perk", "abilities/hero_perks/npc_dota_hero_crystal_maiden_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_crystal_maiden_perk ~= "" then npc_dota_hero_crystal_maiden_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_crystal_maiden_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_crystal_maiden_perk ~= "" then modifier_npc_dota_hero_crystal_maiden_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_crystal_maiden_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_crystal_maiden_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_npc_dota_hero_crystal_maiden_perk:OnCreated()
	if IsClient() then return end
	local caster = self:GetParent()

	local aura = caster:FindAbilityByName("crystal_maiden_brilliance_aura")
	
	for i = 0,5 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:HasAbilityFlag("ice") then
			if not aura then
				aura = caster:AddAbility("crystal_maiden_brilliance_aura")
			end
			aura:UpgradeAbility(false)
		end
	end

end



