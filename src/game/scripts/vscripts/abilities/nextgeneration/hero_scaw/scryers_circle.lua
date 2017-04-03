function LevelUpAbility( keys )
	local caster = keys.caster
	local ability = keys.ability
end

function ScryerProjectiles( keys )
	local caster = keys.caster
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local unit_name = caster:GetUnitName()
	local images_count = ability:GetLevelSpecialValueFor("illusion_count", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "fire_bomb_delay", ability:GetLevel() - 1 ) + 0.5
	local outgoingDamage = -100
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_damage_taken", ability:GetLevel() - 1 )
	local spawnRadius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local delay = ability:GetLevelSpecialValueFor( "spawn_delay", ability:GetLevel() - 1 )

	local point = keys.target_points[1]
	local casterOrigin = caster:GetAbsOrigin()
	local casterForwardVec = caster:GetForwardVector()
	local rotateVar = 0
	ability:CreateVisibilityNode(point, spawnRadius, 1)

	-- Setup a table of projectile positions
	local vProjPos = {}
	for i=1, images_count do
		local rotate_distance = point + casterForwardVec * spawnRadius
		local rotate_angle = QAngle(0,rotateVar,0)
		rotateVar = rotateVar + 360/images_count
		local rotate_position = RotatePosition(point, rotate_angle, rotate_distance)

		local distance = (rotate_position - point):Length2D()
		local vector = (rotate_position - point):Normalized()
		local speed = distance / delay
		local projectileTable =
		{
			EffectName = "particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil.vpcf",
			Ability = ability,
			vSpawnOrigin = point,
			vVelocity = Vector( vector.x * speed, vector.y * speed, 0 ),
			fDistance = distance,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
		}

		vProjPos[i] = ProjectileManager:CreateLinearProjectile(projectileTable)
	end
end


function CreateScryerIllusions( keys )
	local caster = keys.caster
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local unit_name = caster:GetUnitName()
	local images_count = ability:GetLevelSpecialValueFor("illusion_count", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "fire_bomb_delay", ability:GetLevel() - 1 ) + 0.4
	local outgoingDamage = -100
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_damage_taken", ability:GetLevel() - 1 )
	local spawnRadius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )

	local point = keys.target_points[1]
	local casterOrigin = caster:GetAbsOrigin()
	local casterForwardVec = caster:GetForwardVector()
	local rotateVar = 0

	-- Setup a table of potential spawn positions
	local vSpawnPos = {}
	for i=1, images_count do
		local rotate_distance = point + casterForwardVec * spawnRadius
		local rotate_angle = QAngle(0,rotateVar,0)
		rotateVar = rotateVar + 360/images_count
		local rotate_position = RotatePosition(point, rotate_angle, rotate_distance)
		table.insert(vSpawnPos, rotate_position)
	end
	

	-- Spawn illusions
	for j=1, images_count do
		local origin = table.remove( vSpawnPos, 1 )
		local illusionForwardVec = (point - origin):Normalized()

		-- handle_UnitOwner needs to be nil, else it will crash the game.
		local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
		illusion:SetPlayerID(caster:GetPlayerID())
		illusion:SetControllableByPlayer(player, false)

		illusion:SetForwardVector(illusionForwardVec)
		
		-- Level Up the unit to the casters level
		local casterLevel = caster:GetLevel()
		for i=1,casterLevel-1 do
			illusion:HeroLevelUp(false)
		end

		-- Set the skill points to 0 and learn the skills of the caster
		illusion:SetAbilityPoints(0)
		for abilitySlot=0,15 do
			local ability = caster:GetAbilityByIndex(abilitySlot)
			if ability ~= nil then 
				local abilityLevel = ability:GetLevel()
				local abilityName = ability:GetAbilityName()
				if abilityName == "scawmar_scryers_circle" then
					illusion:RemoveAbility(abilityName)
					abilityName = "scryer_fire_bomb"
					illusion:AddAbility(abilityName)
					fireBombIndex = abilitySlot
				end
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				if abilityName == "scryer_fire_bomb" then
					illusionAbility:SetAbilityIndex(abilitySlot)
				end
				illusionAbility:SetLevel(abilityLevel)
			end
		end

		-- Recreate the items of the caster
		for itemSlot=0,5 do
			local item = caster:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = CreateItem(itemName, illusion, illusion)
				illusion:AddItem(newItem)
			end
		end

		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
		
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()
		-- Sets the illusion to begin channeling Fire Bomb
		local fireBomb = illusion:GetAbilityByIndex(fireBombIndex)
		Timers:CreateTimer( 0.035, function() 
			illusion:CastAbilityOnPosition(point, fireBomb, illusion:GetPlayerID() )
		end)
	end
end