function OnKilled(keys)
	local caster = keys.caster
	local unit = keys.unit
	local ability = keys.ability
	local bonus_day = keys.bonus_day/100
	local bonus_night = keys.bonus_night/100

	if not caster or not unit then return end

	if caster:IsIllusion() or unit:IsIllusion() then return end
	
	local day = GameRules:IsDaytime() 
	local unit_health = unit:GetMaxHealth() 
	local heal = 0

	if day then
		heal = unit_health*bonus_day
	else
		heal = unit_health*bonus_night
	end

	caster:Heal(heal, ability) 
	--[[
	print("IsDay:", day)
	print("Heal:", heal)

	for i,x in pairs(keys) do print(i, x) end
	]]
end