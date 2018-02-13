LinkLuaModifier('modifier_bash_cooldown', 'abilities/bash_cooldown.lua', LUA_MODIFIER_MOTION_NONE)

modifier_bash_cooldown = class({
	IsPurgable = function() return false end,
	GetTexture = function() return 'spirit_breaker_greater_bash' end,
})

function BashCooldown( filterTable )
    local pIndex = filterTable.entindex_parent_const
    local cIndex = filterTable.entindex_caster_const
    local aIndex = filterTable.entindex_ability_const
    if not pIndex or not cIndex or not aIndex then
	    return true
    end
	
    local parent = EntIndexToHScript(pIndex)
    local caster = EntIndexToHScript(cIndex)
    local ability = EntIndexToHScript(aIndex)
    local modifierName = filterTable.name_const
    local duration = filterTable.duration
    local abbysalActiveDuration = 2.0

    -- Reflect only modifiers created by abilities with 'bash' flag
    if (ability:HasAbilityFlag('bash') or ability:GetName() == "item_basher" or ability:GetName() == "item_abyssal_blade") and
    	-- All bash abilities adds passive modifier on it's caster, so we should ignore it
        parent ~= caster then
        --allow abbysal blade active to stun because its not a bash.
        if modifierName == "modifier_bashed" and duration == abbysalActiveDuration then return true end
        if parent:HasModifier('modifier_bash_cooldown') then
        	-- Unit was bashed in a short time. Don't add this modifier
            return false
        else
        	-- Unit bashed. Add cooldown modifier for 5s, so it won't be bashed again
            parent:AddNewModifier(caster, nil, 'modifier_bash_cooldown', {
                duration = 5
            })
           Timers:CreateTimer(function() trackModifier( filterTable ) end)
        end
    end
    return true
end

function trackModifier( filterTable )
    local parentIndex = filterTable["entindex_parent_const"]
    local casterIndex = filterTable["entindex_caster_const"]
    if not parentIndex or not casterIndex then
        return
    end
    local parent = EntIndexToHScript( parentIndex )
    local caster = EntIndexToHScript( casterIndex )
    local modifierName = filterTable["name_const"]
    local duration = filterTable["duration"]
    local abbysalActiveDuration = 2.0

    Timers:CreateTimer(0.1, function()
        local modifier = parent:FindModifierByNameAndCaster(modifierName, caster)
        if not modifier or modifier:IsNull() then return end
        local elapsed = modifier:GetElapsedTime()

        modifier.prevElapsed = modifier.prevElapsed or elapsed
        if modifier.prevElapsed > elapsed then
          -- call any functions that need to interact with modifiers on refresh here
            if parent and not parent:IsNull() then
                if parent:HasModifier("modifier_bash_cooldown") then
                    --if this is abbysal blade active dont destroy
                    if modifierName == "modifier_bashed" and duration == abbysalActiveDuration then return end
                    modifier:Destroy()
                end
            end
        end

        if elapsed >= duration then
            return
        end
        return 0.1
    end)
end
