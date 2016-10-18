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

	local creep = CreateUnitByName(target:GetUnitName(), target:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber())
	creep:SetControllableByPlayer(caster:GetPlayerID(), true)
	creep:AddNewModifier(caster, event.ability, "modifier_kill", {duration = lifetime})
	--creep:AddNewModifier(caster, event.ability, "modifier_illusion", nil)
	-- event.ability:ApplyDataDrivenModifier(caster, creep, "modifier_dark_ranger_black_arrow_unit", nil)
	creep:AddNewModifier(caster, event.ability, "modifier_illusion", {duration = lifetime, outgoing_damage = event.ability:GetSpecialValueFor("outgoing_damage"), incoming_damage = event.ability:GetSpecialValueFor("incoming_damage")})
	creep:SetRenderColor(249, 127, 127)
	
	if target:IsRealHero() then
		local target_level = target:GetLevel()
	    for i = 1, target_level - 1 do
	        creep:HeroLevelUp(false)
	    end
	end

	creep:MakeIllusion()
end
