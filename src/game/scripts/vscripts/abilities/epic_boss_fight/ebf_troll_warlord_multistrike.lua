function Fervor(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = keys.modifier
	local standard_cap = GameRules:GetGameModeEntity():GetMaximumAttackSpeed()
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", ability_level)
	local chance = ability:GetLevelSpecialValueFor("chance_per_stack", ability_level)
	local duration = ability:GetSpecialValueFor("stack_duration")
	
	if not ability.prng then ability.prng = 0 end
	-- Check if we have an old target
	if caster.fervor_target then
		-- Check if that old target is the same as the attacked target
		if caster.fervor_target == target then
			-- Check if the caster has the attack speed modifier
			if caster:HasModifier(modifier) then
				-- Get the current stacks
				local stack_count = caster:GetModifierStackCount(modifier, ability)

				-- Check if the current stacks are lower than the maximum allowed
				if stack_count < max_stacks then
					-- Increase the count if they are
					if not caster.stuntattack then
						ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
						caster:SetModifierStackCount(modifier, ability, stack_count + 1)
						if chance*(stack_count + 1) > math.random(100 - ability.prng) then
						caster.stuntattack = true
						caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, (2*caster:GetAttacksPerSecond()))
						Timers:CreateTimer(
                        function()
                            caster.stuntattack = true
							caster:PerformAttack(target, true, true, true, false, true)	
                        end, DoUniqueString('ebf_troll_warlord_multistrike'), caster:GetAttacksPerSecond() / 2)
						ability.prng = 0
						end
					else
						caster.stuntattack = false
						ability.prng = ability.prng + 1
					end
				else
					if not caster.stuntattack then
						ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
						caster:SetModifierStackCount(modifier, ability, stack_count)
						if chance*stack_count > math.random(100 - ability.prng) then
						caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, (2*caster:GetAttacksPerSecond()))
						Timers:CreateTimer(
                        function()
                            caster.stuntattack = true
							caster:PerformAttack(target, true, true, true, false, true)	
                        end, DoUniqueString('ebf_troll_warlord_multistrike'), caster:GetAttacksPerSecond() / 2)
						ability.prng = 0
						end
					else
						caster.stuntattack = false
						ability.prng = ability.prng + 1
					end
				end
			else
				-- Apply the attack speed modifier and set the starting stack number
				ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
				caster:SetModifierStackCount(modifier, ability, 1)
				if chance > math.random(100 - ability.prng) and not caster.stuntattack then
					caster.stuntattack = true
					caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, (2*caster:GetAttacksPerSecond()))
					Timers:CreateTimer(0.2,function()
								caster:PerformAttack(target, true, true, true, false, true)
								ability.prng = 0
							end)
				else
					caster.stuntattack = false
				end
			end
		else
			-- If its not the same target then set it as the new target and remove the modifier
			caster:RemoveModifierByName(modifier)
			caster.fervor_target = target
		end
	else
		caster.fervor_target = target
	end
end