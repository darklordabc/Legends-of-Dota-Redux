function CycloneCheck( keys )
	local caster = keys.caster
	local ability = keys.ability
	local thinker = keys.target
	local cyclone_radius = keys.radius
	
	local units = FindUnitsInRadius(caster:GetTeam(), thinker:GetAbsOrigin(), nil, cyclone_radius, 
	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	
	if #units > 0 then
		for i, individual_unit in ipairs(units) do
			if not individual_unit:HasModifier("modifier_cyclone_armor_reduction") and not individual_unit:HasModifier("modifier_cyclone_immunity") and not individual_unit:IsMagicImmune() and not individual_unit:HasModifier("modifier_roshan_bash") then
				individual_unit:EmitSound("DOTA_Item.Cyclone.Activate")
				ability:ApplyDataDrivenModifier(caster, individual_unit, "modifier_cyclone_immunity", {} )
				ability:ApplyDataDrivenModifier(caster, individual_unit, "modifier_eul_cyclone", {Duration = 2.5} )
				thinker:ForceKill(true)
				break
			end
		end
	end
end
