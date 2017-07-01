if chi_strike_sp_mod == nil then
	chi_strike_sp_mod = class({})
end

function chi_strike_sp_mod:DeclareFunctions()
	local funcs = {
		--MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED
		--MODIFIER_EVENT_ON_ATTACK
	}

	return funcs
end

function chi_strike_sp_mod:IsHidden()
	return true
end

function chi_strike_sp_mod:OnAttackStart( keys )
	if IsServer() then
		if self:GetParent():PassivesDisabled() then return end
		local hAbility = self:GetAbility()
		if hAbility:GetLevel() < 1 then return end
	if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() then
			if hAbility:IsCooldownReady() then
			end
		end
	end
end

--function chi_strike_sp_mod:GetAlwaysAllowAttack()
--	local hAbility = self:GetAbility()
--	return hAbility:GetSpecialValueFor("range") + 100
--end

function chi_strike_sp_mod:OnAttack (keys)
	if IsServer() then
	local hAbility = self:GetAbility()
		if self:GetParent():PassivesDisabled() then return end

		if hAbility:GetLevel() < 1 then return end
	if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() and hAbility:IsCooldownReady() then
		hAbility.original_target = keys.target
		self:DoProjectile(keys.target)
		hAbility:StartCooldown(hAbility:GetTrueCooldown(hAbility:GetLevel()))
	end
	end
end

function chi_strike_sp_mod:OnAttackLanded(keys)
	if IsServer() then
	local hAbility = self:GetAbility()
		if self:GetParent():PassivesDisabled() then return end

		if hAbility:GetLevel() < 1 then return end
	if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() and hAbility:IsCooldownReady() then
	if hAbility.chi_on == nil or hAbility.chi_on == false then
		hAbility.original_target = keys.target
		self:DoProjectile(keys.target)
		hAbility:StartCooldown(hAbility:GetTrueCooldown(hAbility:GetLevel()))
	end
	end
	end
end

function chi_strike_sp_mod:DoProjectile(hTarget)
	local hCaster = self:GetParent()
	EmitSoundOnLocationWithCaster(hCaster:GetAbsOrigin(), "Hero_Magnataur.ShockWave.Cast", hCaster)
	local hAbility = self:GetAbility()
	local bonus_range = hCaster:GetCastRangeIncrease()
	local range = hAbility:GetCastRange(hCaster:GetAbsOrigin(),hAbility.original_target) + bonus_range
	--local range = hAbility:GetSpecialValueFor("range")
	local speed = hAbility:GetSpecialValueFor("speed") + bonus_range
	local info =
	{
		Ability = hAbility,
        EffectName = "particles/chi_strike_wave.vpcf",
        vSpawnOrigin = hTarget:GetAbsOrigin(),
        fDistance = range,
        fStartRadius = 100,
        fEndRadius = 100,
        Source = hCaster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BUILDING,
        fExpireTime = GameRules:GetGameTime() + 10,
		bDeleteOnHit = false,
		vVelocity = hCaster:GetForwardVector() * speed,
		bProvidesVision = true,
		iVisionRadius = 50,
		iVisionTeamNumber = hCaster:GetTeamNumber()
	}
		local directions = 8
		local center = hCaster:GetAbsOrigin()
		local v_x = 0
		local v_y = 0
		local v_len2 = v_x*v_x + v_y*v_y;
		if v_len2 > 0.001 then
			local v_len = math.sqrt( v_len2 )
			v_x = v_x / v_len
			v_y = v_y / v_len
		else
			v_x = 1
			v_y = 0
		end
		v_x = v_x * speed
		v_y = v_y * speed

			for i = 1, directions do
				local theta = (math.pi * 2) * ( ( i - 1 ) / directions )
				local p_x = math.cos( theta ) * v_x + math.sin( theta ) * v_y
				local p_y = -math.sin( theta ) * v_x + math.cos( theta ) * v_y
				local v = Vector( p_x, p_y, 0 )
					info.vVelocity = v
					projectile_a = ProjectileManager:CreateLinearProjectile(info)
					--print("Multi Stirke")
					--print(info.vVelocity)
			end
end
