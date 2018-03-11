ancient_priestess_spirit_link = class({})
LinkLuaModifier("modifier_ancient_priestess_spirit_link", "abilities/life_in_arena/modifier_ancient_priestess_spirit_link.lua",LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	require('lib/timers')
end

function ancient_priestess_spirit_link:CastFilterResultTarget( hTarget )
	local nCasterID = self:GetCaster():GetPlayerOwnerID()
	local nTargetID = hTarget:GetPlayerOwnerID()
	
	--на клиенте невозможно проверить запрещена ли помощь союзникам 26.09.16
	if IsServer() and not hTarget:IsOpposingTeam(self:GetCaster():GetTeamNumber()) and PlayerResource:IsDisableHelpSetForPlayerID(nTargetID,nCasterID) then 	
		return UF_FAIL_DISABLE_HELP
	end

	return UnitFilter(hTarget,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_CHECK_DISABLE_HELP,
		self:GetCaster():GetTeamNumber() )
end

function ancient_priestess_spirit_link:OnSpellStart() 
	local caster = self:GetCaster()

	local maxUnits = self:GetSpecialValueFor("max_unit")
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")

	local nUnits = 1
	local tTargets = {}


	local target = self:GetCursorTarget()
	target:RemoveModifierByName("modifier_ancient_priestess_spirit_link") 
	target:AddNewModifier(caster, self, "modifier_ancient_priestess_spirit_link", {duration = duration})
	target:FindModifierByName("modifier_ancient_priestess_spirit_link").tTargets = tTargets 

	local particle = ParticleManager:CreateParticle("particles/dazzle_shadow_wave_custom.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))	
	ParticleManager:SetParticleControl(particle,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	--звук
	table.insert(tTargets,target)

	Timers:CreateTimer(0.1,
		function()
			local prevTarget = target
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), prevTarget:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
			
			for _,unit in pairs(tTargets) do 
				for k2,unit2 in pairs(targets) do 
 					if unit == unit2 then 
 						table.remove(targets,k2)
 						break
 					end 
 				end 
			end

			target = targets[1]

			if target and not PlayerResource:IsDisableHelpSetForPlayerID(target:GetPlayerOwnerID(),caster:GetPlayerOwnerID()) then 
				target:RemoveModifierByName("modifier_ancient_priestess_spirit_link")
				target:AddNewModifier(caster, self, "modifier_ancient_priestess_spirit_link", {duration = duration})
				local modifier = target:FindModifierByName("modifier_ancient_priestess_spirit_link")
				modifier.tTargets = tTargets

				local particle = ParticleManager:CreateParticle("particles/dazzle_shadow_wave_custom.vpcf", PATTACH_WORLDORIGIN, prevTarget)
				ParticleManager:SetParticleControl(particle,0,Vector(prevTarget:GetAbsOrigin().x,prevTarget:GetAbsOrigin().y,prevTarget:GetAbsOrigin().z + prevTarget:GetBoundingMaxs().z ))	
				ParticleManager:SetParticleControl(particle,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
				--звук
				table.insert(tTargets,target)
				nUnits = nUnits + 1
			else 
				return nil
			end

			if nUnits >= maxUnits then 
				return nil 
			end
			return 0.1
		end)

	EmitSoundOn("Hero_Dazzle.Shadow_Wave", caster)
end