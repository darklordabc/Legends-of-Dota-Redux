function huisu( keys )
	local caster = keys.caster
	if caster.p_hp and caster.p_origin then
		local p = 'particles/econ/events/ti4/blink_dagger_start_ti4.vpcf'
		local p_index = ParticleManager:CreateParticle(p,1,caster)
		ParticleManager:SetParticleControl(p_index,0,caster:GetAbsOrigin())

		local p = 'particles/econ/events/ti4/blink_dagger_end_ti4.vpcf'
		local p_index = ParticleManager:CreateParticle(p,1,caster)
		ParticleManager:SetParticleControl(p_index,0,caster:GetAbsOrigin())

		caster:SetHealth(caster.p_hp[1])
		FindClearSpaceForUnit(caster,caster.p_origin[1],false)
		caster:Stop()

	else
		--Warning("#unknow_warning_time_huisu")
		Notifications:Bottom(caster:GetPlayerOwner(),{text="#unknow_warning_time_huisu",style={color="red"},duration=5})
		caster:FindAbilityByName("shiguanghuisu"):EndCooldown()
	end
end

function huisu_interval( keys )
	local caster = keys.caster
	local ability = keys.ability

	if caster.huisu_timer then
		return
	end
	
	if ability:GetLevel()>0 then
		if not caster.p_hp then
			caster.p_hp = {}
		end
		if not caster.p_origin then
			caster.p_origin = {}
		end

		caster.huisu_timer = true
		Timers:CreateTimer(0,function()
			if caster:IsAlive() then
				while (#caster.p_hp >=50) do
					table.remove(caster.p_hp,1)
					table.remove(caster.p_origin,1)
				end
				table.insert(caster.p_hp,caster:GetHealth())
				table.insert(caster.p_origin,caster:GetAbsOrigin())
			end
			return 0.06
		end)
	end
end

function chongci( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local caster_ori =caster:GetAbsOrigin()
	local distance = math.min((caster_ori-point):Length2D(),keys.maxdistance)
	local radius = keys.radius
	local dir = GetNorDir(point,caster_ori)

	local p = 'particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_jewel.vpcf'
	local p_index = ParticleManager:CreateParticle(p,1,caster)
	ParticleManager:SetParticleControlEnt(p_index,0, caster,PATTACH_CUSTOMORIGIN_FOLLOW,"attach_hitloc",caster_ori, false)

	local n = 1
	Timers:CreateTimer(0,function()
		if (not caster:IsAlive()) or caster:IsStunned() or caster:IsSilenced() then
			ParticleManager:DestroyParticle(p_index,false)
			return nil
		end

		local origin = caster_ori+dir*distance/9*n
		origin.z = GetGroundHeight(origin,nil)
		if n<9 then
			caster:SetAbsOrigin(origin)
			n = n+1
			return 0.02
		else
			FindClearSpaceForUnit(caster,origin,false)
			ParticleManager:DestroyParticle(p_index,false)

			--减速
			local p2 = "particles/units/heroes/hero_faceless_void/faceless_void_timedialate.vpcf"
			local p_index2 = ParticleManager:CreateParticle(p2,PATTACH_WORLDORIGIN,nil)
			ParticleManager:SetParticleControl(p_index2,0,caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(p_index2,1,Vector(radius*1.5,0,0))
			ParticleManager:ReleaseParticleIndex(p_index2)

			local units = FindEnemy(caster:GetTeam(),caster:GetAbsOrigin(),radius)
			if #units>0 then
				for _,unit in pairs(units) do
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_chongci_jiansu",{})
				end
			end

			return nil
		end
	end)
end