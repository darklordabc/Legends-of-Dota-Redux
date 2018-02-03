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

function ouichi(keys)
	local caster = keys.caster or keys.attacker
	local target = keys.target or keys.unit

	if caster:PassivesDisabled() then return end

	local targethp = target:GetHealthPercent()

	local damage = keys.dmg

	local t = keys.threshold

	local agi = caster:GetAgility()

	local fd = agi*damage

	if targethp > t then return end

	if CheckClass(target,"npc_dota_building") then return end

	if caster:IsIllusion() then fd = fd * 0.25 end

	DealDamage(target,caster,fd,DAMAGE_TYPE_PURE)

	local tp,cp = PlayerResource:GetPlayer(target:GetPlayerOwnerID()),PlayerResource:GetPlayer(caster:GetPlayerOwnerID())
	SendOverheadEventMessage(tp or cp, OVERHEAD_ALERT_CRITICAL, target, math.ceil(fd), cp)

	ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeleton_king_weapon_blur_critical.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) --[[Returns:int
	Creates a new particle effect
	]]

	caster:EmitSound("Hero_SkeletonKing.CriticalStrike")

	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()-1))
end

function raigeki(keys)
	local caster = keys.caster
	local target = keys.target_points[1]
	local c_pos = caster:GetAbsOrigin()
	local dr = (target-c_pos):Normalized()
	local range = keys.range
	local delay = keys.delay

	local u = FastDummy(c_pos,caster:GetTeam(),3,0)

	Timers:CreateTimer(delay*0.30,function()
		u:EmitSound("Hero_Magnataur.Empower.Target")
	end)

	Timers:CreateTimer(delay*0.95,function()
		u:EmitSound("Hero_Magnataur.ReversePolarity.Anim")
		u:EmitSound("Hero_Magnataur.ShockWave.Target")
	end)

	Timers:CreateTimer(delay,function()
		local proj = {
			Ability = keys.ability,
        	EffectName = keys.EffectName,
        	vSpawnOrigin = u:GetAbsOrigin(),
        	fDistance = range,
        	fStartRadius = 100,
        	fEndRadius = 100,
        	Source = u,
        	bHasFrontalCone = false,
        	bReplaceExisting = false,
        	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = dr*range*4,
			bProvidesVision = false,
			iVisionRadius = 0,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(proj) --[[Returns:int
		Creates a linear projectile and returns the projectile ID
		]]
	end
	)
end

function genso(event)
	print("Conjure Image")
	local caster = event.caster
	local target = event.target
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(200)
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming", ability:GetLevel() - 1 )

	

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetControllableByPlayer(player, true)

	illusion:EmitSound("Hero_Terrorblade.Reflection")

	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_reflection_cast.vpcf"

	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControl(particle, 3, Vector(1,0,0))
	
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, illusion, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	
	-- Level Up the unit to the casters level
	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end

	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			illusionAbility:SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	-- Add our datadriven Metamorphosis modifier if appropiate
	-- You can add other buffs that want to be passed to illusions this way
	local meta_ability = caster:FindAbilityByName("mifune_genso")
	meta_ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_genso_illusion", nil)
	meta_ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_genso_illusion_speed_boost", nil)

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

	local order = 
		{
			UnitIndex = illusion:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		}

		ExecuteOrderFromTable(order)
	illusion:SetForceAttackTarget(target) --[[Returns:void
	No Description Set
	]]

	illusion.attack_target = target

	if not illusion:IsIllusion() then illusion:MakeIllusion() illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage }) end
end

function genso_illusion(keys)
	local caster = keys.caster
	local target = caster.attack_target

	if not target:IsAlive() or not IsValidEntity(target) then caster:Kill(keys.ability,caster) end
end

function zanmato_init( keys )
	-- Cannot cast multiple stacks
	if keys.caster.sleight_of_fist_active ~= nil and keys.caster.sleight_of_fist_action == true then
		keys.ability:RefundManaCost()
		return nil
	end

	-- Inheritted variables
	local caster = keys.caster
	local main_target = keys.target
	local targetPoint = main_target:GetAbsOrigin()
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local attack_interval = ability:GetLevelSpecialValueFor( "attack_interval", ability:GetLevel() - 1 )
	local modifierTargetName = "modifier_sleight_of_fist_target_datadriven"
	local modifierTargetMainName = "modifier_sleight_of_fist_main_target_datadriven"
	local modifierHeroName = "modifier_sleight_of_fist_target_hero_datadriven"
	local modifierCreepName = "modifier_sleight_if_fist_target_creep_datadriven"
	local casterModifierName = "modifier_sleight_of_fist_caster_datadriven"
	local dummyModifierName = "modifier_sleight_of_fist_dummy_datadriven"
	local particleSlashName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf"
	local particleTrailName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf"
	local particleCastName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf"
	local slashSound = "Hero_EmberSpirit.SleightOfFist.Damage"
	local abilityScepter = caster:FindAbilityByName("mifune_genso")
	
	-- Targeting variables
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS
	local unitOrder = FIND_ANY_ORDER
	
	-- Necessary varaibles
	local counter = 0
	caster.sleight_of_fist_active = true
	local dummy = CreateUnitByName( caster:GetName(), caster:GetAbsOrigin(), false, caster, nil, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
	
	-- Casting particles
	local castFxIndex = ParticleManager:CreateParticle( particleCastName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( castFxIndex, 0, targetPoint )
	ParticleManager:SetParticleControl( castFxIndex, 1, Vector( radius, 0, 0 ) )

	local castFxIndex2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_mifune/mifune_blossoms.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( castFxIndex2, 0, caster:GetAbsOrigin()+Vector(0,0,300))
	ParticleManager:SetParticleControl( castFxIndex2, 1, caster:GetAbsOrigin())
	
	Timers:CreateTimer( 0.1, function()
			ParticleManager:DestroyParticle( castFxIndex, false )
			ParticleManager:ReleaseParticleIndex( castFxIndex )
		end
	)
	
	-- Start function
	local castFxIndex = ParticleManager:CreateParticle( particleCastName, PATTACH_CUSTOMORIGIN, caster )
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), targetPoint, caster, radius, targetTeam,
		targetType, targetFlag, unitOrder, false
	)
	
	for _, target in pairs( units ) do
		counter = counter + 1
		Timers:CreateTimer( counter * attack_interval, function()
				-- Only jump to it if it's alive
				if target:IsAlive() then
					-- Create trail particles and apply the target modifier
					if caster:HasScepter() then
						caster:SetCursorCastTarget(main_target)
						abilityScepter:OnSpellStart()
					end


					ability:ApplyDataDrivenModifier( caster, target, modifierTargetName, {} )
					local trailFxIndex = ParticleManager:CreateParticle( particleTrailName, PATTACH_CUSTOMORIGIN, target )
					ParticleManager:SetParticleControl( trailFxIndex, 0, target:GetAbsOrigin() )
					ParticleManager:SetParticleControl( trailFxIndex, 1, caster:GetAbsOrigin() )
					
					Timers:CreateTimer( 0.1, function()
							ParticleManager:DestroyParticle( trailFxIndex, false )
							ParticleManager:ReleaseParticleIndex( trailFxIndex )
							return nil
						end
					)
					
					-- Move hero there
					FindClearSpaceForUnit( caster, target:GetAbsOrigin(), false )
					
					if target:IsHero() then
						ability:ApplyDataDrivenModifier( caster, caster, modifierHeroName, {} )
					else
						ability:ApplyDataDrivenModifier( caster, caster, modifierCreepName, {} )
					end
					
					caster:PerformAttack( target, true, true, true, false, false )
					
					-- Slash particles
					local slashFxIndex = ParticleManager:CreateParticle( particleSlashName, PATTACH_ABSORIGIN_FOLLOW, target )
					StartSoundEvent( slashSound, caster )
					
					Timers:CreateTimer( 0.1, function()
							ParticleManager:DestroyParticle( slashFxIndex, false )
							ParticleManager:ReleaseParticleIndex( slashFxIndex )
							StopSoundEvent( slashSound, caster )
							return nil
						end
					)
					
					-- Clean up modifier
					caster:RemoveModifierByName( modifierHeroName )
					caster:RemoveModifierByName( modifierCreepName )
				end
				return nil
			end
		)
	end

	local stuntime = counter*attack_interval+0.6

	if stuntime < 1 then stuntime = 1 end

	ability:ApplyDataDrivenModifier( caster, main_target, modifierTargetMainName, {Duration = stuntime} )
	
	-- Return caster to origin position
	Timers:CreateTimer( ( counter + 1 ) * attack_interval, function()
			FindClearSpaceForUnit( caster, dummy:GetAbsOrigin(), false )
			dummy:RemoveSelf()
			for _,target in pairs(units) do
				target:RemoveModifierByName(modifierTargetName)
				if target ~= main_target then
				local info = 
				  {
				  Target = main_target,
				  Source = target,
				  Ability = keys.ability,  
				  EffectName = "particles/units/heroes/hero_mifune/mifune_orb.vpcf",
				  vSpawnOrigin = target:GetAbsOrigin(),
				  fDistance = distance,
				  fStartRadius = 20,
				  fEndRadius = 20,
				  bHasFrontalCone = false,
				  bReplaceExisting = false,
				  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				  iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				  fExpireTime = GameRules:GetGameTime() + 10.0,
				  bDeleteOnHit = true,
				  iMoveSpeed = 800,
				  bProvidesVision = false,
				  iVisionRadius = 275,
				  iVisionTeamNumber = caster:GetTeamNumber(),
				  iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
				  }
		  
		  		local projectile = ProjectileManager:CreateTrackingProjectile(info)
			end
			end
			caster:RemoveModifierByName( casterModifierName )
			caster.sleight_of_fist_active = false
			ParticleManager:DestroyParticle( castFxIndex2, false )
			return nil
		end
	)
end