function GetSummonPoints( keys )
    local caster = keys.caster
    local fv = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
    local distance = keys.distance

    local frontPosition = origin + fv * distance

    local result = { }
    table.insert(result, frontPosition)
    return result
end

function SetUnitsMoveForward( keys )
    local caster = keys.caster
    local target = keys.target
    local fv = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
    target:SetForwardVector(fv)
    -- Add the target to a table on the caster handle, to find them later
    table.insert(caster.wolves, target)
end

function ExplosiveSporeSound( keys )
    print( keys.target:GetHealth() )
    if not keys.target:IsAlive() then
        local particleName = "particles/cherub_explosive_spore.vpcf"
        local soundEventName = "Ability.Techies_LandMines"
        
        local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, keys.target )
        StartSoundEvent( soundEventName, keys.target )
        ParticleManager:ReleaseParticleIndex(fxIndex)
    end
end
