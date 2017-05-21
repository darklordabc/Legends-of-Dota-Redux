local Timers = require('easytimers')

--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_battle_thirst        
--------------------------------------------------------------------------------------------------------
modifier_battle_thirst = class({})
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst:IsHidden()
	return true
end
--------------------------------------------------------------------------------
function modifier_battle_thirst:IsAura()
	return true
end
--------------------------------------------------------------------------------
function modifier_battle_thirst:GetModifierAura()
	return "modifier_battle_thirst_effect"
end
--------------------------------------------------------------------------------
function modifier_battle_thirst:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end
--------------------------------------------------------------------------------
function modifier_battle_thirst:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end
--------------------------------------------------------------------------------
function modifier_battle_thirst:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
--------------------------------------------------------------------------------
function modifier_battle_thirst:GetAuraRadius()
	return FIND_UNITS_EVERYWHERE
end
--------------------------------------------------------------------------------
function modifier_battle_thirst:IsPurgable()
    return false
end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_battle_thirst_effect        
--------------------------------------------------------------------------------------------------------
modifier_battle_thirst_effect = class({})
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:IsHidden()
	self.shouldBeVisible = self.shouldBeVisible or false
	return self.shouldBeVisible == false
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:OnIntervalThink(keys)
	if IsServer() then
		local parent = self:GetParent()

		local parentTeam = parent:GetTeamNumber()
		local enemyTeam = 3

		if parentTeam == 3 then
			enemyTeam = 2
		end

		for _,v in pairs(Entities:FindAllByName("npc_dota_hero*")) do
			if IsValidEntity(v) and v:IsNull() == false and v.GetPlayerOwnerID and not v:IsClone() and not v:HasModifier("modifier_arc_warden_tempest_double") and v:IsRealHero() then
		        if v:GetTeamNumber() == tonumber(enemyTeam) then
		        	if (parent:GetAbsOrigin() - v:GetAbsOrigin()):Length2D() <= 2000.0 and v:CanEntityBeSeenByMyTeam(v) then
		        		parent:AddExperience(8,0,false,false)
		        		parent:ModifyGold(4,false,0)
		        		self.shouldBeVisible = true
		        		return 1.0
		        	end
		        end
		    end
		end

		self.shouldBeVisible = false

		return 1.0
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:IsPurgable()
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:GetTexture()
	return "custom/mutator_battlethirst"
end