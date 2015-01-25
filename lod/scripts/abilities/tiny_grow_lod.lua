-- When tiny_grow_lod is upgraded
function onTinyGrowUpgrade(keys)
    local hero = keys.caster
    if not hero then return end

    -- Ensure it is leveled
    if keys.ability:GetLevel() <= 0 then return end

    -- Remove old modifiers
    if hero:HasModifier('tiny_grow_lod') then
        hero:RemoveModifierByName('tiny_grow_lod')
    end
    if hero:HasModifier('tiny_grow_lod_scepter') then
        hero:RemoveModifierByName('tiny_grow_lod_scepter')
    end

    -- Add the correct modifier
    if hero:HasScepter() then
        -- Give scepter version
        keys.ability:OnChannelFinish(true)
    else
        -- Give normal version
        keys.ability:OnSpellStart()
    end

    -- Set the model
    --hero:SetModel()
end

ListenToGameEvent('dota_item_purchased', function(keys)
    -- Check if this hero exists
    local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
    if hero then
        if hero:HasAbility('tiny_grow_lod') and hero:HasScepter() then
            local ab = hero:FindAbilityByName('tiny_grow_lod')
            if ab then
                ab:OnUpgrade()
            end
        end
    end
end, nil)
