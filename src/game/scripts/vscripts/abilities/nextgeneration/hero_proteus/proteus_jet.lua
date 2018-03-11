function Jet( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local pID = caster:GetPlayerOwnerID()
	
	if caster:PassivesDisabled() then 
		ability:EndCooldown()
		ability:RefundManaCost()
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", caster:GetPlayerOwner())
		UTIL_MessageText(pID, "You cannot use this ability while passives are disabled.", 255, 0, 0, 2.0)
		return 
	end

	-- Distance calculations
	local speed = ability:GetSpecialValueFor("jet_speed")
	local distance =  ability:GetSpecialValueFor("jet_distance")
	local direction = caster:GetForwardVector()

	if caster:HasModifier("modifier_proteus_jet_charges") then
		modifierStacks = caster:GetModifierStackCount("modifier_proteus_jet_charges", ability) - 1
		ability:EndCooldown()
		caster:SetModifierStackCount("modifier_proteus_jet_charges",ability,modifierStacks)
		if modifierStacks < 1 then
			caster:RemoveModifierByName("modifier_proteus_jet_charges")
		end
	end

	-- Saving the data in the ability
	ability.distance = distance
	
	ability.speed = speed / 30 -- 1/30 is how often the motion controller ticks
	ability.direction = direction
	ability.traveled_distance = 0
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = 2})
end

function JetMotion(keys)
	local caster = keys.caster
	local ability = keys.ability
	-- Move the caster while the distance traveled is less than the original distance upon cast
	local original_position = caster:GetAbsOrigin()
	if ability.traveled_distance < ability.distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.direction * ability.speed)
		ability.traveled_distance = ability.traveled_distance + ability.speed
		particle_jet = ParticleManager:CreateParticle("particles/proteus_jet_trail.vpcf", PATTACH_ABSORIGIN, caster)
	else
		-- Remove the motion controller once the distance has been traveled
		caster:InterruptMotionControllers(true)
		caster:RemoveModifierByName("modifier_proteus_jet_push")
	end
end

--[[function JetSilenced(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:IsSilenced() and caster:GetMana() > ability:GetManaCost(-1) and ability:GetAutoCastState() then
		ability:OnSpellStart()
		caster:SpendMana(ability:GetManaCost(-1))
		ability:StartCooldown(ability:GetCooldown(-1))
	end
end]]

function jetOrder(filterTable)
	local units = filterTable["units"]
	local issuer = filterTable["issuer_player_id_const"]
	local order_type = filterTable["order_type"]
	local abilityIndex = filterTable["entindex_ability"]
	local ability = EntIndexToHScript(abilityIndex)

	local caster = EntIndexToHScript(units["0"])
	if not IsValidEntity(caster) then return false end

	if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		local jet = caster:FindAbilityByName("proteus_jet")
		if jet and jet:GetAutoCastState() == true and jet:IsCooldownReady() and caster:GetMana() >= jet:GetManaCost(-1) and not caster:PassivesDisabled() then
			local posX = filterTable["position_x"]
			local posY = filterTable["position_y"]
			local posZ = filterTable["position_z"]
			local location = Vector(posX, posY, posZ)
			local distance = (caster:GetAbsOrigin() - location):Length2D()

			local vectorTarget = (location - caster:GetOrigin()):Normalized().y * 180
			local vectorForward = caster:GetForwardVector().y * 180
			local angle_difference = (vectorTarget - vectorForward)
			local result_angle = angle_difference / math.pi
			abs_result_angle = math.abs(result_angle)

			if abs_result_angle < 5 and distance > 900 and vectorTarget * vectorForward > 0 then
				if not caster:HasModifier("modifier_proteus_jet_charges") then
					jet:StartCooldown(jet:GetCooldown(-1))
				end
				jet:OnSpellStart()
				caster:SpendMana(jet:GetManaCost(-1), caster)
				
			end
		end
	elseif order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
		local targetIndex = filterTable["entindex_target"]
		local target = EntIndexToHScript(targetIndex)
		local jet = caster:FindAbilityByName("proteus_jet")
		if jet and jet:GetAutoCastState() == true and jet:IsCooldownReady() and caster:GetMana() >= jet:GetManaCost(-1) and not caster:PassivesDisabled() then
			local distance = (caster:GetOrigin() - target:GetOrigin()):Length()

			local vectorTarget = (target:GetOrigin() - caster:GetOrigin()):Normalized().y  * 180
			local vectorForward = caster:GetForwardVector().y * 180
			local angle_difference = (vectorTarget - vectorForward)
			local result_angle = angle_difference / math.pi
			abs_result_angle = math.abs(result_angle)

			if abs_result_angle < 5 and distance > 900 and vectorTarget * vectorForward > 0 then
				if not caster:HasModifier("modifier_proteus_jet_charges") then
					jet:StartCooldown(jet:GetCooldown(-1))
				end
				jet:OnSpellStart()
				caster:SpendMana(jet:GetManaCost(-1), caster)
			end
		end
	end

	return true
end