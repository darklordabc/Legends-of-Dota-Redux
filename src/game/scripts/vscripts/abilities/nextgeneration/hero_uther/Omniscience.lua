function AddCharges (keys) -- kv OnUpgrade
	local caster = keys.caster
	local ability = keys.ability
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks",ability:GetLevel()-1)

	caster:SetModifierStackCount("modifier_omniscience",caster, max_stacks)
end



function Omniscience (keys) --KV OnOrder, Requires OrderFilter to check if order was a spell/which spell
	local caster = keys.caster
	local ability = caster:FindAbilityByName("Omniscience")
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks",ability:GetLevel()-1)
	local duration = ability:GetLevelSpecialValueFor("duration",ability:GetLevel()-1)
	local value = ability:GetLevelSpecialValueFor("value",ability:GetLevel()-1)
	local stacks = caster:GetModifierStackCount("modifier_omniscience", caster)

	if caster.DidCast then 
		local random = RandomInt(1,100)
		if (random <= (stacks * value)) and (caster.lastability:GetAbilityName() == "Hurl_Hammer" or caster.lastability:GetAbilityName() == "Threatening_Bolt") then
			
			Timers:CreateTimer({
				endTime = 0.5,
				callback = function()
					caster.lastability:RefundManaCost()
					caster.lastability:EndCooldown()
					caster:SetModifierStackCount("modifier_omniscience",caster,stacks -1)
					ability:ApplyDataDrivenModifier(caster,caster,"modifier_omniscience_dummy",{duration = duration})
				end
			})		
		else
			caster:SetModifierStackCount("modifier_omniscience",caster,max_stacks)
		end
	end
end

