--------------------------------------------------------------------------------------------------------
--
--    Hero: Outworld Devourer
--    Perk: Astral Imprisonment steals 7 intelligence for 60 seconds when cast by Outworld Devourer.
--
--------------------------------------------------------------------------------------------------------
--local timers = require('easytimers')

LinkLuaModifier( "modifier_npc_dota_hero_obsidian_destroyer_perk", "abilities/hero_perks/npc_dota_hero_obsidian_destroyer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_obsidian_destroyer_perk_buff", "abilities/hero_perks/npc_dota_hero_obsidian_destroyer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_obsidian_destroyer_perk_debuff", "abilities/hero_perks/npc_dota_hero_obsidian_destroyer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_obsidian_destroyer_perk ~= "" then npc_dota_hero_obsidian_destroyer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_obsidian_destroyer_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_obsidian_destroyer_perk ~= "" then modifier_npc_dota_hero_obsidian_destroyer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:OnCreated(keys)
	self:GetCaster().intelligenceSteal = 7
	self:GetCaster().duration = 60
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
--[[function modifier_npc_dota_hero_obsidian_destroyer_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk:OnAbilityFullyCast(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local target = keys.target
		local ability = keys.ability
		if caster == keys.unit and target and target:GetTeam() ~= caster:GetTeam() and target:IsHero() and ability and ability:GetName() == "obsidian_destroyer_astral_imprisonment" then
			caster:AddNewModifier(caster, ability, "modifier_npc_dota_hero_obsidian_destroyer_perk_buff", {Duration = self.duration})
			-- Debuff cannot be applied while target is invulnerable, so this must be done. 
			Timers:CreateTimer(function() 
				target:AddNewModifier(caster, ability, "modifier_npc_dota_hero_obsidian_destroyer_perk_debuff", {Duration = self.duration - 4.1})
				return
			end, DoUniqueString("applyIntSteal"), 4.1)
		end
	end
end]]
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_obsidian_destroyer_perk_buff ~= "" then modifier_npc_dota_hero_obsidian_destroyer_perk_buff = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_buff:IsPurgable()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_buff:GetTexture()
	return "obsidian_destroyer_astral_imprisonment"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_buff:GetModifierBonusStats_Intellect()
	return self:GetCaster().intelligenceSteal
end
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_obsidian_destroyer_perk_debuff ~= "" then modifier_npc_dota_hero_obsidian_destroyer_perk_debuff = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:IsDebuff()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:IsPurgable()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:GetTexture()
	return "obsidian_destroyer_astral_imprisonment"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_obsidian_destroyer_perk_debuff:GetModifierBonusStats_Intellect()
	return - self:GetCaster().intelligenceSteal
end
--------------------------------------------------------------------------------------------------------
function perkOD(filterTable)
	local parent_index = filterTable["entindex_parent_const"]
	local caster_index = filterTable["entindex_caster_const"]
	local ability_index = filterTable["entindex_ability_const"]
	if not parent_index or not caster_index or not ability_index then
		return true
	end
	local parent = EntIndexToHScript( parent_index )
	local caster = EntIndexToHScript( caster_index )
	local ability = EntIndexToHScript( ability_index )
	if ability then
		if caster:HasModifier("modifier_npc_dota_hero_obsidian_destroyer_perk") then
			if ability:GetName() == "obsidian_destroyer_astral_imprisonment_redux" and parent:IsHero() and parent:GetTeam() ~= caster:GetTeam() and parent:HasModifier("modifier_astral_imprisonment_redux") then
				caster:AddNewModifier(caster, nil, "modifier_npc_dota_hero_obsidian_destroyer_perk_buff", {Duration = caster.duration})
				-- Debuff cannot be applied while target is invulnerable, so this must be done. 
				Timers:CreateTimer(function() 
					parent:AddNewModifier(caster, nil, "modifier_npc_dota_hero_obsidian_destroyer_perk_debuff", {Duration = caster.duration - 4.1})
					return
				end, DoUniqueString("applyIntSteal"), 4.1)
			end
		end  
	end
	if ability then
		if caster:HasModifier("modifier_npc_dota_hero_obsidian_destroyer_perk") then
			if ability:GetName() == "obsidian_destroyer_astral_imprisonment" and parent:IsHero() and parent:GetTeam() ~= caster:GetTeam() and parent:HasModifier("modifier_astral_imprisonment_redux") then
				caster:AddNewModifier(caster, nil, "modifier_npc_dota_hero_obsidian_destroyer_perk_buff", {Duration = caster.duration})
				-- Debuff cannot be applied while target is invulnerable, so this must be done. 
				Timers:CreateTimer(function() 
					parent:AddNewModifier(caster, nil, "modifier_npc_dota_hero_obsidian_destroyer_perk_debuff", {Duration = caster.duration - 4.1})
					return
				end, DoUniqueString("applyIntSteal"), 4.1)
			end
		end  
	end
end
