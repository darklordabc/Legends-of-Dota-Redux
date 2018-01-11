function PreformAbilityPrecastActions(unit, ability)
	if ability:IsCooldownReady() and ability:IsOwnersManaEnough() then
		ability:PayManaCost()
		ability:AutoStartCooldown()
		return true
	end
	return false
end
