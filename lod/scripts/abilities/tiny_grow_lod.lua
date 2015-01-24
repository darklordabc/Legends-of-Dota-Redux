-- When tiny_grow_lod is upgraded
function onTinyGrowUpgrade(keys)
    local hero = keys.caster
    if not hero then return end

    print('inside')

    -- Ensure it is leveled
    if keys.ability:GetLevel() <= 0 then return end

    print('Leveled!')

    -- Remove old modifiers
    hero:RemoveModifierByName('tiny_grow_lod')
    hero:RemoveModifierByName('tiny_grow_lod_scepter')

    -- Add the correct modifier
    if hero:HasScepter() then
        -- Give scepter version
        keys.ability:OnChannelFinish(true)
        print('scepter')
    else
        -- Give normal version
        keys.ability:OnSpellStart()
        print('regular')
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
                print('running upgrade')
                ab:OnUpgrade()
            end
        end
    end
end, nil)
