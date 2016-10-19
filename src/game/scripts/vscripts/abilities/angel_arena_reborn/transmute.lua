if IsServer() then
	require('lib/timers')
end

function Transmute( event )
	-- Variables
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	if not caster or not target or not ability then return end

	local hp_to_gold_percent = event.health_to_gold / 100
	local target_health = target:GetHealth()	
	local cd_time = ability:GetCooldownTimeRemaining() 
	print(cd_time)

	if not target_health or not cd_time then return end
	if hp_to_gold_percent > 1 then hp_to_gold_percent = 0.5 end

	_G.transmute_antibug = _G.transmute_antibug or {}

	if _G.transmute_antibug[caster:GetPlayerOwnerID()] and _G.transmute_antibug[caster:GetPlayerOwnerID()] > 0 then
		print("returned")
		return
	end
	_G.transmute_antibug[caster:GetPlayerOwnerID()] = cd_time

	if not _G.tansmute_antibug_bool then
		Timers:CreateTimer(1, function()
      								for i,x in pairs(_G.transmute_antibug) do
      									if i and x then
      										if x > 0 then
      											_G.transmute_antibug[i] = _G.transmute_antibug[i] - 1
      										end
      									end
      								end
				      			return 1
  								end )
		_G.tansmute_antibug_bool = true
	end

	caster:ModifyGold(hp_to_gold_percent*target_health, false, 0) 

	ApplyDamage({ victim = target, attacker = caster, damage = target_health+1,	damage_type = DAMAGE_TYPE_PURE })

end
