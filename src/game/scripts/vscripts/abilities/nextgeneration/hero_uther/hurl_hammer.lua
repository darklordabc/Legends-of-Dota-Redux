require('lib/CosmeticLib')
function CancelAttack (keys) -- Make sure the caster doesnt attack enemies, but still can attack allies to heal them
	local caster = keys.caster
	local target = keys.target

	if caster:GetTeamNumber() ~= target:GetTeamNumber() then
		caster:Hold()
	end
end

function ThrowHammer (keys)
	local caster = keys.caster
	local ability = keys.ability

	if not IsServer() then return end

	-- Remove the hammer
	--CosmeticLib:RemoveFromSlot( caster, "weapon" )
	caster.HasHammer = false


	local distance = (caster:GetAbsOrigin() - keys.target_points[1]):Length()

	if caster:HasScepter() then
		hammerOffset = Vector(0,0,180) 
		hammerShake = 1000
		hammerShakeDuration = 1
	else
		hammerOffset = Vector(0,0,90)
		hammerShake = 250
		hammerShakeDuration = 0.5
	end

	hammer_point = keys.target_points[1] + hammerOffset

	--if utherhammer == nil or utherhammer:IsNull() then -- Check if the hammer is on a location or in the casters hands -- HasHammer was added later :/

	local utherhammer = CreateUnitByName("npc_hammer_unit",caster:GetOrigin(), true, nil, nil, caster:GetTeamNumber())
	EmitSoundOn("Hero_Omniknight.Repel",utherhammer)
	ability:ApplyDataDrivenModifier(caster,utherhammer,"modifier_hammer_dummy",{duration = -1})
	local utherdirection = (hammer_point  - caster:GetOrigin()):Normalized()
	utherhammer:SetAngles(caster:GetAngles().x + 45, caster:GetAngles().y, caster:GetAngles().z)
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier(caster,utherhammer,"modifier_hammer_moving_dummy_scepter",{duration = 1})
		utherhammer:SetModelScale(2.00)
		utherhammer:SetDayTimeVisionRange(400)
		utherhammer:SetNightTimeVisionRange(400)
	else
		ability:ApplyDataDrivenModifier(caster,utherhammer,"modifier_hammer_moving_dummy",{duration = 1})
	end


--[[else
		ability:ApplyDataDrivenModifier(caster,utherhammer,"modifier_hammer_moving_dummy",{duration = 1})
		utherdirection = (hammer_point - utherhammer:GetOrigin() ):Normalized()
		caster:RemoveModifierByName("modifier_hammer_stationary_dummy")
	end]]

	utherhammer.angles = utherhammer:GetAngles()
	local baseflip = 55
	local flip = baseflip
	local basejump = ((hammer_point - caster:GetOrigin()):Length2D() + 750) * 0.03
	local jump = basejump
	caster.returnhammer = true

	--Swap main ability with subability
	local subability = 	caster:FindAbilityByName("uther_Hail_Back")
	if subability then
		caster:SwapAbilities(ability:GetName(),subability:GetName(),false,true)
		subability:StartCooldown(2)
	end

	caster.utherhammer = utherhammer

	time_elapsed = 0

	
	local hammer_size = ability:GetLevelSpecialValueFor("Hammer_Size",ability:GetLevel()-1)

	Timers:CreateTimer(0, function()
		local hammer_speed = (hammer_point - utherhammer:GetAbsOrigin()):Length2D() * 0.099
		if utherhammer:HasModifier("modifier_hammer_moving_dummy") or utherhammer:HasModifier("modifier_hammer_moving_dummy_scepter") then
			utherhammer:SetOrigin(utherhammer:GetOrigin() + utherdirection * hammer_speed + Vector(0,0,jump))
			local pitch = utherhammer.angles.x + ((time_elapsed * 3) * flip )
			utherhammer:SetAngles(pitch, utherhammer.angles.y, utherhammer.angles.z)
			time_elapsed = time_elapsed + 0.03
			jump = jump - (basejump * 0.06)
			flip = flip * 0.995
			return 0.03
		else
			local position = GetGroundPosition(utherhammer:GetAbsOrigin(),utherhammer) + hammerOffset
			utherhammer:SetAbsOrigin(position)
			ScreenShake(position, hammerShake, hammerShake, hammerShakeDuration, 2000, 0, true)
			return nil
		end
	end)
end

--[[function HammerPosition (keys) -- Guide the hammer to the right location, speed is reliant on distance.
	local ability = keys.ability
	local caster = keys.caster
	local hammer_speed = (caster.hammer_point - caster.utherhammer:GetAbsOrigin()):Length2D() * 0.099
	local hammer_size = ability:GetLevelSpecialValueFor("Hammer_Size",ability:GetLevel()-1)

	if not IsServer() then return end

	if caster.time_elapsed == nil then caster.time_elapsed = 0 end

	caster.utherhammer:SetOrigin(caster.utherhammer:GetOrigin() + caster.utherdirection * hammer_speed + Vector(0,0,caster.jump))
	local pitch = caster.utherhammer.angles.x + ((caster.time_elapsed * 3) * caster.flip )
	caster.utherhammer:SetAngles(pitch, caster.utherhammer.angles.y, caster.utherhammer.angles.z)
	caster.time_elapsed = caster.time_elapsed + 0.03
	caster.jump = caster.jump - (caster.basejump * 0.06)
	caster.flip = caster.flip * 0.995
end

function HammerFinalPosition (keys) -- Guide the hammer to the right location, speed is reliant on distance.
	local caster = keys.caster
	local position = GetGroundPosition(caster.utherhammer:GetAbsOrigin(),caster.utherhammer) + caster.hammerOffset
	caster.utherhammer:SetAbsOrigin(position)
	ScreenShake(position, caster.hammerShake, caster.hammerShake, caster.hammerShakeDuration, 2000, 0, true)
end]]

function PickUpHammer (keys) -- Check if the caster is very close to his hammer and then pick it up
	local caster = keys.caster
	local ability = caster:FindAbilityByName("uther_Hail_Back")
	local originalAbility = caster:FindAbilityByName("uther_Hurl_Hammer")
	local hammer_size = originalAbility:GetSpecialValueFor("Hammer_Size")

	if caster.utherhammer and (caster:GetOrigin() - caster.utherhammer:GetOrigin()):Length2D() < hammer_size and ability:IsCooldownReady() then
		caster:RemoveModifierByName("modifier_hammer_thrown")
		caster:RemoveModifierByName("modifier_hammer_stationary_dummy")
		StopSoundOn("Hero_Omniknight.Repel",caster.utherhammer)
		caster.utherhammer:RemoveSelf()
		caster.HasHammer = true -- Take the hammer back and show it
		if caster:HasModifier("modifier_argent_smite_passive") then
			--CosmeticLib:ReplaceWithSlotName( caster, "weapon", 7580 )
		else
			--CosmeticLib:ReplaceWithSlotName( caster, "weapon", 100 )
		end

		caster:SwapAbilities(ability:GetName(),originalAbility:GetName(),false,true)
		caster.time_elapsed = 0
	end
end

function RemoveHammer (keys) -- Clean up on death
	local caster = keys.caster
	if not caster.utherhammer:IsNull() then
		caster.utherhammer:ForceKill(false)
	end
	local ability = caster:FindAbilityByName("uther_Hail_Back")
	local originalAbility = caster:FindAbilityByName("uther_Hurl_Hammer")
	caster:SwapAbilities(ability:GetName(),originalAbility:GetName(),false,true)
end

function ReturnHammer (keys) -- The hammer returning to uther, damaging units in its path.
	local caster = keys.caster
	if caster.utherhammer ~= nil and not caster.utherhammer:IsNull() and caster.returnhammer == true then
		caster.returnhammer = false
		local ability = caster:FindAbilityByName("uther_Hurl_Hammer")
		local hammer_speed = ((caster:GetOrigin() - caster.utherhammer:GetOrigin()):Length2D() + 100) * 0.04
		local direction = (caster:GetOrigin() - caster.utherhammer:GetOrigin()):Normalized()
		local hammer_size = ability:GetLevelSpecialValueFor("Hammer_Size",ability:GetLevel()-1)

		local baseflip = 52.5
		local flip = baseflip
		local basejump = ((caster.utherhammer:GetOrigin() - caster:GetOrigin()):Length2D() + 750) * 0.03
		local jump = basejump

		local time_elapsed = 0
		caster.utherhammer.angles = caster.utherhammer:GetAngles()
		caster.utherhammer.angles.x = caster.utherhammer.angles.x + 45

		if hammer_speed < hammer_size then
			Timers:CreateTimer(function()
				if caster:HasModifier("modifier_hammer_stationary_dummy") and not caster.utherhammer:IsNull() then
					local direction = (caster:GetAbsOrigin() - caster.utherhammer:GetOrigin()):Normalized()
					caster.utherhammer:SetAbsOrigin(caster.utherhammer:GetOrigin() + direction * hammer_speed)
					local pitch = (caster.utherhammer.angles.x + ((time_elapsed * 3) * flip) * 1.4)
					caster.utherhammer:SetAngles(-pitch, caster.utherhammer.angles.y, caster.utherhammer.angles.z)
					time_elapsed = time_elapsed + 0.03
					flip = flip * 0.996
					if time_elapsed > 2.5 then
						caster.utherhammer:SetAbsOrigin(caster:GetOrigin())
					end
					return 0.03
				end
				return nil
			end)
		else
			caster.utherhammer:SetAbsOrigin(caster:GetOrigin())
		end
	end
end

function HammerParticle(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	Timers:CreateTimer(1.0, function()
		local modifier = target:FindModifierByName("modifier_hammer_dummy")
		if modifier then
			local hammerParticle = ParticleManager:CreateParticle("particles/econ/courier/courier_trail_05/courier_trail_05.vpcf",PATTACH_ABSORIGIN,caster)
			ParticleManager:SetParticleControl(hammerParticle,0,target:GetAbsOrigin() + Vector(0, 0, 100))
			modifier:AddParticle(hammerParticle, false, false, 1, false, false)
		end
	end)
end

function LearnHurlBack(keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("uther_Hail_Back")
	if ability:GetLevel() == 0 then
		ability:SetLevel(1)
	end
end
	