function EssenceAmp(filterTable)
	local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    local ability_index = filterTable["entindex_inflictor_const"]
    if not victim_index or not attacker_index or not ability_index then
        return filterTable
    end
    local attacker = EntIndexToHScript( attacker_index )
    local victim = EntIndexToHScript( victim_index )
    local ability = EntIndexToHScript( ability_index )
	
	
	if attacker == victim or attacker:PassivesDisabled() then return filterTable end
	local amp = attacker:FindAbilityByName("ebf_mana_fiend_essence_amp")
	--print(amp and amp:GetLevel() > 0, "ampcheck")
	if amp and amp:GetLevel() > 0 then
		local damageMult = amp:GetSpecialValueFor("crit_amp") / 100
		local manaburn = ability:GetManaCost(-1) * (filterTable["damage"]*damageMult / (ability:GetLevel()*80))
		-- Return if the source of spell damage does not have a manacost, its probably a passive source of spell damage like radiance.
		--print(manaburn)
		if manaburn == 0 then
			return filterTable
		end
		local perc = amp:GetSpecialValueFor("crit_chance")		
		if attacker:GetMana() >= manaburn then
			attacker.essenceCritPrng = attacker.essenceCritPrng or 0
			if RollPercentage(perc-1+attacker.essenceCritPrng) then
				filterTable["damage"] = filterTable["damage"] * damageMult
				local particle = ParticleManager:CreateParticle("particles/essence_amp_crit.vpcf", PATTACH_POINT_FOLLOW, attacker)
				attacker:EmitSound("Hero_TemplarAssassin.Meld.Attack")
				victim:ShowPopup( {
							PostSymbol = 4,
							Color = Vector( 125, 125, 255 ),
							Duration = 0.7,
							Number = filterTable["damage"],
							pfx = "spell_custom"} )
				attacker:SpendMana(manaburn / 2, ability)
				attacker.essenceCritPrng = 0
			else
				attacker.essenceCritPrng = attacker.essenceCritPrng + 1
			end
		end
	end
	return filterTable
 end

 function CDOTA_BaseNPC:ShowPopup( data )
    if not data then return end

    local target = self
    if not target then error( "ShowNumber without target" ) end
    local number = tonumber( data.Number or nil )
    local pfx = data.Type or "miss"
    local player = data.Player or false
    local color = data.Color or Vector( 255, 255, 255 )
    local duration = tonumber( data.Duration or 1 )
    local presymbol = tonumber( data.PreSymbol or nil )
    local postsymbol = tonumber( data.PostSymbol or nil )

    local path = "particles/msg_fx/msg_" .. pfx .. ".vpcf"
    local particle = ParticleManager:CreateParticle(path, PATTACH_OVERHEAD_FOLLOW, target)
    if player then
		local playerent = PlayerResource:GetPlayer( self:GetPlayerID() )
        local particle = ParticleManager:CreateParticleForPlayer( path, PATTACH_OVERHEAD_FOLLOW, target, playerent)
    end
	
	if number then
		number = math.floor(number+0.5)
	end

    local digits = 0
    if number ~= nil then digits = string.len(number) end
    if presymbol ~= nil then digits = digits + 1 end
    if postsymbol ~= nil then digits = digits + 1 end

    ParticleManager:SetParticleControl( particle, 1, Vector( presymbol, number, postsymbol ) )
    ParticleManager:SetParticleControl( particle, 2, Vector( duration, digits, 0 ) )
    ParticleManager:SetParticleControl( particle, 3, color )
end
