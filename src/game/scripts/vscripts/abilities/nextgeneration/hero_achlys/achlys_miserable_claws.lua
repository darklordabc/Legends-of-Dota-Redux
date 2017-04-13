function IncreaseStackCount( keys )
    -- Variables
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local modifier_name = keys.modifier_counter_name
    local dur = ability:GetDuration()

    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    -- if the unit does not already have the counter modifier we apply it with a stackcount of 1
    -- else we increase the stack and refresh the counters duration
    if not modifier then
        ability:ApplyDataDrivenModifier(caster, target, modifier_name, {duration=dur})
        target:SetModifierStackCount(modifier_name, caster, 1)
    else
        modifier:IncrementStackCount()
        modifier:SetDuration(dur, true)
    end
end

--[[
    Author: Bude
    Date: 30.09.2015
    Decreases stack count on the visual modifier 
    This is called whenever the debuff modifier runs out
]]
function DecreaseStackCount(keys)
    --Variables
    local caster = keys.caster
    local target = keys.target
    local modifier_name = keys.modifier_counter_name
    local count = target:GetModifierStackCount(modifier_name, caster)
	local modifier = target:FindModifierByName(modifier_name)
	if modifier then
		modifier:DecrementStackCount()
		if modifier:GetStackCount() == 0 then
			target:RemoveModifierByName(modifier_name)
		end
	end
end

function CheckRoot(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local victim_angle = target:GetAnglesAsVector().y
	local origin_difference = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	attacker_angle = attacker_angle + 180.0

	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)

	if not (result_angle >= (-(90 / 2)) and result_angle <= ((90 / 2))) and target:GetIdealSpeed() == 100 and not target:HasModifier("modifier_achlys_miserable_claws_root") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_achlys_miserable_claws_root", {duration = ability:GetSpecialValueFor("root_duration")})
	end
end

function CheckAngle(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local victim_angle = target:GetAnglesAsVector().y
	local origin_difference = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	attacker_angle = attacker_angle + 180.0

	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)

	if result_angle >= (-(90 / 2)) and result_angle <= ((90 / 2)) then
		target:RemoveModifierByName("modifier_achlys_miserable_claws_root")
	end
end