function AddModifier(event)
	local target = event.target
	if not target:IsBuilding() --сколько проверок то
	and not target:IsIllusion() 
	and not target:HasModifier("modifier_kill")
	and not string.find(target:GetUnitName(),"megaboss") then 
		event.ability:ApplyDataDrivenModifier(event.caster, target, "modifier_dark_ranger_black_arrow_spawn", nil)
	end

end

function BlackArrow(event)
	local target = event.unit
	local caster = event.caster
	local lifetime = event.ability:GetSpecialValueFor("lifetime")

	local creep = CreateUnitByName(target:GetUnitName(), target:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	creep:SetControllableByPlayer(caster:GetPlayerID(), true)
	creep:AddNewModifier(caster, event.ability, "modifier_kill", {duration = lifetime})
	--creep:AddNewModifier(caster, event.ability, "modifier_illusion", nil)
	event.ability:ApplyDataDrivenModifier(caster, target, "modifier_dark_ranger_black_arrow_unit", nil)
	creep:SetRenderColor(249, 127, 127)
	creep:MakeIllusion()
	creep:SetAcquisitionRange(800)
end
