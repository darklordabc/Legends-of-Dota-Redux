butcher_zombie = class ({})
LinkLuaModifier("modifier_butcher_zombie", "abilities/life_in_arena/modifier_butcher_zombie.lua" ,LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	require('lib/timers')
end

function butcher_zombie:GetIntrinsicModifierName() 
	return "modifier_butcher_zombie"
end

function butcher_zombie:OnToggle()
	local modifier = self:GetCaster():FindModifierByName("modifier_butcher_zombie")
	if self:GetToggleState() then

		modifier:SetDuration(self.zombieRemaining or 15,true)
		Timers:CreateTimer("ButcherZombie",
			{
				endTime = self.zombieRemaining or 15,
				callback = function() self:CreateZombie() modifier:SetDuration(15,true) return 15 end
			}
		)
	else
		self.zombieRemaining = modifier:GetRemainingTime()
		--print(self.zombieRemaining)
		modifier:SetDuration(-1,true)
		Timers:RemoveTimer("ButcherZombie")
	end
end

function butcher_zombie:CreateZombie()
	local caster = self:GetCaster()
	local level = self:GetLevel()
	local unit_name = {"butcher_zombie_1","butcher_zombie_2","butcher_zombie_3","butcher_zombie_4"}
	local butcher_return_level = caster:FindAbilityByName("butcher_zombie"):GetLevel()


	if not caster:HasModifier("modifier_hide_lua") and GameRules:State_Get() ~= DOTA_GAMERULES_STATE_POST_GAME then --если герой спрятан, то зомби не спавним
		--точку спавна устанавливаем позади героя
		local spawnLoc = caster:GetAbsOrigin()-caster:GetForwardVector()*75 

		local zombie = CreateUnitByName(unit_name[level], spawnLoc, true, caster, caster, caster:GetTeamNumber())
		zombie:SetControllableByPlayer(caster:GetPlayerID(), true)
		zombie:FindAbilityByName("butcher_skin"):SetLevel(butcher_return_level)

		--Timers:CreateTimer(0.1,function() zombie:MoveToNPC(caster) end)
		
		local modifier = caster:FindModifierByName("modifier_butcher_zombie")
		modifier:SetStackCount(modifier:GetStackCount()+1)

		-- Setup lifetime
		zombie:AddNewModifier(zombie,nil,"modifier_kill",{duration=self:GetSpecialValueFor("zombie_lifetime")})
	end
end

function butcher_zombie:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAbility()
	end
end

function butcher_zombie:OnOwnerDied()
	if self:GetLevel() >= 1 and self:GetToggleState() then
		local modifier = self:GetCaster():FindModifierByName("modifier_butcher_zombie")
		
		self.zombieRemaining = modifier:GetRemainingTime()
		self.toggleState = self:GetToggleState()
		
		--print(self.zombieRemaining)
		modifier:SetDuration(-1,true)
		Timers:RemoveTimer("ButcherZombie")
	end
end

function butcher_zombie:OnOwnerSpawned()
	if self.toggleState then
		local modifier = self:GetCaster():FindModifierByName("modifier_butcher_zombie")
		
		self:ToggleAbility()

		modifier:SetDuration(self.zombieRemaining or 15,true)
		
		Timers:CreateTimer("ButcherZombie",
			{
				endTime = self.zombieRemaining or 15,
				callback = function() self:CreateZombie() modifier:SetDuration(15,true) return 15 end
			}
		)
	end
end	
