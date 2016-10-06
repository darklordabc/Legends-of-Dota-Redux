--------------------------------------------------------------------------------------------------------
--
--		Hero: Tusk
--		Perk: Walrus Kick and Walrus Punch will refund their manacost when used by Tusk. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_tusk_perk", "abilities/hero_perks/npc_dota_hero_tusk_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_tusk_perk == nil then npc_dota_hero_tusk_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_tusk_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_tusk_perk == nil then modifier_npc_dota_hero_tusk_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tusk_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tusk_perk:IsHidden()
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
function modifier_npc_dota_hero_tusk_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------

-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tusk_perk:OnCreated()
	if IsServer() then
	
		self.validAbility = self:GetParent():FindAbilityByName("tusk_walrus_kick") 
		if self.validAbility then self.hasValidAbility = (not self.validAbility:IsHidden()) end
		
		self.validAbility2 = self:GetParent():FindAbilityByName("tusk_walrus_punch") 
		if self.validAbility2 then self.hasValidAbility = (not self.validAbility2:IsHidden()) end
			
		if self.hasValidAbility or self.validAbility2 then 
		   CustomNetTables:SetTableValue( "heroes", self:GetParent():GetName().."_perk", { hasValidAbility = true } )
		end
	
	end

end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tusk_perk:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tusk_perk:OnAbilityFullyCast(keys)
	if IsServer() then
		if self:GetCaster() == keys.unit then
			if keys.ability:GetName() == "tusk_walrus_kick" then
				keys.ability:RefundManaCost()
			elseif keys.ability:GetName() == "tusk_walrus_punch" then
				-- GetManaCost() and RefundManaCost() do not work for Walrus Punch, so this is a loosy goosy workaround
				self:GetCaster():GiveMana(25 + (25 * keys.ability:GetLevel()))
			end
		end
	end

	return true
end
--------------------------------------------------------------------------------------------------------
