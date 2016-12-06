--[[
Tower Defense AI

These are the valid orders, in case you want to use them (easier here than to find them in the C code):

DOTA_UNIT_ORDER_NONE
DOTA_UNIT_ORDER_MOVE_TO_POSITION 
DOTA_UNIT_ORDER_MOVE_TO_TARGET 
DOTA_UNIT_ORDER_ATTACK_MOVE
DOTA_UNIT_ORDER_ATTACK_TARGET
DOTA_UNIT_ORDER_CAST_POSITION
DOTA_UNIT_ORDER_CAST_TARGET
DOTA_UNIT_ORDER_CAST_TARGET_TREE
DOTA_UNIT_ORDER_CAST_NO_TARGET
DOTA_UNIT_ORDER_CAST_TOGGLE
DOTA_UNIT_ORDER_HOLD_POSITION
DOTA_UNIT_ORDER_TRAIN_ABILITY
DOTA_UNIT_ORDER_DROP_ITEM
DOTA_UNIT_ORDER_GIVE_ITEM
DOTA_UNIT_ORDER_PICKUP_ITEM
DOTA_UNIT_ORDER_PICKUP_RUNE
DOTA_UNIT_ORDER_PURCHASE_ITEM
DOTA_UNIT_ORDER_SELL_ITEM
DOTA_UNIT_ORDER_DISASSEMBLE_ITEM
DOTA_UNIT_ORDER_MOVE_ITEM
DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
DOTA_UNIT_ORDER_STOP
DOTA_UNIT_ORDER_TAUNT
DOTA_UNIT_ORDER_BUYBACK
DOTA_UNIT_ORDER_GLYPH
DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH
DOTA_UNIT_ORDER_CAST_RUNE
]]

AICore = {}

function AICore:RandomEnemyHeroInRange( entity, range , magic_immune)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )
	if #enemies > 0 then
		local index = RandomInt( 1, #enemies )
		return enemies[index]
	else
		return nil
	end
end

function AICore:NearestEnemyHeroInRange( entity, range , magic_immune)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )
	
	local minRange = range
	local target = nil
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length2D()
		if enemy:IsAlive() and distanceToEnemy < minRange then
			minRange = distanceToEnemy
			target = enemy
		end
	end
	return target
end

function AICore:BeingAttacked( entity )
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, 9999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	local count = 0
	
	for _,enemy in pairs(enemies) do
		if enemy:IsAlive() and enemy:IsAttackingEntity(entity) then
			minRange = distanceToEnemy
			count = count + 1
		end
	end
	return count
end

function AICore:AttackHighestPriority( entity )
	local flag = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local range = entity:GetAttackRange() + entity:GetIdealSpeed() * 0.3
	if not entity:IsDominated() then
		local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flag, 0, false )
		local target = nil
		local minThreat = 0
		if entity.previoustarget then 
			target = entity.previoustarget
			minThreat = target.threat
		end
		for _,enemy in pairs(enemies) do
			local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
			if not enemy.threat then enemy.threat = 0 end
			if enemy:IsAlive() and (enemy.threat or 0) > minThreat and distanceToEnemy < range and not entity.previoustarget then
				minThreat = enemy.threat
				target = enemy
				entity.previoustarget = target
			elseif entity.previoustarget and enemy:IsAlive() and enemy.threat > minThreat + 5 and distanceToEnemy < range then
				minThreat = enemy.threat
				target = enemy
				entity.previoustarget = target
			end
		end
		if not target then 
			local minHP = nil
			local target = nil
			enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range*2, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flag, 0, false )
			for _,enemy in pairs(enemies) do
				local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
				local HP = enemy:GetHealth()
				if enemy:IsAlive() and (minHP == nil or HP < minHP) and distanceToEnemy < range then
					minHP = HP
					target = enemy
					entity.previoustarget = target
				end
			end
		end
		if not target then 
			local minRange = 9999
			local target = nil
			enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, minRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flag, 0, false )
			for _,enemy in pairs(enemies) do
				local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length2D()
				if enemy:IsAlive() and distanceToEnemy < minRange then
					minRange = distanceToEnemy
					target = enemy
					entity.previoustarget = target
				end
			end
		end
		if target and not target:IsNull() then
			ExecuteOrderFromTable({
				UnitIndex = entity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			})
			return 0.5
		else -- no viable targets
			-- ExecuteOrderFromTable({
				-- UnitIndex = entity:entindex(),
				-- OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				-- Position = Vector(0,0)
			-- })
			-- return 0.1
		end
	end
end

function AICore:BeAHugeCoward( entity, runbuffer )
	local nearest = AICore:NearestEnemyHeroInRange( entity, 99999, true )
	if nearest then 
		local direction = (nearest:GetOrigin()-entity:GetOrigin()):Normalized()
		local distance = (nearest:GetOrigin()-entity:GetOrigin()):Length2D()
		if distance < runbuffer then
			ExecuteOrderFromTable({
				UnitIndex = entity:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = (-direction)*distance
			})
		end
	end
end

function AICore:FarthestEnemyHeroInRange( entity, range , magic_immune)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )
	
	local minRange = nil
	local target = nil
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
		if enemy:IsAlive() and (minRange == nil or distanceToEnemy > minRange) and distanceToEnemy < range then
			minRange = distanceToEnemy
			target = enemy
		end
	end
	return target
end

function AICore:NearestDisabledEnemyHeroInRange( entity, range , magic_immune)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )
	
	local minRange = range
	local target = nil
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length2D()
		if enemy:IsAlive() and distanceToEnemy < minRange and enemy:IsDisabled() then
			minRange = distanceToEnemy
			target = enemy
		end
	end
	return target
end

function AICore:TotalEnemyHeroesInRange( entity, range)
	local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )
	
	local count = 0
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
		if enemy:IsAlive() and distanceToEnemy < range then
			count = count + 1
		end
	end
	return count
end

function AICore:OptimalHitPosition(entity, range, radius)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )
	local meanPos
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
		local withinRadius
		if not meanPos then withinRadius = 0 
		else withinRadius = (meanPos - enemy:GetOrigin()):Length() end
		if enemy:IsAlive() and distanceToEnemy < range and withinRadius < radius then
			if not meanPos then meanPos = enemy:GetOrigin()
			else meanPos = (meanPos + enemy:GetOrigin())/2 end
		end
	end
	return meanPos
end

function AICore:TotalNotDisabledEnemyHeroesInRange( entity, range , magic_immune)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )
	
	local count = 0
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
		if enemy:IsAlive() and distanceToEnemy < range and not enemy:IsDisabled() then
			count = count + 1
		end
	end
	return count
end

function AICore:TotalUnitsInRange( entity, range )
	
	flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, flags, 0, false )
	
	local count = 0
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
		if enemy:IsAlive() and distanceToEnemy < range then
			count = count + 1
		end
	end
	return count
end

function AICore:TotalAlliedUnitsInRange( entity, range	)
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	
	local count = 0
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
		if enemy:IsAlive() and distanceToEnemy < range then
			count = count + 1
		end
	end
	return count
end

function AICore:AlliedUnitsAlive( entity )
	local allies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, 99999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	
	local count = 0
	
	for _,ally in pairs(allies) do
		if ally:IsAlive() and ally ~= entity then
			count = count + 1
		end
	end
	return count
end

function AICore:WeakestAlliedUnitInRange( entity, range , magic_immune)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local allies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, flags, 0, false )

	local minHP = nil
	local target = nil

	for _,ally in pairs(allies) do
		local distanceToEnemy = (entity:GetOrigin() - ally:GetOrigin()):Length()
		local HP = ally:GetHealth()
		if ally:IsAlive() and (minHP == nil or HP < minHP) and distanceToEnemy < range then
			minHP = HP
			target = ally
		end
	end

	return target
end

function AICore:SpecificAlliedUnitsAlive( entity, name )
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, 99999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	
	local count = 0
	
	for _,enemy in pairs(enemies) do
		if enemy:IsAlive() and enemy ~= entity and (enemy:GetUnitName() == name or enemy:GetName() == name or enemy:GetUnitLabel() == name) then
			count = count + 1
		end
	end
	return count
end

function AICore:EnemiesInLine(entity, range, width, magic_immune)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInLine(entity:GetTeam(), entity:GetOrigin(),  entity:GetOrigin() + entity:GetForwardVector()*range, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL, flags)
	if enemies then
		return true
	else
		return false
	end
end

function AICore:WeakestEnemyHeroInRange( entity, range , magic_immune)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )

	local minHP = nil
	local target = nil

	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
		local HP = enemy:GetHealth()
		if enemy:IsAlive() and (minHP == nil or HP < minHP) and distanceToEnemy < range then
			minHP = HP
			target = enemy
		end
	end

	return target
end

function AICore:StrongestEnemyHeroInRange( entity, range , magic_immune)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )

	local minHP = nil
	local target = nil

	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
		local HP = enemy:GetHealth()
		if enemy:IsAlive() and (minHP == nil or HP > minHP) and distanceToEnemy < range then
			minHP = HP
			target = enemy
		end
	end

	return target
end

function AICore:HighestThreatHeroInRange(entity, range, basethreat, magic_immune)
	local flags = 0
	if magic_immune then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
    local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, flags, 0, false )

	local target = nil
	local minThreat = basethreat
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
		if not enemy.threat then enemy.threat = 0 end
		local threat = enemy.threat
		if enemy:IsAlive() and (minThreat == nil or threat > minThreat) and distanceToEnemy < range then
			minThreat = threat
			target = enemy
		end
	end

	return target
end

function AICore:CreateBehaviorSystem( behaviors )
	local BehaviorSystem = {}

	BehaviorSystem.possibleBehaviors = behaviors
	BehaviorSystem.thinkDuration = 1.0
	BehaviorSystem.repeatedlyIssueOrders = true -- if you're paranoid about dropped orders, leave this true

	BehaviorSystem.currentBehavior =
	{
		endTime = 0,
		order = { OrderType = DOTA_UNIT_ORDER_NONE }
	}

	function BehaviorSystem:Think()
		if GameRules:GetGameTime() >= self.currentBehavior.endTime then
			local newBehavior = self:ChooseNextBehavior()
			if newBehavior == nil then 
				-- Do nothing here... this covers possible problems with ChooseNextBehavior
			elseif newBehavior == self.currentBehavior then
				self.currentBehavior:Continue()
			else
				if self.currentBehavior.End then self.currentBehavior:End() end
				self.currentBehavior = newBehavior
				self.currentBehavior:Begin()
			end
		end

		if self.currentBehavior.order and self.currentBehavior.order.OrderType ~= DOTA_UNIT_ORDER_NONE then
			if self.repeatedlyIssueOrders or
				self.previousOrderType ~= self.currentBehavior.order.OrderType or
				self.previousOrderTarget ~= self.currentBehavior.order.TargetIndex or
				self.previousOrderPosition ~= self.currentBehavior.order.Position then

				-- Keep sending the order repeatedly, in case we forgot >.<
				ExecuteOrderFromTable( self.currentBehavior.order )
				self.previousOrderType = self.currentBehavior.order.OrderType
				self.previousOrderTarget = self.currentBehavior.order.TargetIndex
				self.previousOrderPosition = self.currentBehavior.order.Position
			end
		end

		if self.currentBehavior.Think then self.currentBehavior:Think(self.thinkDuration) end

		return self.thinkDuration
	end

	function BehaviorSystem:ChooseNextBehavior()
		local result = nil
		local bestDesire = nil
		for _,behavior in pairs( self.possibleBehaviors ) do
			local thisDesire = behavior:Evaluate()
			if bestDesire == nil or thisDesire > bestDesire then
				result = behavior
				bestDesire = thisDesire
			end
		end

		return result
	end

	function BehaviorSystem:Deactivate()
		print("End")
		if self.currentBehavior.End then self.currentBehavior:End() end
	end

	return BehaviorSystem
end