function HealPercent(keys)
	print("HOL AHEAL")
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local heal_pct = keys.heal_pct / 100
	print("HEAL FOR ", target:GetMaxHealth()*heal_pct)
	target:Heal(target:GetMaxHealth()*heal_pct , ability)
end