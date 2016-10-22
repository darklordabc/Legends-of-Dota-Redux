function EssenceAmp(filterTable)
	local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    local ability_index = filterTable["entindex_inflictor_const"]
    if not victim_index or not attacker_index or not ability_index then
        return true
    end
    local attacker = EntIndexToHScript( attacker_index )
    local victim = EntIndexToHScript( victim_index )
    local ability = EntIndexToHScript( ability_index )
	local amp = attacker:FindAbilityByName("ebf_mana_fiend_essence_amp")
	if amp and amp:GetLevel() > 0 then
		local damageMult = amp:GetSpecialValueFor("crit_amp")
		local manaburn = ability:GetManaCost(-1) * damageMult - ability:GetManaCost(-1)
		local perc = amp:GetSpecialValueFor("crit_chance")
		if RollPercentage(perc) and caster:GetMana() >= manaburn then
			filterTable["damage"] = filterTable["damage"] * damageMult
			local particle = ParticleManager:CreateParticle("particles/essence_amp_crit.vpcf",PATTACH_POINT_FOLLOW,caster)
			caster:EmitSound("Hero_TemplarAssassin.Meld.Attack")
			target:ShowPopup( {
						PostSymbol = 4,
						Color = Vector( 125, 125, 255 ),
						Duration = 0.7,
						Number = filterTable["damage"],
						pfx = "spell_custom"} )
			caster:SpendMana(manaburn, ability)
		end
	end
 end