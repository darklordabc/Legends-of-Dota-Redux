--[[
Unit AI
]]
require( "abilities/dota2horde/ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
	behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorAttackAncient } )--, BehaviorRun }-- } )
end

function AIThink()
	if thisEntity == nil or thisEntity:IsNull() or not thisEntity:IsAlive() or thisEntity:IsOwnedByAnyPlayer() then
		return nil -- deactivate this think function
	end
	return behaviorSystem:Think()
end

BehaviorAttackAncient = {}

function BehaviorAttackAncient:Evaluate()
	local desire = 0
	
	local nonAAFriendCount = 0
	local allFriends = FindUnitsInRadius( thisEntity:GetTeam(), thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for _,friend in pairs(allFriends) do
		if not friend:IsNull() and friend:IsAlive() and friend:GetUnitName() ~= "npc_dota_creature_ancient_apparition" then
			nonAAFriendCount = nonAAFriendCount + 1
		end
	end

	if nonAAFriendCount < 3 then
		desire = 3
	end

	return desire
end

function BehaviorAttackAncient:Begin()
	self.endTime = GameRules:GetGameTime() + 5
	local hAncient = Entities:FindByName( nil, "dota_goodguys_fort" )
	local targetTeam =  DOTA_UNIT_TARGET_TEAM_ENEMY --ability:GetAbilityTargetTeam()
	local targetType = DOTA_UNIT_TARGET_HERO -- ability:GetAbilityTargetType()
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS -- ability:GetAbilityTargetFlags()
	local units = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), thisEntity, 20000, targetTeam, targetType, targetFlag, FIND_CLOSEST, false)
	local mainTarget = nil
	local foundHuman = false
	for k, v in pairs( units ) do
		if not util:isPlayerBot(v:GetOwner():GetPlayerID()) then
			mainTarget = v
			break
		end	
		if mainTarget == nil then
			mainTarget = v
		end	
	end

	self.order =
		{
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			UnitIndex = thisEntity:entindex(),
			Position = mainTarget:GetOrigin()
		}
end

BehaviorAttackAncient.Continue = BehaviorAttackAncient.Begin

function BehaviorAttackAncient:Think(dt)
end
