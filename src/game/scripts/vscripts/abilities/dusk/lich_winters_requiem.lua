lich_winters_requiem = class({})

LinkLuaModifier("modifier_winters_requiem","abilities/dusk/lich_winters_requiem",LUA_MODIFIER_MOTION_NONE)

function lich_winters_requiem:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local radius = self:GetSpecialValueFor("radius")

		local damage = self:GetSpecialValueFor("damage")

		local n = self:GetSpecialValueFor("targets")
		local buffer_radius = self:GetSpecialValueFor("buffer")
		local delay = self:GetSpecialValueFor("delay")

		local slow_duration = self:GetSpecialValueFor("slow_duration")

		local enemies = FindEnemies(caster,caster:GetAbsOrigin(),radius,nil,DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE)

		shuffleTable(enemies)

		local targets = {}

		caster:EmitSound("Hero_KeeperOfTheLight.ManaLeak.Target")

		for k,v in pairs(enemies) do

			if k <= n then
				CreateParticleHitloc(v, "particles/units/heroes/hero_lich/winters_requiem_target.vpcf")
				table.insert(targets, v)
			else
				break
			end

		end

		for k,v in pairs(targets) do

			Timers:CreateTimer(delay+k*0.15,function()
				if ( caster:GetRangeToUnit(v) < (radius + buffer_radius) )then
					v:EmitSound("Ability.FrostNova")
					CreateParticleHitloc(v, "particles/units/heroes/hero_lich/winters_requiem.vpcf")
					local damage_radius = self:GetSpecialValueFor("damage_radius")
					local found = FindEnemies(caster,v:GetAbsOrigin(),damage_radius)

					-- DebugDrawCircle(v:GetAbsOrigin()+Vector(0,0,15), Vector(255,0,0), 5, damage_radius, false, 1)

					for kk,vv in pairs(found) do
						InflictDamage(vv,caster,self,damage,DAMAGE_TYPE_MAGICAL)
						v:AddNewModifier(caster, self, "modifier_winters_requiem", {Duration=slow_duration})
					end
				end
			end)

		end
	end
end

modifier_winters_requiem = class({})

function modifier_winters_requiem:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_winters_requiem:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return func
end

function modifier_winters_requiem:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow")
end

function InflictDamage(target,attacker,ability,damage,damage_type,flags)
	local flags = flags or 0
	ApplyDamage({
	    victim = target,
	    attacker = attacker,
	    damage = damage,
	    damage_type = damage_type,
	    damage_flags = flags,
	    ability = ability
  	})
end

function shuffleTable( t )
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = RandomInt(1,i)
        t[i], t[j] = t[j], t[i]
    end
end

function FindEnemies(caster,point,radius,targets,flags)
  local targets = targets or DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
  local flags = flags or DOTA_UNIT_TARGET_FLAG_NONE
  return FindUnitsInRadius( caster:GetTeamNumber(),
                            point,
                            nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            targets,
                            flags,
                            FIND_CLOSEST,
                            false)
end

function CreateParticleHitloc(handle,particle_name)
  local p = ParticleManager:CreateParticle(particle_name, PATTACH_POINT_FOLLOW, handle) --[[Returns:int
  Creates a new particle effect
  ]]
  ParticleManager:SetParticleControlEnt(p,0,handle,PATTACH_POINT_FOLLOW,"attach_hitloc",handle:GetCenter(),true)
  return p
end