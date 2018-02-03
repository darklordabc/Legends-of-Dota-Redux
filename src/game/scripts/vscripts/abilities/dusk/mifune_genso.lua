mifune_genso = class({})

LinkLuaModifier("modifier_genso_illusion","abilities/dusk/mifune_genso",LUA_MODIFIER_MOTION_NONE)

if IsServer() then

	function mifune_genso:OnSpellStart()
		local c = self:GetCaster()
		local t = self:GetCursorTarget()

		if t:TriggerSpellAbsorb(self) then return end

		local n = self:GetSpecialValueFor("illusions")

		while n > 0 do
			Timers:CreateTimer(0.10*n,function()
				self:GenIllusion(c,t,self)
			end)
			n = n - 1
		end
		self:StartCooldown(-1)
	end

	function mifune_genso:GenIllusion(caster,target,ability)
		local player = caster:GetPlayerID()
		local unit_name = caster:GetUnitName()
		local origin = target:GetAbsOrigin() + RandomVector(128)
		local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
		local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_damage", ability:GetLevel() - 1 )
		local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming", ability:GetLevel() - 1 )

		-- handle_UnitOwner needs to be nil, else it will crash the game.
		local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
		illusion:SetPlayerID(caster:GetPlayerID())
		illusion:SetControllableByPlayer(player, true)

		illusion:EmitSound("Hero_Terrorblade.Reflection")

		local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_reflection_cast.vpcf"

		local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, target )
		ParticleManager:SetParticleControl(particle, 3, Vector(1,0,0))
		
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
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
				local abilityName = ability:GetAbilityName()
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				if illusionAbility then
					illusionAbility:SetLevel(abilityLevel)
				end
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

		illusion:AddNewModifier(caster, ability, "modifier_genso_illusion", {Duration = duration})

		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
		
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()

		-- spawned heroes get no draw applied from pregame.lua
		illusion:RemoveNoDraw()

		local order = {
			UnitIndex = illusion:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		}

		ExecuteOrderFromTable(order)
		illusion:SetForceAttackTarget(target)

		illusion.attack_target = target

		--if not illusion:IsIllusion() then illusion:MakeIllusion() illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage }) end
	end

end



modifier_genso_illusion = class({})

function modifier_genso_illusion:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	}
	return state
end

function modifier_genso_illusion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_genso_illusion:OnDeath(params)
	local a = params.attacker
	local u = params.unit
	local at = self:GetParent().attack_target

	if not at then return end

	if params.unit == at then
		self:GetParent():Kill(self:GetAbility(),self:GetAbility():GetCaster())
	end

end

function modifier_genso_illusion:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("illusion_bonus_movespeed")
end