erra_morbid_blade = class({})

if IsServer() then

	function erra_morbid_blade:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()

		local radius = self:GetSpecialValueFor("radius")
		local threshold = self:GetSpecialValueFor("pure_threshold")

		local damage = self:GetAbilityDamage()
		local lifesteal = (self:GetSpecialValueFor("lifesteal")/100)

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
				damage_type = DAMAGE_TYPE_PURE
				self:EndCooldown()
				self:StartCooldown(self:GetCooldown(self:GetLevel())*0.5)
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
end

function DealDamage(target,attacker,damageAmount,damageType,ability,damageFlags)
  local target = target
  local attacker = attacker or target -- if nil we assume we're dealing self damage
  local dmg = damageAmount
  local dtype = damageType
  local flags = damageFlags or DOTA_DAMAGE_FLAG_NONE
  local ability = ability or nil
  if not IsValidEntity(target) and type(target) == "table" then
    for kd,vd in pairs(target) do
      if IsValidEntity(vd) then
        ApplyDamage({
          victim = vd,
          attacker = attacker,
          damage = dmg,
          damage_type = dtype,
          damage_flags = flags,
          ability = ability
        })
      end
    end
    return
  end
  ApplyDamage({
    victim = target,
    attacker = attacker,
    damage = dmg,
    damage_type = dtype,
    damage_flags = flags,
    ability = ability
  })
end

function FastDummy(target, team, duration, vision)
  duration = duration or 0.03
  vision = vision or  250
  local dummy = CreateUnitByName("npc_dummy_unit", target, false, nil, nil, team)
  if dummy ~= nil then
    dummy:SetAbsOrigin(target) -- CreateUnitByName uses only the x and y coordinates so we have to move it with SetAbsOrigin()
    dummy:SetDayTimeVisionRange(vision)
    dummy:SetNightTimeVisionRange(vision)
    dummy:AddNewModifier(dummy, nil, "modifier_phased", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_invulnerable", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_kill", {duration = duration+0.03})
    Timers:CreateTimer(duration,function()
      if not dummy:IsNull() then
        dummy:ForceKill(true)
        --dummy:Destroy()
        UTIL_Remove(dummy)
      end
    end)
  end
  return dummy
end