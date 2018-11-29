--[[	Author: Firetoad
		Date: 06.09.2015	]]

require('lib/timers')
require('lib/util_imba')

function AIControl( keys )
    local caster = keys.caster
    local ability = keys.ability

    -- Mostly for duel
    if caster:PassivesDisabled() or caster:HasModifier("modifier_duel_out_of_game") then
    	return nil
    end

    -- If the ability is on cooldown, do nothing
    if not ability:IsCooldownReady() then
        return nil
    end
	
	if caster:PassivesDisabled() then return end
	
    -- Parameters
    local tower_loc = caster:GetAbsOrigin()
    
    local longRange = 4000
    local nearby = 800
    local veryClose = 300

    -- Find nearby enemies
    local EnemyInRange = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, nearby, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
    if not EnemyInRange then return end
    
    local AllyInRange = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, nearby+100, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
    local veryCloseAllies = 0
    for _,ally in pairs(AllyInRange) do
        if (tower_loc - ally:GetAbsOrigin()):Length2D() < veryClose then
            veryCloseAllies = veryCloseAllies + 1
        end
    end
    -- Check if the ability should be cast
        -- IF TOWER IS VULNERABLE AND DOES NOT HAVE BACK DOOR PROTECTION AND AT LEAST 1 ENEMY NEARBY
    for _,enemy in pairs(EnemyInRange) do
    	if IsValidEntity(enemy) then
	        if util:isPlayerBot(enemy:GetPlayerID()) then
	            local distance = (tower_loc - enemy:GetAbsOrigin()):Length2D()
				-- IF BOT IS ABOUT TO DIE, SAVE IT AND SEND IT BACK TO BASE WITH FULL HP MP AND MAX MOVE SPEED FOR 30 SECONDS
	            if enemy:GetHealth() < 300 and enemy:HasModifier("modifier_pugna_decrepify") == false and #AllyInRange == 0 then
	                enemy:AddNewModifier(caster, ability, "modifier_pugna_decrepify", {duration = 5})
	                enemy:AddNewModifier(caster, ability, "modifier_chen_test_of_faith_teleport", {duration = 5})
					ability:StartCooldown(ability:GetCooldown(-1))
	                Timers:CreateTimer(1, function()
	                    if enemy then
	                        enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = 4})
	                        
	                    end
	                end)
					Timers:CreateTimer(5, function()
	                    if enemy:IsAlive() then
							enemy:SetHealth(enemy:GetMaxHealth())
							enemy:SetMana(enemy:GetMaxMana())
							local tpScroll = enemy:FindItemByName("item_tpscroll")
							if tpScroll then
								tpScroll:StartCooldown(30)
							end
	                        enemy:AddNewModifier(caster, ability, "modifier_dark_seer_surge", {duration = 30})
	                        enemy:AddExperience(100,0,false,false)
	                        enemy:ModifyGold(100, false, 0) 
	                    end
	                end)
	            else 
					local invulnerable = caster:HasModifier("modifier_tower_anti_rat") or caster:HasModifier("modifier_invulnerable") or caster:HasModifier("modifier_backdoor_protection_active")
	                if distance < veryClose then
	                    if invulnerable then
	                    	if caster:HasModifier("modifier_tower_anti_rat") then
	                       	 	enemy:AddNewModifier(enemy, nil, "modifier_chen_test_of_faith_teleport", {duration = 4}) 
	                    	end
	                        abilityRoar = caster:FindAbilityByName("lone_druid_savage_roar_tower")   
	                        caster:CastAbilityImmediately(abilityRoar, caster:GetPlayerOwnerID())
	                        enemy:AddNewModifier(caster, ability, "modifier_phased", {duration = 4})
	                        enemy:AddNewModifier(caster, ability, "modifier_dark_seer_surge", {duration = 4})
	                        ability:StartCooldown(ability:GetCooldown(-1))
	                    elseif enemy:GetHealth() > enemy:GetMaxHealth() * 0.90 and veryCloseAllies == 0 then
	                        enemy:AddNewModifier(caster, ability, "modifier_axe_berserkers_call", {duration = 1.5})
	                        ability:StartCooldown(ability:GetCooldown(-1))
	                    end
	                elseif not enemy:HasModifier("modifier_lone_druid_savage_roar") and not enemy:HasModifier("modifier_pugna_decrepify") and #AllyInRange == 0 and not invulnerable then
	                    enemy:AddNewModifier(caster, ability, "modifier_axe_berserkers_call", {duration = 1.5})
	                    ability:StartCooldown(ability:GetCooldown(-1))
	                end
	            end
	        end
    	end
    end                                    
end
		
function Laser( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local projectile_laser = keys.projectile_laser
	local sound_impact = keys.sound_impact

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- Parameters
	local blind_aoe = ability:GetLevelSpecialValueFor("blind_aoe", ability_level)
	local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, blind_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, blind_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #creeps >= min_creeps or #heroes >= 1 then

		-- Emit sound
		caster:EmitSound(sound_impact)

		-- Create projectile
		local laser_projectile = {
			Target = "",
			Source = caster,
			Ability = ability,
			EffectName = projectile_laser,
			bDodgeable = true,
			bProvidesVision = false,
			iMoveSpeed = projectile_speed,
		--	iVisionRadius = vision_radius,
		--	iVisionTeamNumber = caster:GetTeamNumber(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}

		-- Launch projectiles
		for _,enemy in pairs(creeps) do
			laser_projectile.Target = enemy
			ProjectileManager:CreateTrackingProjectile(laser_projectile)
		end
		for _,enemy in pairs(heroes) do
			laser_projectile.Target = enemy
			ProjectileManager:CreateTrackingProjectile(laser_projectile)
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function LaserHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_blind = keys.modifier_blind
	local particle_blind = keys.particle_blind
	local sound_impact = keys.sound_impact

	-- Play sound
	target:EmitSound(sound_impact)

	-- Play hit particle
	local laser_pfx = ParticleManager:CreateParticle(particle_blind, PATTACH_OVERHEAD_FOLLOW, target)
	ParticleManager:SetParticleControl(laser_pfx, 1, target:GetAbsOrigin())

	-- Apply blind modifier
	ability:ApplyDataDrivenModifier(caster, target, modifier_blind, {})
end

function Multishot( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster:PassivesDisabled() then return end
	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	-- Parameters
	local tower_range = caster:Script_GetAttackRange() + 128
	
	-- Find nearby enemies
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, tower_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)

	-- Attack each nearby enemy once
	for _,enemy in pairs(enemies) do
		if enemy ~= target then
			caster:PerformAttack(enemy, true, true, true, true, true, false, true)
		end
	end
end

function HexAura( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_slow = keys.modifier_slow

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- Parameters
	local hex_aoe = ability:GetLevelSpecialValueFor("hex_aoe", ability_level)
	local hex_duration = ability:GetLevelSpecialValueFor("hex_duration", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, hex_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, hex_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #creeps >= min_creeps or #heroes >= 1 then

		-- Choose a random hero to be the modifier owner (having a non-hero hex modifier owner crashes the game)
		local hero_owner = HeroList:GetHero(0)

		-- Hex enemies
		for _,enemy in pairs(creeps) do
			if enemy:IsIllusion() then
				enemy:ForceKill(true)
			else
				enemy:AddNewModifier(hero_owner, ability, "modifier_sheepstick_debuff", {duration = hex_duration})
				ability:ApplyDataDrivenModifier(caster, enemy, modifier_slow, {})
			end
		end
		for _,enemy in pairs(heroes) do
			if enemy:IsIllusion() then
				enemy:ForceKill(true)
			else
				enemy:AddNewModifier(hero_owner, ability, "modifier_sheepstick_debuff", {duration = hex_duration})
				ability:ApplyDataDrivenModifier(caster, enemy, modifier_slow, {})
			end
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function ManaBurn( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_burn = keys.particle_burn
	local sound_burn = keys.sound_burn
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- If the target has no mana, do nothing
	if target:GetMaxMana() <= 0 then
		return nil
	end

	-- Parameters
	local mana_burn_pct = ability:GetLevelSpecialValueFor("mana_burn", ability_level)

	-- Calculate mana to burn
	local mana_to_burn = caster:GetAttackDamage() * mana_burn_pct / 100

	-- Burn mana
	target:ReduceMana(mana_to_burn)

	-- Play sound
	target:EmitSound(sound_burn)

	-- Play mana burn particle
	local mana_burn_pfx = ParticleManager:CreateParticle(particle_burn, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(mana_burn_pfx, 0, target:GetAbsOrigin())
end

function ManaFlare( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_burn = keys.particle_burn
	local sound_burn = keys.sound_burn

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end

	-- Parameters
	local burn_aoe = ability:GetLevelSpecialValueFor("burn_aoe", ability_level)
	local burn_pct = ability:GetLevelSpecialValueFor("burn_pct", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, burn_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #heroes >= 1 then

		-- Play sound
		caster:EmitSound(sound_burn)

		-- Iterate through enemies
		for _,enemy in pairs(heroes) do
			
			-- Burn mana
			local mana_to_burn = enemy:GetMaxMana() * burn_pct / 100
			enemy:ReduceMana(mana_to_burn)

			-- Play mana burn particle
			local mana_burn_pfx = ParticleManager:CreateParticle(particle_burn, PATTACH_ABSORIGIN, enemy)
			ParticleManager:SetParticleControl(mana_burn_pfx, 0, enemy:GetAbsOrigin())
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function Permabash( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_bash = keys.sound_bash
	local modifier_bash = keys.modifier_bash

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end
	
	if caster:PassivesDisabled() then return end	

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end

	-- Parameters
	local bash_damage = ability:GetLevelSpecialValueFor("bash_damage", ability_level)
	local bash_duration = ability:GetLevelSpecialValueFor("bash_duration", ability_level)

	-- Play sound
	target:EmitSound(sound_bash)

	-- Apply bash modifiers
	ability:ApplyDataDrivenModifier(caster, target, modifier_bash, {})
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = bash_duration})

	-- Deal damage
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = bash_damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- Put the ability on cooldown
	ability:StartCooldown(ability:GetCooldown(ability_level))
end

function Chronotower( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_stun = keys.sound_stun
	local modifier_stun = keys.modifier_stun

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- Parameters
	local stun_radius = ability:GetLevelSpecialValueFor("stun_radius", ability_level)
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, stun_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, stun_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #creeps >= min_creeps or #heroes >= 1 then

		-- Play sound
		caster:EmitSound(sound_stun)

		-- Stun enemies
		for _,enemy in pairs(creeps) do
			ability:ApplyDataDrivenModifier(caster, enemy, modifier_stun, {})
			enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		end
		for _,enemy in pairs(heroes) do
			ability:ApplyDataDrivenModifier(caster, enemy, modifier_stun, {})
			enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function GrievousWounds( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_debuff = keys.modifier_debuff
	local particle_hit = keys.particle_hit
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end


	-- Parameters
	local damage_increase = ability:GetLevelSpecialValueFor("damage_increase", ability_level)

	-- Play hit particle
	local hit_pfx = ParticleManager:CreateParticle(particle_hit, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(hit_pfx, 0, target:GetAbsOrigin())

	-- Calculate bonus damage
	local base_damage = caster:GetAttackDamage()
	local current_stacks = target:GetModifierStackCount(modifier_debuff, caster)
	local total_damage = base_damage * ( 1 + current_stacks * damage_increase / 100 )

	-- Apply damage
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = total_damage, damage_type = DAMAGE_TYPE_PHYSICAL})

	-- Apply bonus damage modifier
	AddStacks(ability, caster, target, modifier_debuff, 1, true)
end

function EssenceDrain( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_str = keys.modifier_str
	local modifier_agi = keys.modifier_agi
	local modifier_int = keys.modifier_int
	local modifier_stacks = keys.modifier_stacks
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end


	-- Parameters
	local drain_per_hit = ability:GetLevelSpecialValueFor("drain_per_hit", ability_level)
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", ability_level)
	local available_stacks = math.max(max_stacks - caster:GetModifierStackCount(modifier_stacks, caster), 0)

	-- If the target is not a hero, apply one time and exit
	if not target:IsHero() then
		AddStacks(ability, caster, caster, modifier_stacks, math.min(1, available_stacks), true)
		return nil
	end

	-- Grant the tower its bonuses
	AddStacks(ability, caster, caster, modifier_stacks, math.min(drain_per_hit, available_stacks), true)

	-- Fetch target's current attributes
	local target_str = target:GetStrength()
	local target_agi = target:GetAgility()
	local target_int = target:GetIntellect()

	-- Reduce Strength to a minimum of 1 (prevents making the target a "zombie" for the rest of the match)
	if target_str > drain_per_hit then
		AddStacks(ability, caster, target, modifier_str, drain_per_hit, true)
	else
		AddStacks(ability, caster, target, modifier_str, target_str - 1, true)
	end

	-- Reduce Intelligence to a minimum of 1 (prevents making the target manaless for the rest of the match)
	if target_int > drain_per_hit then
		AddStacks(ability, caster, target, modifier_int, drain_per_hit, true)
	else
		AddStacks(ability, caster, target, modifier_int, target_int - 1, true)
	end

	-- Reduce Agility (no minimum value)
	AddStacks(ability, caster, target, modifier_agi, drain_per_hit, true)

	-- Update the target's stats
	target:CalculateStatBonus()
end

function EssenceDrainStackUp( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier_dummy = keys.modifier_dummy

	-- Increase dummy modifier stack count
	AddStacks(ability, caster, caster, modifier_dummy, 1, true)
end

function EssenceDrainStackDown( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier_dummy = keys.modifier_dummy

	-- If this is the last stack, remove the modifier
	if caster:GetModifierStackCount(modifier_dummy, caster) <= 1 then
		caster:RemoveModifierByName(modifier_dummy)

	-- Else, reduce stack count by one
	else
		AddStacks(ability, caster, caster, modifier_dummy, -1, false)
	end
end

function Fervor( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_fervor = keys.modifier_fervor
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- Parameters
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", ability_level)

	-- Fetch current stack amount
	local current_stacks = caster:GetModifierStackCount(modifier_fervor, caster)

	-- Increase stacks if below the maximum amount
	if current_stacks < max_stacks then
		AddStacks(ability, caster, caster, modifier_fervor, 1, true)
	else
		AddStacks(ability, caster, caster, modifier_fervor, 0, true)
	end
end

function Berserk( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_berserk = keys.modifier_berserk

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- Parameters
	local hp_per_stack = ability:GetLevelSpecialValueFor("hp_per_stack", ability_level)

	-- Calculate proper amount of stacks
	local current_hp_pct = caster:GetHealth() / caster:GetMaxHealth()
	local current_stacks = math.floor( ( 1 - current_hp_pct ) * 100 / hp_per_stack )

	-- Update stack amount
	caster:RemoveModifierByName(modifier_berserk)
	AddStacks(ability, caster, caster, modifier_berserk, current_stacks, true)
end

function Multihit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	
	if not ability:IsCooldownReady() then
		return nil
	end
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end

	cooldown = caster:GetSecondsPerAttack() - 0.1
	
	-- Parameters
	local bonus_attacks = ability:GetLevelSpecialValueFor("bonus_attacks", ability_level)
	local delay = ability:GetLevelSpecialValueFor("delay", ability_level)

	-- Perform bonus attacks
	for i = 1, bonus_attacks do
		Timers:CreateTimer(delay * i, function()
			caster:PerformAttack(target, true, true, true, true, true, false, true)
		end)
	end
	
	if caster:IsHero() then
		ability:StartCooldown(cooldown)
	end
end

function PlagueParticle( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_plague = keys.particle_plague

	-- Parameters
	local radius = ability:GetLevelSpecialValueFor("area_of_effect", ability_level)

	-- Play particle
	plague_pfx = ParticleManager:CreateParticle(particle_plague, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(plague_pfx, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl(plague_pfx, 1, Vector(radius,0,0) )
end

function AegisUpdate( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Parameters
	local bonus_health = ability:GetLevelSpecialValueFor("bonus_health", 0)

	-- Update health
	caster:SetBaseMaxHealth(caster:GetBaseMaxHealth() + bonus_health)
	caster:SetMaxHealth(caster:GetMaxHealth() + bonus_health)
	caster:SetHealth(caster:GetHealth() + bonus_health)
end

function SelfRepair( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_regen = keys.modifier_regen

	-- If the ability is level 3, do nothing
	if ability_level == 2 then
		return nil
	end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end

	-- Parameters
	local regen_delay = ability:GetLevelSpecialValueFor("regen_delay", ability_level)
	
	-- Remove this modifier
	caster:RemoveModifierByName(modifier_regen)

	-- Destroy particle
	ParticleManager:DestroyParticle(caster.self_regen_pfx, false)

	-- Apply this modifier again after [regen_delay]
	Timers:CreateTimer(regen_delay, function()
		ability:ApplyDataDrivenModifier(caster, caster, modifier_regen, {})
	end)
end

function SelfRepairParticle( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_regen = keys.particle_regen

	-- Create particle
	if not caster:IsHero() then
		caster.self_regen_pfx = ParticleManager:CreateParticle(particle_regen, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(caster.self_regen_pfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(caster.self_regen_pfx, 1, caster:GetAbsOrigin())
	end
end

function Spacecow( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_creep = keys.sound_creep
	local sound_hero = keys.sound_hero

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end

	-- Parameters
	local knockback_damage = ability:GetLevelSpecialValueFor("knockback_damage", ability_level)
	local knockback_distance = ability:GetLevelSpecialValueFor("knockback_distance", ability_level)
	local knockback_duration = ability:GetLevelSpecialValueFor("knockback_duration", ability_level)
	local knockback_origin = caster:GetAbsOrigin()

	-- Play appropriate sound
	if target:IsHero() then
		target:EmitSound(sound_hero)
	else
		target:EmitSound(sound_creep)
	end

	-- Knockback target
	local knockback_param =
	{	should_stun = 1,
		knockback_duration = knockback_duration,
		duration = knockback_duration,
		knockback_distance = knockback_distance,
		knockback_height = knockback_distance / 4,
		center_x = knockback_origin.x,
		center_y = knockback_origin.y,
		center_z = knockback_origin.z
	}
	target:RemoveModifierByName("modifier_knockback")
	target:AddNewModifier(caster, nil, "modifier_knockback", knockback_param)

	-- Deal damage
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = knockback_damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- Put the ability on cooldown
	ability:StartCooldown(ability:GetCooldown(ability_level))
end

function Reality( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_reality = keys.sound_reality

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- Parameters
	local reality_aoe = ability:GetLevelSpecialValueFor("reality_aoe", ability_level)
	local tower_loc = caster:GetAbsOrigin()
	local stun_radius = ability:GetLevelSpecialValueFor("stun_radius", ability_level)

	-- Find nearby enemies
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, stun_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Kill any existing illusions
	local ability_used = false
	for _,enemy in pairs(heroes) do
		if enemy:IsIllusion() then
			enemy:ForceKill(true)
			ability_used = true
		end
	end

	-- If the ability was used, play the sound and put it on cooldown
	if ability_used then

		-- Play sound
		caster:EmitSound(sound_reality)

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function Force( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_force = keys.sound_force

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end

	if caster:PassivesDisabled() then return end	

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
		
	-- Parameters
	local force_aoe = ability:GetLevelSpecialValueFor("force_aoe", ability_level)
	local force_distance = ability:GetLevelSpecialValueFor("force_distance", ability_level)
	local force_duration = ability:GetLevelSpecialValueFor("force_duration", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, force_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, force_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #creeps >= min_creeps or #heroes >= 1 then

		-- Play sound
		caster:EmitSound(sound_force)

		-- Set up knockback parameters
		local knockback_param =
		{	should_stun = 1,
			knockback_duration = force_duration,
			duration = force_duration,
			knockback_distance = force_distance,
			knockback_height = 0,
			center_x = tower_loc.x,
			center_y = tower_loc.y,
			center_z = tower_loc.z
		}

		-- Knockback enemies
		for _,enemy in pairs(creeps) do
			enemy:RemoveModifierByName("modifier_knockback")
			enemy:AddNewModifier(caster, nil, "modifier_knockback", knockback_param)
		end
		for _,enemy in pairs(heroes) do
			enemy:RemoveModifierByName("modifier_knockback")
			enemy:AddNewModifier(caster, nil, "modifier_knockback", knockback_param)
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function Nature( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_root = keys.sound_root
	local modifier_root = keys.modifier_root

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- Parameters
	local root_radius = ability:GetLevelSpecialValueFor("root_radius", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, root_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, root_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #creeps >= min_creeps or #heroes >= 1 then

		-- Play sound
		caster:EmitSound(sound_root)

		-- Root enemies
		for _,enemy in pairs(creeps) do
			ability:ApplyDataDrivenModifier(caster, enemy, modifier_root, {})
		end
		for _,enemy in pairs(heroes) do
			ability:ApplyDataDrivenModifier(caster, enemy, modifier_root, {})
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function Mindblast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_silence = keys.sound_silence
	local modifier_silence = keys.modifier_silence

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- Parameters
	local silence_radius = ability:GetLevelSpecialValueFor("silence_radius", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, silence_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #heroes >= 1 then

		-- Play sound
		caster:EmitSound(sound_silence)

		-- Silence enemies
		for _,enemy in pairs(heroes) do
			ability:ApplyDataDrivenModifier(caster, enemy, modifier_silence, {})
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function PlasmaField( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()
	--local sound_silence = keys.sound_silence
	if not ability:IsCooldownReady() then
		return nil
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- Parameters
	local plasma_radius = ability:GetLevelSpecialValueFor("plasma_radius", ability_level-1)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, plasma_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, plasma_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #heroes >= 1 or #creeps > 1 then
		local plasma = caster:FindAbilityByName("plasma_internal_tower")
		if not plasma then
			caster:AddAbility("plasma_internal_tower")
			plasma = caster:FindAbilityByName("plasma_internal_tower")
			plasma:SetHidden(true)
			plasma:SetLevel(ability_level)
		end
		plasma:SetLevel(ability_level)
		print(plasma:GetLevel())
		--Below doesnt work, I dont know how to make it play the sound
		--caster:EmitSound("Ability.PlasmaField")
		plasma:OnSpellStart()

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function DeathPulse( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()
	--local sound_silence = keys.sound_silence
	if not ability:IsCooldownReady() then
		return nil
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	
	-- Parameters
	local plasma_radius = ability:GetLevelSpecialValueFor("area_of_effect", ability_level-1)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #heroes >= 1 or #creeps >= 1 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_imba_tower_death_pulse_cast", {})
		ability:UseResources(true, false, true)

	--[[	local pulse = caster:FindAbilityByName("necrolyte_death_pulse_tower")
		if not pulse then
			caster:AddAbility("necrolyte_death_pulse_tower")
			pulse = caster:FindAbilityByName("necrolyte_death_pulse_tower")
			pulse:SetHidden(true)
			pulse:SetLevel(ability_level)
		end
		pulse:SetLevel(ability_level)
		print(pulse:GetLevel())
		--Below doesnt work, I dont know how to make it play the sound
		--caster:EmitSound("Ability.PlasmaField")
		pulse:OnSpellStart()

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	]]
	end
end

function DeathPulseHit( keys )
	if keys.target and keys.ability and keys.caster then
		local damageHeal = keys.ability:GetSpecialValueFor("healdamage")
		if keys.target:GetTeam() ~= keys.caster:GetTeam() then
			ApplyDamage({victim = keys.target, attacker = keys.caster, ability = keys.ability, damage = damageHeal, damage_type = DAMAGE_TYPE_MAGICAL})
		else
			keys.target:Heal(damageHeal, keys.caster)
		end
	end
end

function Forest( keys )

	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_tree = keys.sound_tree
	local abilityName = ability:GetName()

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end

	if not caster:IsRealHero() and not caster:IsBuilding() and abilityName ~= "imba_tower_forest_generator" then return nil end
	
	if caster:PassivesDisabled() then return end



	-- Parameters
	local tree_radius = ability:GetLevelSpecialValueFor("tree_radius", ability_level)
	local tree_duration = ability:GetLevelSpecialValueFor("tree_duration", ability_level)

	-- Tree generator for black forest mutator
	if ability:GetAbilityName() == "imba_tower_forest_generator" then
		
		-- FOREST CALIBRATION SETTINGS
		local treeBufferDistance = 205 --How far trees should be apart
		local treeBufferDistanceRiver = 300
		local nearbyUnitsRadius = 300
		local nearbyTowersRadius = 600
		local nearbyNeutralCampRadius = 500
		local nearbyAncientRadius = 1000
		local nearbyShrineRadius = 400
		local nearbyShrineRadius = 400
		--local totalTreeLimit = 2000
		-- END SETTINGS

        local tree_loc = Vector(RandomInt(-7136, 7136), RandomInt(-7136, 7136), 384)
        tree_loc.z = GetGroundHeight(tree_loc, caster)     

        --local allTrees = Entities:FindAllByClassnameWithin("dota_temp_tree",tree_loc, 99999)
		--print(#allTrees)
        
        if tree_loc.z ~= 384 and tree_loc.z ~= 128 and tree_loc.z ~= 256 then 
			return nil
		end

		--print(tree_loc.z)
		if tree_loc.z == 128 then treeBufferDistance = treeBufferDistanceRiver end -- If in river area, spreadout trees more

		-- Condition checks
		local nearbyUnits = FindUnitsInRadius(caster:GetTeamNumber(), tree_loc, nil, nearbyUnitsRadius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
		if #nearbyUnits > 0 then return nil end

		local nearbyTowers = Entities:FindAllByClassnameWithin("npc_dota_tower",tree_loc, nearbyTowersRadius)
        if #nearbyTowers > 0 then return nil end

        local nearbyCamp = Entities:FindByNameNearest("neutralcamp_*", tree_loc, nearbyNeutralCampRadius)
        if nearbyCamp then return nil end

        local nearbyAncients = Entities:FindByNameNearest("*_fort*", tree_loc, nearbyAncientRadius)
        if nearbyAncients then return nil end

        local nearbyShrines = Entities:FindAllByClassnameWithin("npc_dota_healer",tree_loc, nearbyShrineRadius)
        if #nearbyShrines > 0 then return nil end

        local nearbytrees = GridNav:GetAllTreesAroundPoint( tree_loc, treeBufferDistance, false )
        if #nearbytrees > 0 then return nil end

        if GridNav:IsTraversable(tree_loc) == false or GridNav:IsBlocked(tree_loc) then return nil end
 
		createTempTreePretty(tree_loc, tree_duration)

	else
		
		local nearbyUnits = Entities:FindAllInSphere(caster:GetAbsOrigin(), 50)
	
		-- Play sound
		caster:EmitSound(sound_tree)

		-- Create a tree on a random location
		local tree_loc = caster:GetAbsOrigin() + RandomVector(100):Normalized() * RandomInt(100, tree_radius)
		createTempTreePretty(tree_loc, tree_duration)

		local unitsInRadius = FindUnitsInRadius(caster:GetTeamNumber(), tree_loc, nil, 256, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for _, unit in pairs(unitsInRadius) do
			FindClearSpaceForUnit(unit,unit:GetAbsOrigin(),true)
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))	
	end

end

function createTempTreePretty( tree_loc, duration )
	CreateTempTree(tree_loc, duration)
			
	local nearbyUnits = Entities:FindAllInSphere(tree_loc, 1)
	for _, unit in pairs(nearbyUnits) do
		if unit:GetClassname() == "dota_temp_tree" then
			-- Figure out what side of the map is the tree on
			local treeSide = nil
			local goodancients = Entities:FindAllByName("dota_goodguys_fort")
			local distancetoGoodAncient = CalcDistanceBetweenEntityOBB( goodancients[1], unit )

			local badancients = Entities:FindAllByName("dota_badguys_fort")
			distancetoBadAncient = CalcDistanceBetweenEntityOBB( badancients[1], unit )

			-- If its close enough to an ancient its safe to assume its on the dire/radiant side
			if distancetoGoodAncient < 7300 then
				treeSide = "radiant"
			elseif distancetoBadAncient < 7300 then
				treeSide = "dire"
			end

			-- If we couldnt determine side by measuing distance to ancients resort to measuing nearest neutral camps
			if treeSide == nil then
				local closestneutralcamp = Entities:FindByNameNearest("neutralcamp_*", unit:GetAbsOrigin(), 6000)
				local nameOfCamp = closestneutralcamp:GetName()
				if nameOfCamp:match("_good_") then treeSide = "radiant" 
				elseif nameOfCamp:match("_evil_") then treeSide = "dire" 
				end
			end
			
			local chance 
			if treeSide == "dire" then
				chance = RandomInt(1, 6)
			end
			if treeSide == "radiant" then
				chance = RandomInt(7, 13)
			end
			-- If the treespot is in the water river area, spawn only leafless trees
			if tree_loc.z == 128 then 
				chance = RandomInt(1, 4)
			end

			Trees =
			{
			   [1] = {"models/props_tree/dire_tree001.vmdl", 1},
			   [2] = {"models/props_tree/dire_tree002.vmdl", 1},
			   [3] = {"models/props_tree/dire_tree004b_sfm.vmdl", 1},
			   [4] = {"models/props_tree/dire_tree007_sfm.vmdl", .5},
			   [5] = {"models/props_tree/dire_tree003.vmdl", 1.2},
			   [6] = {"models/props_tree/dire_tree005.vmdl", 1},
			   [7] = {"models/props_tree/tree_oak_01_sfm.vmdl", 0.5},
			   [8] = {"models/props_tree/tree_oak_00.vmdl", 1},
			   [9] = {"models/props_tree/tree_oak_01b_sfm.vmdl", 0.8},
			   [10] = {"models/props_tree/tree_oak_02_sfm.vmdl", 0.35},
			   [11] = {"models/props_tree/tree_pine_01_sfm.vmdl", 0.5},
			   [12] = {"models/props_tree/tree_pine_02_sfm.vmdl", 0.4},
			   [13] = {"models/props_tree/tree_pine_03b_sfm.vmdl", 1},
			}

			unit:SetModel(Trees[chance][1])
			unit:SetModelScale(Trees[chance][2])

			if RollPercentage(25) then
				local size = RandomFloat(.8, 1.6)
				--print(size)
				unit:SetModelScale(unit:GetModelScale() * size)
			end

			if RollPercentage(1) then
				unit:SetModelScale(unit:GetModelScale() * 3)
			end
			
			if chance == 5 or chance == 6 then
				unit:SetRenderColor(160, 160, 160)
			end

			if chance == 7 or chance == 12 or chance == 11 or chance == 13 then
				local colorChance = RandomInt(1, 4)
				if colorChance == 2 then 
					unit:SetRenderColor(255,192,203)
				elseif colorChance == 3 then					
					unit:SetRenderColor(255,215,0)
				elseif colorChance == 3 then					
					unit:SetRenderColor(162, 163, 3)
				end
				
			end

		end
	end
end

function Glaives( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_creep = keys.sound_creep
	local sound_hero = keys.sound_hero

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return nil
	end
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end

	-- Parameters
	local knockback_damage = ability:GetLevelSpecialValueFor("knockback_damage", ability_level)
	local knockback_distance = ability:GetLevelSpecialValueFor("knockback_distance", ability_level)
	local knockback_duration = ability:GetLevelSpecialValueFor("knockback_duration", ability_level)
	local knockback_origin = caster:GetAbsOrigin()

	-- Play appropriate sound
	if target:IsHero() then
		target:EmitSound(sound_hero)
	else
		target:EmitSound(sound_creep)
	end

	-- Knockback target
	local knockback_param =
	{	should_stun = 1,
		knockback_duration = knockback_duration,
		duration = knockback_duration,
		knockback_distance = knockback_distance,
		knockback_height = knockback_distance / 4,
		center_x = knockback_origin.x,
		center_y = knockback_origin.y,
		center_z = knockback_origin.z
	}
	target:RemoveModifierByName("modifier_knockback")
	target:AddNewModifier(caster, nil, "modifier_knockback", knockback_param)

	-- Deal damage
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = knockback_damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- Put the ability on cooldown
	ability:StartCooldown(ability:GetCooldown(ability_level))
end

function Split( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local scepter = HasScepter(caster)
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	

	-- Parameters
	local split_chance = ability:GetLevelSpecialValueFor("split_chance", ability_level)
	local split_radius = ability:GetLevelSpecialValueFor("split_radius", ability_level)
	local split_amount = ability:GetLevelSpecialValueFor("split_amount", ability_level)
	local target_pos = target:GetAbsOrigin()
	
	-- Roll for splinter chance
	if RandomInt(1, 100) <= split_chance then

		-- Choose the correct particle for this tower
		local attack_projectile = ""
		if caster:GetTeam() == DOTA_TEAM_BADGUYS then
			attack_projectile = "particles/base_attacks/ranged_tower_bad.vpcf"
		elseif caster:GetTeam() == DOTA_TEAM_GOODGUYS then
			attack_projectile = "particles/base_attacks/ranged_tower_good.vpcf"
		end

		-- Find enemies near the target
		local nearby_enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_pos, nil, split_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		if #nearby_enemies > 1 then

			-- Initialize the target table
			local split_targets = {}

			-- Add enemies to the target table until it's full
			for _,enemy in pairs(nearby_enemies) do
				
				-- Do not add the original target
				if enemy ~= target then
					split_targets[#split_targets + 1] = enemy

					-- If the target table is full, stop looking for more
					if #split_targets >= split_amount then
						break
					end
				end
			end

			-- Split projectile base parameters
			local split_projectile = {
				Target = "",
				Source = target,
				Ability = ability,
				EffectName = attack_projectile,
				bDodgeable = true,
				bProvidesVision = false,
				iMoveSpeed = 750,
			--	iVisionRadius = vision_radius,
			--	iVisionTeamNumber = caster:GetTeamNumber(),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
			}

			-- Create the projectiles
			for _,split_target in pairs(split_targets) do
				split_projectile.Target = split_target
				ProjectileManager:CreateTrackingProjectile(split_projectile)
			end
		end
	end
end

function SplitHit( keys )
	local caster = keys.caster
	local target = keys.target

	caster:PerformAttack(target, true, true, true, true, false, false, true)
end

function Cannon( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_explosion = keys.particle_explosion
	
	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end
	

	-- Parameters
	local salvo_aoe = ability:GetLevelSpecialValueFor("salvo_aoe", ability_level)
	local salvo_dmg = ability:GetLevelSpecialValueFor("salvo_dmg", ability_level)
	local target_loc = target:GetAbsOrigin()

	-- Find nearby enemies
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_loc, nil, salvo_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)

	-- Play particle
	target_loc = target_loc + Vector(0, 0, 100)
	local explosion_pfx = ParticleManager:CreateParticle(particle_explosion, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(explosion_pfx, 0, target_loc)
	ParticleManager:SetParticleControl(explosion_pfx, 3, target_loc)

	-- Deal bonus damage to enemies
	for _,enemy in pairs(enemies) do
		ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = salvo_dmg, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end
