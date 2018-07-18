--local timers = require('easytimers')

BATTLE_THIRST_TIME = 45.0

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
	return "modifier_battle_thirst_aura"
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
--    Modifier: modifier_battle_thirst_aura        
--------------------------------------------------------------------------------------------------------
modifier_battle_thirst_aura = class({})
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_aura:IsHidden()
	return true
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_aura:OnIntervalThink(keys)
	if IsServer() then
		-- Dont count down until game has started
		if GameRules:GetDOTATime(false,false) == 0 then 
			return 
		end

		local parent = self:GetParent()

		local parentTeam = parent:GetTeamNumber()
		local enemyTeam = 3

		if parentTeam == 3 then
			enemyTeam = 2
		end

		parent.counter = parent.counter or 0
		

		if parent.counter > BATTLE_THIRST_TIME then
			---- Temporarily disabled the bonus exp
			--if OptionManager:GetOption('sharedXP') == 1 then
	        --    for i=0,DOTA_MAX_TEAM do
	        --        local pID = PlayerResource:GetNthPlayerIDOnTeam(parentTeam,i)
	        --        if (PlayerResource:IsValidPlayerID(pID) or PlayerResource:GetConnectionState(pID) == 1) and PlayerResource:GetPlayer(pID) then
	        --            local otherHero = PlayerResource:GetPlayer(pID):GetAssignedHero()
	                    
	                    --otherHero:AddExperience(math.ceil(8 / util:GetActivePlayerCountForTeam(parentTeam)),0,false,false)
	        --        end
	        --    end
			--else
				-- Temporarily disabled the bonus exp
				--parent:AddExperience(8,1,false,false)
			--end
			
			parent:ModifyGold(-2,false,0)

			-- Little alert above players to indicate they are losing gold
			parent.alertTicker = parent.alertTicker or 3
			if parent.alertTicker == 3 then
				SendOverheadEventMessage( parent, OVERHEAD_ALERT_DENY , parent, 1, nil )
				parent.alertTicker = 0
			else
				parent.alertTicker = parent.alertTicker + 1
			end

		end
		
		for _,v in pairs(FindUnitsInRadius( parentTeam, parent:GetAbsOrigin(), nil, 2000.0, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE+DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )) do
			local check = (IsValidEntity(v) and v:IsNull() == false and v.GetPlayerOwnerID and not v:IsClone() and not v:HasModifier("modifier_arc_warden_tempest_double") and not string.match(v:GetUnitName(), "ward") and parent:CanEntityBeSeenByMyTeam(v) and v:GetTeamNumber() == tonumber(enemyTeam) and v:CanEntityBeSeenByMyTeam(parent))

			if check then
				parent.counter = 0
				parent:RemoveModifierByName("modifier_battle_thirst_effect")
        		return 1.0
		    end
		end

		parent.counter = parent.counter + 1

		if parent.counter >= BATTLE_THIRST_TIME and not parent:FindModifierByName("modifier_battle_thirst_effect") then
			parent:AddNewModifier(parent,nil,"modifier_battle_thirst_effect",{})
		end
		return 1.0
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_aura:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_aura:IsPurgable()
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_aura:GetTexture()
	return "custom/custom_games_xp_coin"
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_aura:IsDebuff()
	return false
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_battle_thirst_effect      
--------------------------------------------------------------------------------------------------------
modifier_battle_thirst_effect = class({})
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:IsHidden()
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:RemoveOnDeath()
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:OnCreated()
	if IsServer() then
		-- self:SetDuration(10.0,false)
		self:StartIntervalThink(1.0)
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:IsPurgable()
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:IsDebuff()
	return true
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


	end
end
----------------------------------------------------------------------------------------------------------
function modifier_battle_thirst_effect:GetTexture()
	return "custom/custom_games_xp_coin"
end