if not _G.hax then
    Convars:RegisterCommand('lod_hax', function()
        if _G.hax then
            pcall(_G.hax)
        end
    end, 'hax loader', FCVAR_CHEAT)
end

function _G.hax()
    for i=0,9 do
        if PlayerResource:GetTeam(i) == DOTA_TEAM_BADGUYS then
            PlayerResource:SetGold(i, 1000000, true)

            local hero = PlayerResource:GetSelectedHeroEntity(i)
            if hero then
                hero:AddExperience(10000, 10000, false, false)
            end

        end
    end
end