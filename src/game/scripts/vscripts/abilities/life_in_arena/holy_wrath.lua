LinkLuaModifier("modifier_lord_of_lightning_holy_wrath_slow", "abilities/life_in_arena/modifier_lord_of_lightning_holy_wrath_slow.lua",LUA_MODIFIER_MOTION_NONE)

function damageTo(event)
	local caster = event.caster
	--local target = event.target
	local attacker = event.attacker
	local ability = event.ability

	if not ability:IsCooldownReady() then 
		return 
	end
	
	if attacker:IsBuilding() or attacker:IsOther() then return end
	--
	local damage_per_int = ability:GetSpecialValueFor("damage_per_int")
	local radius_dop_dmg = ability:GetSpecialValueFor("radius_dop_dmg")
	local intcast = caster:GetBaseIntellect()
	--
	local damageType = DAMAGE_TYPE_MAGICAL
	local damage = damage_per_int * intcast
	--
	--print("		caster = ", caster )
	--print("		target = ", target )
	--print("		unit = ", event.unit )
	--print("		attacker = ", attacker )

	ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1))

	local damage_table = { 
	  attacker = caster,
		damage_type = damageType, 
		damage = damage,
		ability = ability,
		victim = attacker,
	}
		
	ApplyDamage(damage_table)
	attacker:Purge(true, false, false, false, false)
	attacker:AddNewModifier(caster, ability, "modifier_lord_of_lightning_holy_wrath_slow", {duration = 1})
		
	local lightning = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_CUSTOMORIGIN, attacker)
    local loc = attacker:GetAbsOrigin()
    ParticleManager:SetParticleControl(lightning, 0, loc + Vector(0, 0, 1000))
    ParticleManager:SetParticleControl(lightning, 1, loc)
    ParticleManager:SetParticleControl(lightning, 2, loc)

	EmitSoundOn("Hero_Leshrac.Lightning_Storm", attacker)	

	local targets = FindUnitsInRadius(caster:GetTeam() ,attacker:GetAbsOrigin(), nil, radius_dop_dmg, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for _,unit in pairs(targets) do 
		ApplyDamage({victim = unit, attacker = caster, damage = damage/2, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
	end

end 
