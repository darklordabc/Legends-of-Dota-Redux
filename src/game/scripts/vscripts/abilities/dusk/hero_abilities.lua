require('lib/physics')
function OnePunchAbilityPhaseStart(keys)
	local caster = keys.caster
	local target = keys.target

	if caster:IsDisarmed() then caster:Interrupt() return end
	if target:IsAttackImmune() then caster:Interrupt() return end
end

function OnePunch(keys)
	local caster = keys.caster
	local target = keys.target

	local target_location = target:GetAbsOrigin()

	local particle_kill = "particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf"

	local mod = "modifier_one_punch_crit"
	local p = "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf"

	local k = "modifier_one_punch_knockback"

	local knockback = keys.knockback

	

	local r = RandomInt(0, 100) --[[Returns:int
	Get a random ''int'' within a range
	]]

	print(r)

	if caster:HasScepter() then
		k = "modifier_one_punch_knockback_s"
		knockback = 1750
	end

	if r < keys.ability:GetSpecialValueFor("mega_crit_chance") then
		if caster:HasScepter() then
			mod = "modifier_one_punch_mega_crit_scepter"
		else
			mod = "modifier_one_punch_mega_crit"
		end

		target:EmitSound("Hero_Tusk.Snowball.Stun")
		target:EmitSound("Hero_Tusk.IceShards")
		target:EmitSound("Hero_LegionCommander.Duel.Victory")
		p = "particles/units/heroes/hero_hero/hero_one_punch_mega_crit.vpcf"
	end

	local particle = ParticleManager:CreateParticle(p, PATTACH_ABSORIGIN, target) --[[Returns:int
	Creates a new particle effect
	]]
	ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin()+Vector(0,0,75)) --[[Returns:void
	Set the control point data for a control on a particle effect
	]]

	target:EmitSound("Hero_Tusk.WalrusPunch.Target")
	target:EmitSound("Hero_Tusk.WalrusPunch.Damage")

	if target:GetTeam() ~= caster:GetTeam() then

		keys.ability:ApplyDataDrivenModifier(caster, caster, mod, {}) --[[Returns:void
		No Description Set
		]]

		caster:PerformAttack(target, true, true, true, false, true, false, true) --[[Returns:void
		Performs an attack on a target. Params: Target, bUseCastAttackOrb, bProcessProcs, bSkipCooldown, bIgnoreInvis
		]]

		Timers:CreateTimer(0.03,function () caster:RemoveModifierByName(mod) end)

	end

	ScreenShake(target:GetCenter(), 500, 5, 1, 1500, 0, true)

	keys.ability:ApplyDataDrivenModifier(caster, target, k, {Duration = 2}) --[[Returns:void
	No Description Set
	]]

	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_one_punch_freedom_strike_augment", {}) --[[Returns:void
	No Description Set
	]]

	caster.freedom_strike_bonus = knockback

	local fs_ab = caster:FindAbilityByName("hero_freedom_strike") --[[Returns:handle
	Retrieve an ability by name from the unit.
	]]
	if fs_ab then
		fs_ab:EndCooldown()
	end

	if not target:IsAlive() then
		local culling_kill_particle = ParticleManager:CreateParticle(particle_kill, PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:ReleaseParticleIndex(culling_kill_particle)
		target:AddNoDraw()
		target:EmitSound("Hero_PhantomAssassin.Spatter")
	end
end

function HeroicSoul(keys)
	local caster = keys.caster

	caster:Purge(false,true,false,true,false)

	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_heroic_soul_buff", {}) --[[Returns:void
	No Description Set
	]]
end

function FreedomStrike(keys)
	local caster = keys.caster
	local distance = keys.distance

	local radius = keys.radius

	local facing = caster:GetForwardVector()

	local damage = keys.damage

	if caster.freedom_strike_bonus ~= nil and caster:HasModifier("modifier_one_punch_freedom_strike_augment") then
		distance = caster.freedom_strike_bonus+50
	end

	Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:PreventDI(true)
	-- To allow going through walls / cliffs add the following:
	caster:FollowNavMesh(false)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)

	caster:SetPhysicsVelocity(facing * distance * (1/0.4))
	caster:AddPhysicsVelocity(Vector(0,0,distance*1.4))

	caster:SetPhysicsAcceleration(Vector(0,0,-(distance*10)))

	Timers:CreateTimer(0.4,function()
		caster:SetPhysicsVelocity(Vector(0,0,0))
		--    FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)
		caster:PreventDI(false)
	end
	)
	Timers:CreateTimer(0.43,function()
		local enemy = FindUnitsInRadius( caster:GetTeamNumber(),
                              caster:GetCenter(),
                              nil,
                                radius,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_CLOSEST,
                                false)

		local p = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) --[[Returns:int
		Creates a new particle effect
		]]
		ParticleManager:SetParticleControl(p, 1, Vector(radius,0,0)) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]
		caster:EmitSound("Hero_Brewmaster.ThunderClap")
		for k,v in pairs(enemy) do
			DealDamage(v,caster,damage,DAMAGE_TYPE_MAGICAL)
			keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_freedom_strike_slow", {}) --[[Returns:void
			No Description Set
			]]
		end
		FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)
	end
	)
end

function JusticeKickCheckOpponent(keys)
	local caster = keys.caster
	local target = keys.target

	if target:IsRealHero() and not target:IsAlive() then
		EmitGlobalSound("Hero.JusticeKick.Humiliation")

		local player = caster:GetPlayerOwner()

		if player.JusticeKickKills then

			player.JusticeKickKills = player.JusticeKickKills+1

		else

			player.JusticeKickKills = 1

		end

		local r = RandomInt(1, 5) --[[Returns:int
		Get a random ''int'' within a range
		]]

		if player.JusticeKickKills > 4 then
			r = RandomInt(6,9)
		end

		if player.JusticeKickKills == 30 then
			r = 10
			keys.ability:SetHidden(true)
			local ab = caster:FindAbilityByName("hero_hyper_kick")
			ab:SetLevel(1)
			ab:SetHidden(false)

		end

		local response_table = {
			"What a way to go...",
			"Justice Kick!",
			"The foot of Justice!",
			"Booted.",
			"Boot to the head!",
			"Are you really letting this happen?",
			"Please stop.",
			"?!?!?!",
			"There is no god.",
			"A latent power is unleashed!"
		}

		local response = response_table[r]
		local messageinfo = {
			message = response,
			duration = 4
			}
			FireGameEvent("show_center_message",messageinfo) 
		GameRules:SendCustomMessage("<font color='#dd3f4e'>Justice Kill</font> x"..player.JusticeKickKills.."!", caster:GetTeam(), 0)
	end
end

function HyperKick(keys)
	local caster = keys.caster
	local ab = caster:FindAbilityByName("hero_justice_kick")
	ab:SetHidden(false)
	ab = caster:FindAbilityByName("hero_hyper_kick")
	ab:SetHidden(true)
	local messageinfo = {
			message = "THE ONE TRUE KICK!",
			duration = 2
			}
			FireGameEvent("show_center_message",messageinfo)

	GameRules:SendCustomMessage("<font color='#dd3f4e'>Ultimate Saviour of the Downtrodden Hyper Justice Kick</font> x1!", caster:GetTeam(), 0)
end