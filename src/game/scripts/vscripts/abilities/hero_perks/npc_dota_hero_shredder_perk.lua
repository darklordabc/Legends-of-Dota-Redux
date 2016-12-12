--------------------------------------------------------------------------------------------------------
--
--		Hero: Timbersaw
--		Perk: Timbersaw gains health, mana, and experience points whenever a nearby tree is cut down. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_shredder_perk", "abilities/hero_perks/npc_dota_hero_shredder_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_shredder_perk ~= "" then npc_dota_hero_shredder_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_shredder_perk
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_shredder_perk ~= "" then modifier_npc_dota_hero_shredder_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shredder_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shredder_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shredder_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shredder_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shredder_perk:OnCreated(keys)
	ListenToGameEvent("tree_cut", function(keys) 
		local caster = self:GetCaster()
		local treeX = keys.tree_x
		local treeY = keys.tree_y
		local treeVector = Vector(treeX, treeY, 0)

		local XPamount = 2
		local HPamount = 5
		local MPamount = 2

		if caster and (caster:GetAbsOrigin() - treeVector):Length2D() <= 1200 then
			caster:AddExperience(XPamount, 0, false, false)
			caster:Heal(HPamount, self:GetAbility())
			caster:GiveMana(MPamount)
		end
	end, nil)
	return
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
