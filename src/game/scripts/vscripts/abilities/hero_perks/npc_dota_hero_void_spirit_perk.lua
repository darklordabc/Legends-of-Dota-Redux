--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_void_spirit_perk", "abilities/hero_perks/npc_dota_hero_void_spirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_void_spirit_perk ~= "" then npc_dota_hero_void_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_void_spirit_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_void_spirit_perk ~= "" then modifier_npc_dota_hero_void_spirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_void_spirit_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ab = caster:FindAbilityByName("black_drake_magic_amplification_aura")
		if ab then
			ab:SetLevel(1)
		else
			ab = caster:AddAbility("black_drake_magic_amplification_aura")
            ab:SetStolen(true)
			ab:SetLevel(1)
			ab:SetHidden(false)
		end
	end
end
