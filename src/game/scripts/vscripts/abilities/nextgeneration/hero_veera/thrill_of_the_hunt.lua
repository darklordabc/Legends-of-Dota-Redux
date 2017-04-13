function ThrillInitialize( keys )
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsIllusion() then
		caster.caster_altitude = 0
		camera_distance = 1200
		view_distance = ability:GetLevelSpecialValueFor("bonus_camera_view", (ability:GetLevel() - 1))
		bonus_vision = ability:GetLevelSpecialValueFor("bonus_vision", (ability:GetLevel() - 1))
		GameRules:GetGameModeEntity():SetCameraDistanceOverride( camera_distance )

		
		caster.caster_altitude = GetGroundHeight(caster:GetAbsOrigin(), caster)
		caster.camera_distance = camera_distance
		caster.start_bonus = 0
		caster:RemoveModifierByName("modifier_thrill_bonus_vision")
	end

end

function ThrillCameraCheck( keys )
	local caster = keys.caster
	local ability = keys.ability
	local view_distance = ability:GetLevelSpecialValueFor("bonus_camera_view", (ability:GetLevel() - 1))
	if not caster:IsIllusion() then
		local altitude = GetGroundHeight(caster:GetAbsOrigin(), caster)
		
		if altitude > caster.caster_altitude then
			caster.camera_distance = caster.camera_distance + 5
			caster.caster_altitude = caster.caster_altitude + 5
			GameRules:GetGameModeEntity():SetCameraDistanceOverride( caster.camera_distance + 5 )
		end
		if altitude < caster.caster_altitude then
			caster.camera_distance = caster.camera_distance - 5
			caster.caster_altitude = caster.caster_altitude - 5
			GameRules:GetGameModeEntity():SetCameraDistanceOverride( caster.camera_distance - 5 )
		end
		if caster.start_bonus < view_distance then
			caster.camera_distance = caster.camera_distance + 10
			caster.start_bonus = caster.start_bonus + 10
			GameRules:GetGameModeEntity():SetCameraDistanceOverride( caster.camera_distance + 10 )
		end
	end
end

function ThrillCastPointBonus( keys )
	local caster = keys.caster
	local ability = keys.ability
	local passive = caster:FindAbilityByName("veera_plains_runner")

	local castpointReduction = 1 - (ability:GetSpecialValueFor("cooldown_reduction") / 100)

	local ability1 = caster:GetAbilityByIndex(0)
	local ability2 = caster:GetAbilityByIndex(1)

	ability1.castpoint = ability1:GetCastPoint()
	ability2.castpoint = ability2:GetCastPoint()
	
	ability1:SetOverrideCastPoint(ability1.castpoint * castpointReduction)
	ability2:SetOverrideCastPoint(ability2.castpoint * castpointReduction)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_thrill_bonus_vision", {})

	caster.stack_count = caster:GetModifierStackCount('modifier_movespeed_cap', passive)
	caster.scepter_stack_count = caster.stack_count
	print(caster.stack_count)

	EmitGlobalSound("Hero_Veera.Thrill.Drums")
	if caster:HasScepter() and caster.stack_count == caster.scepter_stack_count then
		caster.scepter_stack_count = caster.stack_count * 2
		caster:SetModifierStackCount('modifier_movespeed_cap', passive, caster.scepter_stack_count)
	end
	print(caster.scepter_stack_count)
end

function ThrillRemoveBonus( keys )
	local caster = keys.caster
	local passive = caster:FindAbilityByName("veera_plains_runner")
	local ability1 = caster:GetAbilityByIndex(0)
	local ability2 = caster:GetAbilityByIndex(1)
	
	ability1:SetOverrideCastPoint(ability1.castpoint)
	ability2:SetOverrideCastPoint(ability2.castpoint)

	if caster.scepter_stack_count > caster.stack_count then
		caster.scepter_stack_count = caster.stack_count / 2
		caster:SetModifierStackCount('modifier_movespeed_cap', passive, caster.stack_count)
	end
end