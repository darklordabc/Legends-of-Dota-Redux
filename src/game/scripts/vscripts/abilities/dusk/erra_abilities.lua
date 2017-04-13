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


function MorbidBlade(keys)
	local caster = keys.caster
	local point = caster:GetCursorPosition()

	local radius = keys.radius
	local threshold = keys.threshold

	local damage = keys.dmg
	local lifesteal = (keys.lifesteal/100)

	local sound = "Erra.MorbidBlade"
	local particle = "particles/units/heroes/hero_erra/morbid_blade.vpcf"

	local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                  point,
                  nil,
                    radius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_CLOSEST,
                    false)
	-- Check for Health amount
	local damage_type = DAMAGE_TYPE_PHYSICAL
	for k,v in pairs(enemy_found) do
		if v:GetHealthPercent() < threshold then
			damage_type = DAMAGE_TYPE_PURE keys.ability:EndCooldown()
			keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel())*0.5)
			sound = "Erra.MorbidBlade.Pure"
			particle = "particles/units/heroes/hero_erra/morbid_blade_below_threshold.vpcf"
			break
		end
	end

	local unit = FastDummy(point,caster:GetTeam(),2,radius)

	local p = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, unit) --[[Returns:int
	Creates a new particle effect
	]]

	ParticleManager:SetParticleControl(p, 1, Vector(radius,0,0)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	unit:EmitSound(sound)

	for k,v in pairs(enemy_found) do
		DealDamage(v,caster,damage,damage_type)

		if v:IsHero() then
			caster:Heal(v:GetHealthDeficit()*lifesteal,caster)
		else
			caster:Heal(v:GetHealthDeficit()*(lifesteal*0.5),caster)
		end
	end
end

function ToDust(keys)
	print("TO DUST")
	local caster = keys.caster

	local damage = keys.dmg/100

	local creep_damage = keys.dmg_creep/100

	local radius = keys.radius or 875

	if radius == 0 then radius = 875 end

	print("RADIUS: "..radius)

	local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                  caster:GetCenter(),
                  nil,
                    radius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_CLOSEST,
                    false)

	local enemy_creep = FindUnitsInRadius( caster:GetTeamNumber(),
                  caster:GetCenter(),
                  nil,
                    radius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_CREEP,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_CLOSEST,
                    false)

	local total_damage_bonus = 0

	for k,v in pairs(enemy_found) do
		print(v:GetUnitName())
		total_damage_bonus = total_damage_bonus + v:GetHealthDeficit() * damage
		ParticleManager:CreateParticle("particles/units/heroes/hero_erra/to_dust_affected_unit.vpcf", PATTACH_ABSORIGIN_FOLLOW, v) --[[Returns:int
		Creates a new particle effect
		]]
	end

	for k,v in pairs(enemy_creep) do
		print(v:GetUnitName())
		total_damage_bonus = total_damage_bonus + v:GetHealthDeficit() * creep_damage
		ParticleManager:CreateParticle("particles/units/heroes/hero_erra/to_dust_affected_unit.vpcf", PATTACH_ABSORIGIN_FOLLOW, v) --[[Returns:int
		Creates a new particle effect
		]]
	end

	total_damage_bonus = math.floor(total_damage_bonus)

	print(total_damage_bonus)

	if total_damage_bonus > 0 then
		caster:EmitSound("Erra.ToDust")
		local mod = keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_to_dust_damage", {}) --[[Returns:void
		No Description Set
		]]

		mod:SetStackCount(total_damage_bonus)

		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_to_dust_show", {}) --[[Returns:void
		No Description Set
		]]
	end

end

function GraveGuard(keys)
	local caster = keys.caster

	local hp = caster:GetHealthPercent()

	local threshold = keys.threshold

	if not caster:IsRealHero() then return end

	if hp < threshold and keys.ability:IsCooldownReady() and keys.ability:IsOwnersManaEnough() then
		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()-1))
		caster:SpendMana(keys.ability:GetManaCost(keys.ability:GetLevel()), keys.ability) --[[Returns:void
		Spend mana from this unit, this can be used for spending mana from abilities or item usage.
		]]
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_erra_grave_guard_recovery", {}) --[[Returns:void
		No Description Set
		]]
		caster:EmitSound("Erra.GraveGuard") --[[Returns:void
		 
		]]
	end
end