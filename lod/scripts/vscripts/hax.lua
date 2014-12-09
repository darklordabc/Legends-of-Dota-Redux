if not _G.hax then
    Convars:RegisterCommand('lod_hax', function()
        if _G.hax then
            local worked, err = pcall(_G.hax)

            if not worked then
                print(err)
            end
        end
    end, 'hax loader', FCVAR_CHEAT)
end

function _G.hax()
    for i=0,9 do
        if PlayerResource:GetTeam(i) == DOTA_TEAM_BADGUYS then
            local gold = PlayerResource:GetGold(i)
            PlayerResource:SetGold(i, 0, false)
            PlayerResource:SetGold(i, gold+10000, true)

            local hero = PlayerResource:GetSelectedHeroEntity(i)
            if hero then
                hero:AddExperience(1000, 1000, false, false)

                local abs = {
                    faceless_void_backtrack = 4,
                    dragon_knight_dragon_blood = 4,
                    drow_ranger_marksmanship = 3,
                    spirit_breaker_empowering_haste = 4,
                    elder_titan_natural_order = 4,
                    skeleton_king_vampiric_aura = 4,
                    vengefulspirit_command_aura = 4,
                    abyssal_underlord_atrophy_aura = 4
                }

                for skill, level in pairs(abs) do
                    if not hero:HasAbility(skill) then
                        hero:AddAbility(skill)

                        local ab = hero:FindAbilityByName(skill)
                        if ab then
                            ab:SetLevel(level)
                        end
                    end

                end
            end

        end
    end
end