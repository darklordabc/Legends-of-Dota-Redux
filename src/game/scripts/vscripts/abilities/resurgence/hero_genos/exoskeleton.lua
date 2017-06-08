--[[Author: The Great Gimmick
	5/15/17]]

LinkLuaModifier("modifier_exoskeleton", "heroes/hero_genos/modifiers/modifier_exoskeleton.lua", LUA_MODIFIER_MOTION_NONE)

function InitialShell(event)
	local caster = event.caster
	local ability = event.ability
	local ability_level = ability:GetLevel() - 1

	local point = caster:GetAbsOrigin()

	caster.exoskeleton_magic_resistance = ability:GetLevelSpecialValueFor("magicresist", ability_level) + caster.aquired_immunity_adaptations*5
    caster.exoskeleton_amror = ability:GetLevelSpecialValueFor("armor", ability_level) + caster.aquired_immunity_adaptations*2

    print("")
    print("InitialShell")
    print(caster.exoskeleton_magic_resistance)
    print(caster.exoskeleton_amror)

	caster:AddNewModifier(caster, ability, "modifier_exoskeleton", {R = caster.exoskeleton_magic_resistance , A = caster.exoskeleton_amror})
	caster.shell = CreateUnitByName("genos_shell", point, false, caster, caster, caster:GetTeam())
	--ability:ApplyDataDrivenModifier(caster, caster, "modifier_exoskeleton_shell", {})
    caster.shell:FindAbilityByName("hazel_broom_passive"):SetLevel(1)
end

function UpgradeShell(event)
	local caster = event.caster
	local ability = event.ability
	local ability_level = ability:GetLevel() - 1

	local shell = caster:FindModifierByName("modifier_exoskeleton")

	if shell then
		caster:RemoveModifierByName("modifier_exoskeleton")
		caster.exoskeleton_magic_resistance = ability:GetLevelSpecialValueFor("magicresist", ability_level) + caster.aquired_immunity_adaptations*5
    	caster.exoskeleton_amror = ability:GetLevelSpecialValueFor("armor", ability_level) + caster.aquired_immunity_adaptations*2
    	print("")
    print("UpgradeShell")
    	print(caster.exoskeleton_magic_resistance)
    	print(caster.exoskeleton_amror)

		caster:AddNewModifier(caster, ability, "modifier_exoskeleton", {R = caster.exoskeleton_magic_resistance , A = caster.exoskeleton_amror})
	end
end

function ShellChange(event)
	local caster = event.caster
	local ability = event.ability
	local ability_level = ability:GetLevel() - 1

	local shell = caster:FindModifierByName("modifier_exoskeleton")

	if shell then 
		caster:RemoveModifierByName("modifier_exoskeleton")
		caster:EmitSound("Hero_Bristleback.PistonProngs.Bristleback")
		--caster:RemoveModifierByName("modifier_exoskeleton_shell")
		caster.shell:RemoveSelf()
	else
		local point = caster:GetAbsOrigin()
		local shield = ability:GetLevelSpecialValueFor("invince", (ability:GetLevel() - 1))

		caster.exoskeleton_magic_resistance = ability:GetLevelSpecialValueFor("magicresist", ability_level) + caster.aquired_immunity_adaptations*5
    	caster.exoskeleton_amror = ability:GetLevelSpecialValueFor("armor", ability_level) + caster.aquired_immunity_adaptations*2
		caster:AddNewModifier(caster, ability, "modifier_exoskeleton", {R = caster.exoskeleton_magic_resistance , A = caster.exoskeleton_amror})
    print("")
    print("ShellChange")
    print(caster.exoskeleton_magic_resistance)
    print(caster.exoskeleton_amror)

		--ability:ApplyDataDrivenModifier(caster, caster, "modifier_exoskeleton_shell", {})
		caster:AddNewModifier(caster, ability, "modifier_invulnerable", { duration = shield })
		caster:EmitSound("Hero_Bristleback.PistonProngs.QuillSpray.Cast")
		caster.shell = CreateUnitByName("genos_shell", point, false, caster, caster, caster:GetTeam())
    	caster.shell:FindAbilityByName("hazel_broom_passive"):SetLevel(1)
	end

end
--[[
function ShellFollow(event)
	print("shell following")
	local caster = event.caster

	if not caster.shell:IsNull() then
		local point = caster:GetAbsOrigin() 
        local fv = (caster:GetForwardVector())
        	caster.shell:SetAbsOrigin((point + Vector(0,0,0))-fv*1)
        	caster.shell:SetForwardVector(fv*-1)

    		if not caster.vision_checker then
		        local team = caster:GetTeamNumber()
		        local panic = 0
		        --set vision dummy to the opposite team. If there are more than two teams, do not spawn a vision dummy. 
		        if team == 2 then
		            team = 3
		        else
		            if team == 3 then
		                team = 2
		            else
		                panic = 1
		            end
		        end
		        --create vision dummy if there are just two teams. 
		        if panic == 0 then
		            caster.vision_checker = CreateUnitByName("eye_of_the_moon_dummy", Vector(0, 0, 0), false, caster, caster, team)
		            print("Vision checker made by "..caster:GetName().." created on team "..team..".")
		        else
		            print("Vision checker has failed due to the team being '"..team.."'.")
		        end
		    end
	        local see_caster = caster.vision_checker:CanEntityBeSeenByMyTeam(caster)
	        if not see_caster then
	        	ability:ApplyDataDrivenModifier(caster, caster.shell, "modifier_invisible_broom", { duration = 0.01 })
	        end

    end
end
]]

