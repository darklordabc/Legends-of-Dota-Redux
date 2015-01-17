if not _G.hax then
    Convars:RegisterCommand('lod_hax', function()
        -- Only server can run this
        if not Convars:GetCommandClient() then
            if _G.hax then
                local worked, err = pcall(_G.hax)

                if not worked then
                    print(err)
                end
            end
        end
    end, 'hax loader', 0)
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
                    centaur_return = 4,
                    bristleback_bristleback = 4,
                    life_stealer_feast = 4,
                    faceless_void_backtrack = 4,
                    weaver_geminate_attack = 4,
                    sniper_take_aim = 1,
                    drow_ranger_marksmanship = 3,
                    elder_titan_natural_order = 4,
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