function StoreTalents()
    -- Store all the talents and arrange them with their level
    TalentList = {}
    for i=1,4 do
        TalentList[i] = {}
        TalentList["count"..i] = 1
        TalentList["basic"..i] = {}
        TalentList["basicCount"..i] = 1
    end

    -- Get and order default talents
    local allHeroes = LoadKeyValues('scripts/npc/npc_heroes.txt')
    local abilitiesOverride = LoadKeyValues('scripts/npc/npc_abilities_override.txt')
    for hero,params in pairs(allHeroes) do
        -- Find first talent
        if type(params) == "table" then
            local talentIndex
            for i=1,26 do
                if params["Ability"..i] and string.find(params["Ability"..i],"special_bonus_") then
                    talentIndex = i
                    break
                end
            end
            if talentIndex then
                for i =1,8 do
                    local n = talentIndex + i -1
                    local t = math.ceil(i/2)
                    if params["Ability"..n] then
                        local talentName = abilitiesOverride[params["Ability"..n]]
                        if talentName and talentName.TalentRequiredAbility then
                            TalentList[t][params["Ability"..n]] = talentName.TalentRequiredAbility
                            TalentList["count"..t] = TalentList["count"..t] + 1
                        elseif string.find(params["Ability"..n],"special_bonus_") and not string.find(params["Ability"..n],"special_bonus_unique") then
                            TalentList["basic"..t][params["Ability"..n]] = hero
                            TalentList["basicCount"..t] = TalentList["basicCount"..t] + 1
                        end
                    end
                end
            end
        end
    end

    -- Get all custom talents
    local customAbilities = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
    for ability,params in pairs(allHeroes) do
        if type(params) == "table" then
            if params.TalentRank then
                TalentList[params.TalentRank][ability] = params.TalentRequiredAbility
            end
        end
    end
end

function AddTalents(hero,build)
    -- Get the viable talents

    hero.heroTalentList = hero.heroTalentList or {}
    local function FindAbilityTalentFromList(nTalentRank)
        local ViableTalents = hero.ViableTalents
        local talent
        local rnd = math.random(1,ViableTalents["count"..nTalentRank])
        local c = 1
        for k,v in pairs(ViableTalents[nTalentRank]) do
            if c == rnd then
                talent = k
                table.insert(hero.heroTalentList,k)
                TalentList["count"..nTalentRank] = TalentList["count"..nTalentRank] - 1
                break
            end
            c = c + 1
        end
        if hero.ViableTalents[nTalentRank][talent] then
            hero.ViableTalents[nTalentRank][talent] = nil
        end
    end

    local function FindNormalTalentFromList(nTalentRank)
        local m = 0
        for k,v in pairs(TalentList["basic"..nTalentRank]) do
            m = m +1
        end
        local rnd = math.random(1,m)
        local c = 1

        for k,v in pairs(TalentList["basic"..nTalentRank]) do
            if v == hero:GetUnitName() then
                local hasTalent = false
                for K,V in pairs(hero.heroTalentList) do
                    if V==k then
                        hasTalent = true
                    end
                end
                if not hasTalent then
                    table.insert(hero.heroTalentList,k)
                end
                return
            end
        end

        for k,v in pairs(TalentList["basic"..nTalentRank]) do
            if c == rnd then
                table.insert(hero.heroTalentList,k)
                --TalentList["basicCount"..i] = TalentList["basicCount"..i] - 1
                break
            end
            c = c +1
        end
    end

    local ViableTalents = {}
    for i =1,4 do
        ViableTalents[i] = {}
        ViableTalents["count"..i] = 0
        for k,v in pairs(TalentList[i]) do
            local bool = false
            for K,V in pairs(build) do
                if K ~= "hero" and v == V then
                    ViableTalents[i][k] = k
                    ViableTalents["count"..i] = ViableTalents["count"..i] + 1
                    break
                end
            end
        end
    end

    hero.ViableTalents = ViableTalents
    for i=1,4 do
        if hero.ViableTalents["count"..i] >= 2 then
            FindAbilityTalentFromList(i)
            FindAbilityTalentFromList(i)
        elseif hero.ViableTalents["count"..i] == 1 then
            FindAbilityTalentFromList(i)
            FindNormalTalentFromList(i)
        else
            FindNormalTalentFromList(i)
            FindNormalTalentFromList(i)
        end
    end
    for k,v in pairs(hero.heroTalentList) do
        hero:AddAbility(v)
    end

end
