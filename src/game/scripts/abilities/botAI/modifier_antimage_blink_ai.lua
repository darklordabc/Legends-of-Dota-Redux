
modifier_antimage_blink_ai = class({})

--------------------------------------------------------------------------------

function modifier_antimage_blink_ai:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_antimage_blink_ai:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------

function modifier_antimage_blink_ai:OnCreated( params )
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink( 1 )
	end
end

--------------------------------------------------------------------------------

function modifier_antimage_blink_ai:OnIntervalThink()
	local caster = self:GetParent()
	local target = caster:GetAttackTarget()
	local ability = caster:FindAbilityByName("antimage_blink")
	local shouldBlink = false
	local shouldBlinkAggressive = false
	
	if ability and ability:IsFullyCastable() and caster:IsAlive() and not caster:IsChanneling() and caster:IsRealHero() then
		if target and target:IsRealHero() then
			distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
			-- blinks aggressively if health is comparatively high enough. (cannot be lower than 25% max)
			if (caster:GetHealthPercent() * 2) - target:GetHealthPercent() > 50 and distance > caster:GetAttackRange() then
				shouldBlinkAggressive = true
				--print("aggresive blink")
			end
		-- Bots will retreat at low health, prioritizing blink
		elseif caster:GetHealthPercent() < 30 and not target then
			shouldBlink = true
			--print("blink retreat")
		elseif GridNav:IsTraversable(caster:GetAbsOrigin()) then
			shouldBlink = true
			--print("blocked!")
		end
	end

	if shouldBlink == true then
		local cooldown = ability:GetCooldown( ability:GetLevel() )

		local origin = caster:GetAbsOrigin()
		local vector = caster:GetForwardVector()
		local range = ability:GetLevelSpecialValueFor("blink_range", ability:GetLevel() - 1)
		
		-- blinks behind an enemy if within range. 
		if shouldBlinkAggressive == true then
			vector = (target:GetAbsOrigin() - origin):Normalized()
			aggroRange = (origin - target:GetAbsOrigin()):Length2D() + 200
			if range > aggroRange then range = aggroRange end	
		end

		local location = origin + vector * range

		--DebugDrawCircle(location, Vector(0,0,255), 1, 250, false, 2 ) 

		local preorder = 
		{
			UnitIndex = caster:GetEntityIndex(), 
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = location, 
			Queue = true
		}
		local order =
		{
			UnitIndex = caster:GetEntityIndex(),
			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			AbilityIndex = ability:GetEntityIndex(),
			Position = location,
			Queue = false
		}

	    ExecuteOrderFromTable(preorder)
	    caster:Interrupt()
	    ExecuteOrderFromTable(order)
	end
end
