--------------------------------------------------------------------------------------------------------
--
--		Hero: Tidehunter
--		Perk: Refreshes Ravage when Tidehunter dies. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_tidehunter_perk", "abilities/hero_perks/npc_dota_hero_tidehunter_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_tidehunter_perk == nil then npc_dota_hero_tidehunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_tidehunter_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_tidehunter_perk == nil then modifier_npc_dota_hero_tidehunter_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:IsHidden()
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
function modifier_npc_dota_hero_tidehunter_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:OnCreated()
	if IsServer() then
	
		self.validAbility = self:GetParent():FindAbilityByName("tidehunter_ravage") 

		if self.validAbility then self.hasValidAbility = (not self.validAbility:IsHidden()) end
			
		if self.hasValidAbility then 
		   CustomNetTables:SetTableValue( "heroes", self:GetParent():GetName().."_perk", { hasValidAbility = true } )
		end
		
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tidehunter_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_npc_dota_hero_tidehunter_perk:OnDeath(keys)
  if IsServer() then
    local caster = self:GetParent()
    if caster == keys.unit and caster:HasAbility("tidehunter_ravage") then
      caster:FindAbilityByName("tidehunter_ravage"):EndCooldown()
    end
  end
end

