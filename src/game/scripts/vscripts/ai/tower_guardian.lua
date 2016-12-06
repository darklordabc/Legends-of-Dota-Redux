--[[
Broodking AI
]]

require( "ai/ai_core" )

-- GENERIC AI FOR SIMPLE CHASE ATTACKERS

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
	thisEntity.ownerLevel = thisEntity:GetOwnerEntity():GetLevel()
end


function AIThink()
	if thisEntity:GetOwnerEntity():GetLevel() ~= thisEntity.ownerLevel then
		local hpPct = thisEntity:GetHealth() / thisEntity:GetMaxHealth()
		thisEntity:SetMaxHealth(thisEntity:GetMaxHealth() + 50)
		thisEntity:SetBaseMaxHealth(thisEntity:GetBaseMaxHealth() + 50)
		thisEntity:SetHealth(thisEntity:GetMaxHealth()*hpPct)
		thisEntity:SetBaseDamageMax(thisEntity:GetBaseDamageMax() + 5)
		thisEntity:SetBaseDamageMin(thisEntity:GetBaseDamageMin() + 5)
		thisEntity:SetPhysicalArmorBaseValue(thisEntity:GetPhysicalArmorBaseValue() + 0.25)
		thisEntity.ownerLevel = thisEntity:GetOwnerEntity():GetLevel()
	end
	if not thisEntity:IsControllableByAnyPlayer() then
		return 0.25
	else return 0.25 end
	return 0.25
end