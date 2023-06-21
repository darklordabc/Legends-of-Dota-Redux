--------------------------------------------------------------------------------------------------------
--
--		Hero: Drow Ranger
--		Perk: Gust also disarms enemies when cast by Drow Ranger. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_drow_ranger_perk", "abilities/hero_perks/npc_dota_hero_drow_ranger_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_drow_ranger_disarm", "abilities/hero_perks/npc_dota_hero_drow_ranger_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_drow_ranger_perk ~= "" then npc_dota_hero_drow_ranger_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_drow_ranger_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_drow_ranger_perk ~= "" then modifier_npc_dota_hero_drow_ranger_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function perkDrowRanger(filterTable)
  --[[local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
    return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )
  if ability then
    if caster:HasModifier("modifier_npc_dota_hero_drow_ranger_perk") then
      if ability:GetName() == "drow_ranger_wave_of_silence" then
        local modifierDuration = filterTable["duration"]
        parent:AddNewModifier(caster,ability,"modifier_disarmed",{duration = modifierDuration})
      end
    end  
  end]]--
end

function modifier_npc_dota_hero_drow_ranger_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:OnCreated()
	self.bonusPerLevel = 2
	self.bonusAmount = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		for i=0, caster:GetAbilityCount() do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("ranger") then
				if not skill.perkLevel then skill.perkLevel = skill:GetLevel() end
				if skill:GetLevel() > skill.perkLevel then
					local increase = (skill:GetLevel()  - skill.perkLevel)
					increase = increase * self.bonusPerLevel
					local stacks = self:GetStackCount()
					self:SetStackCount(stacks + increase)
					skill.perkLevel = skill:GetLevel()
				end
			end
		end
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_drow_ranger_perk:GetModifierBonusStats_Agility(params)
	return self.bonusAmount * self:GetStackCount()
end
