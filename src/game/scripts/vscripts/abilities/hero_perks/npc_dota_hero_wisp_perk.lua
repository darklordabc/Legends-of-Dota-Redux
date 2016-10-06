--------------------------------------------------------------------------------------------------------
--
--		Hero: Wisp
--		Perk: Any spell IO casts on a Tethered Hero also gets cast on him.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_wisp_perk", "abilities/hero_perks/npc_dota_hero_wisp_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_wisp_perk == nil then npc_dota_hero_wisp_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_wisp_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_wisp_perk == nil then modifier_npc_dota_hero_wisp_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsHidden()
		if IsClient() then
		if not self.check then
			local netTable = CustomNetTables:GetTableValue( "heroes", self:GetParent():GetName().."_perk" )
			if netTable then
				self.hasValidAbility = netTable.hasValidAbility
			end
			self.check = true
		end
	end
	return (not self.hasValidAbility)
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:GetTexture()
	return "wisp_tether"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:OnCreated()
	if IsServer() then
	
		self.validAbility = self:GetParent():FindAbilityByName("wisp_tether") 

		if self.validAbility then self.hasValidAbility = (not self.validAbility:IsHidden()) end
			
		if self.hasValidAbility then 
		   CustomNetTables:SetTableValue( "heroes", self:GetParent():GetName().."_perk", { hasValidAbility = true } )
		end
		
	end
	
	self.exceptionList = {lich_dark_ritual = true,
						clinkz_death_pact = true,
						enchantress_enchant = true,
						chen_holy_persuasion = true}
end


function modifier_npc_dota_hero_wisp_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_wisp_perk:OnAbilityFullyCast(params)
	if IsServer() and params.unit == self:GetParent() and not self.exceptionList[params.ability:GetName()] then
		if params.ability:GetCursorTarget() and params.ability:GetCursorTarget():HasModifier("modifier_wisp_tether_haste") and params.ability:GetCursorTarget():GetTeamNumber() == self:GetParent():GetTeamNumber() then
			self:GetParent():SetCursorCastTarget(self:GetParent())
			params.ability:OnSpellStart()
		end
	end
end
