--------------------------------------------------------------------------------------------------------
--
--		Hero: Dragon Knight
--		Perk: While Dragon Knight is in Elder Dragon Form, all of Dragon Knight's abilities apply Dragon Form debuffs. This includes towers.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_dragon_knight_perk", "abilities/hero_perks/npc_dota_hero_dragon_knight_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_dragon_knight_perk ~= "" then npc_dota_hero_dragon_knight_perk = class({}) end

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_dragon_knight_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_dragon_knight_perk ~= "" then modifier_npc_dota_hero_dragon_knight_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:OnCreated()
	-- self.dragonform = self:GetParent():FindAbilityByName("dragon_knight_elder_dragon_form")
	print(self:GetParent():GetUnitName())
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE,
  }
  return funcs
end

function modifier_npc_dota_hero_dragon_knight_perk:OnTakeDamage(params)
	if params.attacker and params.unit and params.attacker:GetTeamNumber() == params.unit:GetTeamNumber() then return end
	local dragonform = self:GetParent():FindAbilityByName("dragon_knight_elder_dragon_form")
	if self.dragonform or dragonform and params.attacker == self:GetParent() then
		local caster = params.attacker
		local parent = params.unit
		if caster and parent and caster == self:GetCaster() and params.inflictor ~= dragonform then
			if caster:HasModifier("modifier_dragon_knight_corrosive_breath") then
				local duration = dragonform:GetSpecialValueFor("corrosive_breath_duration")
			parent:AddNewModifier(caster, dragonform, "modifier_dragon_knight_corrosive_breath_dot", {duration = duration})
			end
			if caster:HasModifier("modifier_dragon_knight_frost_breath") then
				local duration = dragonform:GetSpecialValueFor("frost_duration")
				parent:AddNewModifier(caster, dragonform, "modifier_dragon_knight_frost_breath_slow", {duration = duration})
			end
		end
	end
end

function PerkDragonKnight(filterTable)
	local parent_index = filterTable["entindex_parent_const"]
  	local caster_index = filterTable["entindex_caster_const"]
  	local ability_index = filterTable["entindex_ability_const"]
  	if not parent_index or not caster_index or not ability_index then
      		return true
  	end
  	local parent = EntIndexToHScript( parent_index )
  	local caster = EntIndexToHScript( caster_index )
  	local ability = EntIndexToHScript( ability_index )
	if parent:GetTeamNumber() == caster:GetTeamNumber() then return end
	if ability then
    		local targetPerk = caster:FindAbilityByName(caster:GetName() .. "_perk")
	 	if targetPerk and targetPerks_modifier[targetPerk:GetName()] then
	    		if targetPerk:GetName() == "npc_dota_hero_dragon_knight_perk" then
		    		local dragonblood = caster:FindAbilityByName("dragon_knight_elder_dragon_form")
		    		if dragonblood and dragonblood ~= ability then
			    		if caster:HasModifier("modifier_dragon_knight_corrosive_breath") then
				  		local duration = dragonblood:GetSpecialValueFor("corrosive_breath_duration")
				  		parent:AddNewModifier(caster, dragonblood, "modifier_dragon_knight_corrosive_breath_dot", {duration = duration})
			    		end
			    		if caster:HasModifier("modifier_dragon_knight_frost_breath") then
				    		local duration = dragonblood:GetSpecialValueFor("frost_duration")
				    		parent:AddNewModifier(caster, dragonblood, "modifier_dragon_knight_frost_breath_slow", {duration = duration})
			    		end
		    		end
    			end
    		end
    	end
  end
