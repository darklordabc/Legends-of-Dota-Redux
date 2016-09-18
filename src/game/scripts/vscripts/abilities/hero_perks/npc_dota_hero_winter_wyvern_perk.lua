--------------------------------------------------------------------------------------------------------
--
--		Hero: Winter Wyvern
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_winter_wyvern_perk", "abilities/hero_perks/npc_dota_hero_winter_wyvern_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
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
	self:StartIntervalThink(0.05)
	self.flying = false
end




function modifier_npc_dota_hero_winter_wyvern_perk:CheckState()
	local hpCheck = false
	if self:GetParent():GetHealthPercent() < 10 then
		hpCheck = true
	end
	local state = {
	[MODIFIER_STATE_FLYING] = hpCheck,
	}
	if self.flying and self:GetParent():GetHealthPercent() >= 10 then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 300, true)
		self.flying = false
	elseif not self.flying and self:GetParent():GetHealthPercent() < 10 then
		self.flying = true
	end
	return state
end