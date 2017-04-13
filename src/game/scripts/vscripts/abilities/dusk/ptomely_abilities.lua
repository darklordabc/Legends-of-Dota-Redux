function FastDummy(target, team, duration, vision)
  duration = duration or 0
  vision = vision or  250
  local dummy = CreateUnitByName("npc_dummy_unit_dusk", target, false, nil, nil, team)
  if dummy ~= nil then
    dummy:SetAbsOrigin(target) -- CreateUnitByName uses only the x and y coordinates so we have to move it with SetAbsOrigin()
    dummy:SetDayTimeVisionRange(vision)
    dummy:SetNightTimeVisionRange(vision)
    dummy:AddNewModifier(dummy, nil, "modifier_phased", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_invulnerable", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_kill", {duration = duration })
    
  end
  return dummy
end

function DealDamage(target,attacker,damageAmount,damageType,damageFlags,ability)
  local target = target
  local attacker = attacker or target -- if nil we assume we're dealing self damage
  local dmg = damageAmount
  local dtype = damageType
  local flags = damageFlags or DOTA_DAMAGE_FLAG_NONE
  -- Damage Flags are:
  -- DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
  -- DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY
  -- DOTA_DAMAGE_FLAG_BYPASSES_MAGIC_BLOCK
  -- DOTA_DAMAGE_FLAG_BYPASSES_MAGIC_IMMUNITY
  -- DOTA_DAMAGE_FLAG_HPLOSS
  -- DOTA_DAMAGE_FLAG_IGNORS_COMPOSITE_ARMOR
  -- DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR
  -- DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR
  -- DOTA_DAMAGE_FLAG_NONE
  -- DOTA_DAMAGE_FLAG_NON_LETHAL
  -- DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
  -- DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT
  -- DOTA_DAMAGE_FLAG_REFLECTION
  -- DOTA_DAMAGE_FLAG_USE_COMBAT_PROFICIENCY
  
  if not IsValidEntity(target) and type(target) == "table" then -- assume a table was passed
  print("[DealDamage] Dealing "..dmg.." of type "..dtype.." from attacker "..attacker:GetName().." to the following targets: ")
    for kd,vd in pairs(target) do
      if IsValidEntity(vd) then
      print("==[DealDamage] Target "..k..": "..v:GetName())
        ApplyDamage({
          victim = vd,
          attacker = attacker,
          damage = dmg,
          damage_type = dtype,
          damage_flags = flags
        })
      end
    end
    return
  end
  
  print("[DealDamage] Dealing "..dmg.." of type "..dtype.." to "..target:GetName().." from attacker "..attacker:GetName())
  
  ApplyDamage({
    victim = target,
    attacker = attacker,
    damage = dmg,
    damage_type = dtype,
    damage_flags = flags
  })
end

function astralise(keys)
	local caster = keys.caster
	local target = keys.target
	local duration = keys.duration
	local p_duration = keys.p_duration

	local damage = keys.damage

	local mod = "modifier_astralise"

	local unit_mod = "modifier_astralise_pulse"

	local ally_mod = "modifier_astralise_ally"

	local loc = target:GetAbsOrigin() + target:GetForwardVector()*-200

	loc = loc + Vector(0,0,90)

	local unit = FastDummy(loc,caster:GetTeam(),duration+2,0)

	-- local ab = unit:FindAbilityByName("astral_ghost_immunities") --[[Returns:handle
	-- Retrieve an ability by name from the unit.
	-- ]]

	-- ab:SetLevel(1)

	target:EmitSound("Ptomely.Astralise")

	if target:GetTeam() ~= caster:GetTeam() then

		DealDamage(target,caster,damage,DAMAGE_TYPE_MAGICAL)

	else
		keys.ability:ApplyDataDrivenModifier(caster, target, ally_mod, {Duration=duration}) --[[Returns:void
		No Description Set
		]]
	end

	unit.astralise_linked_unit = target

	-- target.astralise_linked_unit = unit

	unit.astralise_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ptomely/astralise_ghost.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit) --[[Returns:int
	Creates a new particle effect
	]]

	Timers:CreateTimer(p_duration,function() ParticleManager:DestroyParticle(unit.astralise_particle,false) end)

	keys.ability:ApplyDataDrivenModifier(caster, target, mod, {Duration=duration}) --[[Returns:void
	No Description Set
	]]
	keys.ability:ApplyDataDrivenModifier(caster, unit, unit_mod, {Duration=p_duration}) --[[Returns:void
	No Description Set
	]]
end

function astralise_pulse(keys)
	local caster = keys.caster
	local target = keys.target -- unit

	local owner = target
	local int = 1

	if target.astralise_linked_unit then
		owner = target.astralise_linked_unit
	end

	target:EmitSound("Ptomely.AstralisePulse")

	if owner:IsHero() then int = owner:GetIntellect() end

	local radius = keys.radius

	local damage = keys.damage/100

	local fdmg = int*damage

	-- local team_mult = 1

	-- if caster:GetTeam() == owner:GetTeam() then
	-- 	team_mult = 0.5
	-- end

	--owner:ReduceMana(fdmg*team_mult)

	local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                              target:GetCenter(),
                              nil,
                                radius,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_CLOSEST,
                                false)

	local ally_found = FindUnitsInRadius( caster:GetTeamNumber(),
                          target:GetCenter(),
                          nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_CLOSEST,
                            false)

	for k,v in pairs(enemy_found) do
		DealDamage(v,caster,fdmg,DAMAGE_TYPE_MAGICAL)
	end

	for k,v in pairs(ally_found) do
		v:Heal(fdmg/2,caster)
	end

	local p = ParticleManager:CreateParticle("particles/units/heroes/hero_ptomely/astralise_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --[[Returns:int
	Creates a new particle effect
	]]

	ParticleManager:SetParticleControl(p, 1, Vector(radius,0,0)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]
end

function mirror_blade_damage(keys)
	local caster = keys.caster
	local target = keys.target

	local int = caster:GetIntellect()

	local dmg = keys.dmg

	local fdmg = int*dmg

	target:EmitSound("Ptomely.MirrorBladeHit")

	DealDamage(target,caster,fdmg,DAMAGE_TYPE_PHYSICAL)
end

function mirror_blade(keys)
	local caster = keys.caster

	local point = caster:GetCursorPosition()

	local direction = (point - caster:GetAbsOrigin()):Normalized()

	local blades = keys.blades or 5

	local origin = caster:GetAbsOrigin()

	local projectile_speed = keys.projectile_speed
	local radius = keys.radius
	local range = keys.range
	local vision_radius = keys.vision_radius

	local n = 0

	local unit = FastDummy(origin,caster:GetTeam(),1.5,250)

	Timers:CreateTimer(0.20,function()
		local rv = RandomVector(RandomInt(0,0.2))
		local info = 
		  {
		  Ability = keys.ability,
		  EffectName = "particles/units/heroes/hero_ptomely/mirror_blade.vpcf",
		  vSpawnOrigin = origin,
		  fDistance = range,
		  fStartRadius = radius,
		  fEndRadius = radius,
		  Source = caster,
		  bHasFrontalCone = false,
		  bReplaceExisting = false,
		  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		  iUnitTargetType = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
		  fExpireTime = GameRules:GetGameTime() + 10.0,
		  vVelocity = (direction+rv) * projectile_speed,
		  bProvidesVision = true,
		  iVisionRadius = vision_radius,
		  iVisionTeamNumber = caster:GetTeamNumber()
		  }
		unit:EmitSound("Ptomely.MirrorBlade")
		ProjectileManager:CreateLinearProjectile(info) --[[Returns:int
		Creates a linear projectile and returns the projectile ID
		]]
		n = n+1
		if n < blades then
			return 0.20
		end
	end)
end

function expunge(keys)
	local caster = keys.caster
	local target = keys.target

	local pct = keys.pct/100

	local mp = target:GetMana()

	local bonus_mp = 0

	local bonus_pct = 0

	local aghs = false

	if caster:HasScepter() then
		bonus_pct = keys.aghs_pct/100
		bonus_mp = target:GetMaxMana()
		aghs = true
	end

	local damage = keys.dmg or 1

	local delay = keys.delay or 2.5

	local base = keys.base

	local amt = mp*pct + base

	if aghs then
		amt = mp*pct + bonus_mp*bonus_pct + base
	end

	print(amt..", ".."Aghs: "..bonus_mp*bonus_pct.." Mana")

	local radius = keys.radius

	local total_damage = damage*amt

	local particle_name = "particles/units/heroes/hero_ptomely/expunge.vpcf"

	local particle_trail = "particles/units/heroes/hero_ptomely/expunge_drain.vpcf"

	--target:ReduceMana(amt)
	-- We're reducing Mana over time with the modifier, so we don't need this.

	local mod = keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_expunge", {Duration=delay}) --[[Returns:void
	No Description Set
	]]

	if not target.expunge_mana_drain then

		target.expunge_mana_drain = amt

	else
		-- In case of Refresher
		target.expunge_mana_drain = target.expunge_mana_drain + amt

	end

	local unit = FastDummy(target:GetAbsOrigin(),caster:GetTeam(), 8, 1000)

	local p = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, unit) --[[Returns:int
	Creates a new particle effect
	]]

	unit:EmitSound("Ptomely.ExpungeCharge")

	ParticleManager:SetParticleControl(p, 1, unit:GetAbsOrigin()+Vector(0,0,350)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	ParticleManager:SetParticleControl(p, 2, Vector(radius,0,0)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	local p2 = ParticleManager:CreateParticle(particle_trail, PATTACH_ABSORIGIN_FOLLOW, target) --[[Returns:int
	Creates a new particle effect
	]]

	ParticleManager:SetParticleControl(p2, 1, unit:GetAbsOrigin()+Vector(0,0,350)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	ScreenShake(unit:GetCenter(), 1200, 50, delay, 1200, 0, true)

	Timers:CreateTimer(delay,function()
		local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                          unit:GetCenter(),
                          nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_CLOSEST,
                            false)

		local ally_found = FindUnitsInRadius( caster:GetTeamNumber(),
                          unit:GetCenter(),
                          nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_CLOSEST,
                            false)

		ScreenShake(unit:GetCenter(), 1200, 170, 0.4, 1200, 0, true)

		unit:EmitSound("Ptomely.ExpungeBoom")

		ParticleManager:DestroyParticle(p,false)
		ParticleManager:DestroyParticle(p2,false)

		for k,v in pairs(enemy_found) do
			DealDamage(v,caster,total_damage,DAMAGE_TYPE_MAGICAL)
		end

		for k,v in pairs(ally_found) do
			v:GiveMana(amt/2)
		end
	end)
end

function expunge_drain(keys)
	local caster = keys.caster
	local target = keys.target

	-- local mp = target:GetMana()

	if not target.expunge_mana_drain then return end

	local drain = target.expunge_mana_drain
	local time = 2.5

	local interval = 0.1

	local amt_per_tick = drain/(time/interval)

	target:ReduceMana(amt_per_tick) --[[Returns:void
	Remove mana from this unit, this can be used for involuntary mana loss, not for mana that is spent.
	]]

end

function expunge_end(keys)
	local caster = keys.caster
	local target = keys.target

	if not target.expunge_mana_drain then
		return
	else
		target.expunge_mana_drain = nil
	end
end