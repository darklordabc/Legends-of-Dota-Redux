--[[print("Hello from game mode init")

local csp = Entities:FindAllByClassname('dota_base_game_mode')[1]
--local csp = GameRules:GetGameModeEntity()

csp:SetUseCustomHeroLevels(true)
csp:SetCustomHeroMaxLevel(10000)
csp:SetCustomXPRequiredToReachNextLevel({
    0,
    100,
    2,
    3
})

ListenToGameEvent('dota_item_purchased', function(self, keys)
    print("Hello there!")

    local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
    print(hero)

    hero:SetBaseMoveSpeed(3000)
    hero:SetBaseIntellect(100)

    print(hero:GetIntellect())

    --hero:SwapAbilities("antimage_blink", "antimage_spell_shield", true, false)

    local blink = hero:FindAbilityByName("antimage_blink")

    blink:OnAbilityPinged()

    blink:PayManaCost()

    blink:SetAbilityIndex(4)

    hero:SetMoveCapability(2)
    hero:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

end, {})
]]

--[[print("Lets do this")

for k,v in pairs(Entities:FindAllByClassname('*')) do
    local name = v:GetClassname()

    if name ~= "worldspawn" then
        print(name)
        --v:Remove()
    end
end]]
