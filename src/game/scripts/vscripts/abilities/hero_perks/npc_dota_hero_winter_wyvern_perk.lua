--------------------------------------------------------------------------------------------------------
--
--		Hero: Winter Wyvern
--		Perk: When Winter Wyvern's health is below 10% she gains flying status.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_winter_wyvern_perk", "abilities/hero_perks/npc_dota_hero_winter_wyvern_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_winter_wyvern_flying", "abilities/hero_perks/npc_dota_hero_winter_wyvern_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_winter_wyvern_perk == nil then npc_dota_hero_winter_wyvern_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_winter_wyvern_perk			
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_winter_wyvern_perk == nil then modifier_npc_dota_hero_winter_wyvern_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_winter_wyvern_perk:OnCreated()
	self.flying = false
end




function modifier_npc_dota_hero_winter_wyvern_perk:CheckState()
	local hpCheck = false
	if self:GetParent():GetHealthPercent() < 10 then
		hpCheck = true
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_npc_dota_hero_winter_wyvern_flying", {})
	end
	local state = {
	[MODIFIER_STATE_FLYING] = hpCheck,
	}
	if self.flying and self:GetParent():GetHealthPercent() >= 10 then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 300, true)
		self.flying = false
		self:GetParent():RemoveModifierByName("modifier_npc_dota_hero_winter_wyvern_flying")
	elseif not self.flying and self:GetParent():GetHealthPercent() < 10 then
		self.flying = true
	end
	return state
end

if modifier_npc_dota_hero_winter_wyvern_flying == nil then modifier_npc_dota_hero_winter_wyvern_flying = class({}) end
