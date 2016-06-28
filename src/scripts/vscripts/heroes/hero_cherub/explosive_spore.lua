function GetSummonPoints( event )
	local caster = event.caster
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local distance = event.distance

	local front_position = origin + fv * distance

	local result = { }
		table.insert(result, front_position)
	return result
end

function SetUnitsMoveForward( event )
	local caster = event.caster
	local target = event.target
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	target:SetForwardVector(fv)
	-- Add the target to a table on the caster handle, to find them later
	table.insert(caster.wolves, target)
end

function ExplosiveSporeSound( keys )
	print( keys.target:GetHealth() )
	if not keys.target:IsAlive() then
		local particleName = "particles/cherub_explosive_spore.vpcf"
		local soundEventName = "Ability.Techies_LandMines"
		
		local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, keys.target )
		StartSoundEvent( soundEventName, keys.target )
	end
end
