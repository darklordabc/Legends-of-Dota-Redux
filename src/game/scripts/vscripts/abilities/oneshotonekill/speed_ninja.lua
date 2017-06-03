function zhanhun( keys )
	local caster = keys.caster
	local reduce = keys.reduce
	
	local ability = keys.event_ability
	local abilityCooldown = ability:GetCooldown(ability:GetLevel())
	local abilityManaCost = ability:GetManaCost(ability:GetLevel())
	--Does not proc for abilities with low cooldowns or no manacost
	if abilityManaCost == 0 then return nil end
	if abilityCooldown < 3 then return nil end


	for i = 0,10 do
		local ability = caster:GetAbilityByIndex(i)
		if ability:GetLevel()>0 and not ability:IsCooldownReady() then
			local remain = ability:GetCooldownTimeRemaining()
			ability:EndCooldown()
			ability:StartCooldown(remain-reduce)
		end
	end
end

function saodang( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local radius = keys.radius
	local caster_ori =caster:GetAbsOrigin()
	local distance = math.min((caster_ori-point):Length2D(),keys.maxdistance)
	local dir = (point-caster_ori):Normalized()
	dir.z = 0
	dir = dir:Normalized()

	local p = 'particles/skills/saodang/iron.vpcf'
	local p_c = ParticleManager:CreateParticle(p,1,caster)
	ParticleManager:SetParticleControlEnt(p_c,0, caster,PATTACH_POINT_FOLLOW,"attach_hitloc",caster_ori, true)

	local n = 0
	Timers:CreateTimer(0,function()
		if (not caster:IsAlive()) or caster:IsStunned() or caster:IsSilenced() then
			ParticleManager:DestroyParticle(p_c,false)
			return nil
		end

		caster_ori = caster_ori + dir*distance/9
		caster_ori.z = GetGroundHeight(caster_ori,nil)
		if n<9 then
			caster:SetAbsOrigin(caster_ori)
			aoe_damage(caster,caster_ori,radius)
			n = n+1
			return 0.02
		else
			FindClearSpaceForUnit(caster, caster_ori,false)
			keys.ability:ApplyDataDrivenModifier(caster,caster,"saodang_jiasu",nil)
			--ParticleManager:DestroyParticle(p_c,false)
			return nil
		end
	end)
	Timers:CreateTimer( keys.duration + 0.3 ,function()
		ParticleManager:DestroyParticle(p_c,false)
		return nil
	end)
end

function yuanyue( keys )
	local target = keys.target
	local radius = keys.radius
	local p = 'particles/skills/yuanyue/yuanyue_cleave.vpcf'
	local p_c = ParticleManager:CreateParticle(p,1,target)
	ParticleManager:SetParticleControl(p_c,1,Vector(1,0,radius))
end

function shunzhan( keys )
	local caster = keys.caster
	local radius = keys.radius
	local point = keys.target_points[1]
	local target = keys.target
	if target then
		caster.preplace = caster:GetAbsOrigin()
		local p = 'particles/skills/shunzhan/shunzhan_target_ground_fallback_mid_egset.vpcf'
		local p_c = ParticleManager:CreateParticle(p,PATTACH_POINT_FOLLOW,target)
		ParticleManager:SetParticleControl(p_c,0,target:GetAbsOrigin())
		ParticleManager:SetParticleControl(p_c,1,Vector(200,200,200))
		FindClearSpaceForUnit(caster,target:GetAbsOrigin(),false)
		caster:PerformAttack( target,true, true, true, true,true,true,true)
		EmitSoundOn("Speed.shunzhan",target)

		local level = caster:FindAbilityByName("shunzhan"):GetLevel()
		caster:RemoveAbility("shunzhan")
		caster:AddAbility("shunzhan_back")
		caster:FindAbilityByName("shunzhan_back"):SetLevel(level)

		Timers:CreateTimer(3,function()
			if caster:HasAbility("shunzhan_back") then
				local lv = caster:FindAbilityByName("shunzhan_back"):GetLevel()
				caster:RemoveAbility("shunzhan_back")
				caster:AddAbility("shunzhan")
				local ability = caster:FindAbilityByName("shunzhan")
				ability:SetLevel(lv)
				ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1))
			end
		end)
	else
		local targets = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,0,false)
		if targets[1] then
			caster.preplace = caster:GetAbsOrigin()
			local p = 'particles/skills/shunzhan/shunzhan_target_ground_fallback_mid_egset.vpcf'
			local p_c = ParticleManager:CreateParticle(p,PATTACH_POINT_FOLLOW,targets[1])
			ParticleManager:SetParticleControl(p_c,0,targets[1]:GetAbsOrigin())
			ParticleManager:SetParticleControl(p_c,1,Vector(200,200,200))
			FindClearSpaceForUnit(caster,targets[1]:GetAbsOrigin(),false)
			caster:PerformAttack( targets[1],true, true, true, true,true,true,true)
			EmitSoundOn("Speed.shunzhan",targets[1])

			local level = caster:FindAbilityByName("shunzhan"):GetLevel()
			caster:RemoveAbility("shunzhan")
			caster:AddAbility("shunzhan_back")
			caster:FindAbilityByName("shunzhan_back"):SetLevel(level)

			Timers:CreateTimer(3,function()
				if caster:HasAbility("shunzhan_back") then
					local lv = caster:FindAbilityByName("shunzhan_back"):GetLevel()
					caster:RemoveAbility("shunzhan_back")
					caster:AddAbility("shunzhan")
					local ability = caster:FindAbilityByName("shunzhan")
					ability:SetLevel(lv)
					ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1))
				end
			end)
		end
	end
end

function shunzhan_back( keys )
	local caster = keys.caster
	if caster.preplace then
		caster:SetAbsOrigin(caster.preplace)
		local level = caster:FindAbilityByName("shunzhan_back"):GetLevel()
		caster:RemoveAbility("shunzhan_back")
		caster:AddAbility("shunzhan")
		local ability = caster:FindAbilityByName("shunzhan")
		ability:SetLevel(level)
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1) )
	end
end