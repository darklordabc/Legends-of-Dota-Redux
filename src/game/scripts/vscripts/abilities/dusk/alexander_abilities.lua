function CheckClass(input, class)
  -- building exception:
  if class == "npc_dota_building" then -- since we want to include all buildings, we add the tower class as well
    class = {
      [1] = "npc_dota_building",
      [2] = "npc_dota_tower",
      [3] = "npc_dota_fort",
      [4] = "npc_dota_barracks",
    }
  end
  if type(class) == "table" then
    for k,v in pairs(class) do
      if input:GetClassname() == v then return true end
    end
    return false -- the loop ended without finding anything so we return false 
  end
  print("[CheckClass] Class check for input, class found is: "..input:GetClassname()) -- only prints if not a table of course
  
  if input:GetClassname() == class then return true else return false end
end

function Steadfast(keys)
	local caster = keys.caster
	local hp = caster:GetHealth()

	local dpct = keys.hp_damage/100

	local d = math.ceil(dpct*hp)

	if not caster:HasModifier("modifier_alexander_steadfast_regen") then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_alexander_steadfast_regen", {}) --[[Returns:void
		No Description Set
		]]
	end

	local mod = caster:FindModifierByName("modifier_alexander_steadfast_regen")

	if d > 0 then
		mod:SetStackCount(d)
	else
		caster:RemoveModifierByName("modifier_alexander_steadfast_regen")
	end
	
end

function Godfall(keys)
	local caster = keys.caster
	local target = keys.target or keys.unit

	local radius = 800

	local damage = caster:GetAverageTrueAttackDamage(caster)

	local m = keys.mult/100

	local scepter_mult = keys.scepter_mult/100

	local final = m*damage

	if CheckClass(target,"npc_dota_building") then return end

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_alexander/godfall_strike.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, Vector(0,0,0)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin()) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) --[[Returns:void
	No Description Set
	]]

	target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=0.5}) --[[Returns:void
	No Description Set
	]]

	target:Purge(true,false,false,false,false)

	DealDamage(target,caster,final,DAMAGE_TYPE_PURE)

	target:EmitSound("Alexander.Godfall")

	if caster:HasScepter() then
		local enemy_found = FindUnitsInRadius( caster:GetTeamNumber(),
                              target:GetAbsOrigin(),
                              nil,
                                radius,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                FIND_CLOSEST,
                                false)

		for k,v in pairs(enemy_found) do
			Timers:CreateTimer(k*0.2,
				function ()
					if k ~= 1 then 
						local particle2 = ParticleManager:CreateParticle("particles/econ/items/luna/luna_lucent_ti5_gold/luna_lucent_beam_impact_ti_5_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
						ParticleManager:SetParticleControl(particle2, 0, v:GetAbsOrigin()) --[[Returns:void
						Set the control point data for a control on a particle effect
						]]
						ParticleManager:SetParticleControl(particle2, 1, v:GetAbsOrigin()) --[[Returns:void
						Set the control point data for a control on a particle effect
						]]
						DealDamage(v,caster,final*scepter_mult,DAMAGE_TYPE_PURE)
						v:EmitSound("Hero_Luna.LucentBeam.Target")
						if not v:IsRealHero() then caster:Heal(final*scepter_mult*0.50, caster) else
							caster:Heal(final*scepter_mult, caster)
						end
					end
				end)
		end
	end

	caster:RemoveModifierByName("modifier_alexander_godfall")
end

function GodfallSound(keys)
	local target = keys.target

	target:EmitSound("Alexander.Godfall.Charged")

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_alexander/godfall_success.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, Vector(0,0,0)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) --[[Returns:void
	No Description Set
	]]
end

function GodfallSoundStop(keys)
	local target = keys.target

	target:StopSound("Alexander.Godfall.Charged")
end

function elandras_blessing(keys)
	local caster = keys.caster
	local unit = keys.target or keys.unit
	local attacker = keys.attacker
	local damage = keys.damage/100
	local fdamage = 0
	local particle = "particles/units/heroes/hero_alexander/greater_vitality_damage.vpcf"

	if not unit:IsHero() then return end
	if CheckClass(attacker,"npc_dota_building") then return end

	local main_stat = unit:GetPrimaryAttribute()

	if main_stat == 0 then fdamage = unit:GetStrength()*damage end
	if main_stat == 1 then fdamage = unit:GetAgility()*damage end
	if main_stat == 2 then fdamage = unit:GetIntellect()*damage end

	ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, attacker) --[[Returns:int
	Creates a new particle effect
	]]

	DealDamage(attacker, caster, fdamage, DAMAGE_TYPE_MAGICAL)
end