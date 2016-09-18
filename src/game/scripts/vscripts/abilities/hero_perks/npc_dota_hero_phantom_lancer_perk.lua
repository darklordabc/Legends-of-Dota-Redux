--------------------------------------------------------------------------------------------------------
--
--		Hero: phantom_lancer
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_phantom_lancer_perk", "abilities/hero_perks/npc_dota_hero_phantom_lancer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_phantom_lancer_perk == nil then npc_dota_hero_phantom_lancer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_phantom_lancer_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_phantom_lancer_perk == nil then modifier_npc_dota_hero_phantom_lancer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_phantom_lancer_perk:OnCreated(params)
	self:PhantomRushCheck(params)
end

function modifier_npc_dota_hero_phantom_lancer_perk:PhantomRushCheck(params)
	local caster = self:GetCaster()

	local rush = caster:FindAbilityByName("phantom_lancer_phantom_edge") or nil

	if rush then
		rush:UpgradeAbility(false)
	else 
		rush = caster:AddAbility("phantom_lancer_phantom_edge")
		rush:SetHidden(true)
		rush:SetLevel(1)
	end
end