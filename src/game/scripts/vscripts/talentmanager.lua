function StoreTalents()
    -- Store all the talents and arrange them with their level
    TalentList = {}
    for i=1,4 do
        TalentList[i] = {}
        TalentList["count"..i] = 1
        TalentList["basic"..i] = {}
        TalentList["basicCount"..i] = 1
    end

    PlayerTalents ={}
    for i=0,20 do
        PlayerTalents[i] = {}
        PlayerTalents[i]["TalentList"] = {}
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
                        if talentName and talentName.TalentRequiredAbility and not TalentList[t][params["Ability"..n]] then
                            TalentList[t][params["Ability"..n]] = talentName.TalentRequiredAbility
                            TalentList["count"..t] = TalentList["count"..t] + 1
                        elseif string.find(params["Ability"..n],"special_bonus_") and not string.find(params["Ability"..n],"special_bonus_unique") and not TalentList["basic"..t][params["Ability"..n]] then
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
    for ability,params in pairs(customAbilities) do
        if type(params) == "table" then
            if params.TalentRank then
                if params.TalentRequiredAbility and not TalentList[params.TalentRank][ability] then
                    TalentList[params.TalentRank][ability] = params.TalentRequiredAbility
                    TalentList["count"..params.TalentRank] = TalentList["count"..params.TalentRank] + 1
                else
                    if TalentList["basic"..params.TalentRank][ability] then
                        TalentList["basic"..params.TalentRank][ability] = hero
                        TalentList["basicCount"..params.TalentRank] = TalentList["basicCount"..params.TalentRank] + 1
                    end
                end
            end
        end
    end
end

function AddTalents(hero,build)
    -- Get the viable talents

    hero.heroTalentList = hero.heroTalentList or {}

    local function HasTalent(talent)
        for _,tal in pairs(hero.heroTalentList) do
            if tal == talent then
                return true
            end
        end
        return false
    end

    local function FindAbilityTalentFromList(nTalentRank)
        local ViableTalents = hero.ViableTalents
        local talent
        local rnd = RandomInt(1,ViableTalents["count"..nTalentRank])
        local c = 1
        for k,v in pairs(ViableTalents[nTalentRank]) do
            if c == rnd then
                talent = k
                --table.insert(hero.heroTalentList,k)
                --TalentList["count"..nTalentRank] = TalentList["count"..nTalentRank] - 1
                --ViableTalents[nTalentRank][k] = nil
                if not HasTalent(k) then
                    return k
                end
            end
            c = c + 1
        end
        if hero.ViableTalents[nTalentRank][talent] then
            hero.ViableTalents[nTalentRank][talent] = nil
        end
    end

    local function FindHeroTalentFromList(nTalentRank)
        

        for k,v in pairs(TalentList["basic"..nTalentRank]) do
            if v == hero:GetUnitName() then
                local hasTalent = false
                for K,V in pairs(hero.heroTalentList) do
                    if V==k then
                        print("hasTalent",k)
                        hasTalent = true
                    end
                end
                if k and not hasTalent then
                    --table.insert(hero.heroTalentList,k)
                    if not HasTalent(k) then
                        return k
                    end
                end
            end
        end
        --print("NOT RETURNING HERO")
    end

    

    local function FindNormalTalentFromList(nTalentRank,otherTalent)
        local m = TalentList["basicCount"..nTalentRank]
        local rnd = RandomInt(1,m)
        
        while true do
            local c = 1
            local rnd = RandomInt(1,m)
            for k,v in pairs(TalentList["basic"..nTalentRank]) do
                --print(k,c== rnd)
                if c == rnd then
                    if not otherTalent or k ~= otherTalent:gsub('%d','') then
                        if not string.find(k,"DOTA_Tooltip_ability_special_bonus_cooldown_reduction") then
                            if not string.find(k,"special_bonus_attack_range") or hero:IsRangedAttacker() then
                                if not string.find(k, "special_bonus_cleave") or not hero:IsRangedAttacker() then
                                    if not HasTalent(k) then
                                        return k
                                    end
                                end
                            end
                        end
                    end
                end
                c = c +1
            end
        end
        --print("NOT RETURNING NORMAL, THIS IS A PROBLEM")
    end

    hero.ViableTalents = GetViableTalents(build)
    local PID = hero:GetPlayerOwnerID()
    
    for i=1,4 do
        local a = PlayerTalents[PID]["TalentList"][(i*2)-1]
        local b = PlayerTalents[PID]["TalentList"][(i*2)]
        --print(hero:GetUnitName())
        if hero.ViableTalents["count"..i] >= 2 then
            local a = a or FindAbilityTalentFromList(i)
            local b = b or FindAbilityTalentFromList(i)
            local j = 0
            while j<100 and (a==b or not b) do
                b = FindAbilityTalentFromList(i)
                j = j +1
            end
            if not a then a =FindNormalTalentFromList(i) end
            if not b then b =FindNormalTalentFromList(i) end
            --print("Normal0",a,b)
            table.insert(hero.heroTalentList,a)
            table.insert(hero.heroTalentList,b)
        elseif hero.ViableTalents["count"..i] == 1 then
            local a = a or FindAbilityTalentFromList(i)
            local b = b or FindHeroTalentFromList(i)
            
            if not a then a =FindNormalTalentFromList(i) end
            if not b then b =FindNormalTalentFromList(i) end
            --print("Normal1",a,b)
            table.insert(hero.heroTalentList,a)
            table.insert(hero.heroTalentList,b)

        else
            local a = a or FindHeroTalentFromList(i)
            local b = b or FindHeroTalentFromList(i,a)
            local j = 0
            while j<100 and (a == b or not b) do
                b = FindAbilityTalentFromList(i,a)
                j = j +1
            end
            if not a then a =FindNormalTalentFromList(i) end
            if not b then b =FindNormalTalentFromList(i) end
            --print("Normal2",a,b)
            table.insert(hero.heroTalentList,a)
            table.insert(hero.heroTalentList,b)
        end
    end
    for k,v in pairs(hero.heroTalentList) do

        local a = hero:AddAbility(v)
        if a then
            --print(v)
        end
    end
end

function GetViableTalents(build)
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
    return ViableTalents
end

function SendTalentsToClient(PID,build)
    local talents = GetViableTalents(build)
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(PID), "send_viable_talents", talents )
end

function RegisterTalents(PID,data)
    for i=0,7 do
        if data[i] then
            PlayerTalents[PID][i+1] = data[i]
        else
            PlayerTalents[PID][i+1] = nil
        end
    end
end


CustomGameEventManager:RegisterListener( "request_available_talents", SendTalentsToClient ) 
CustomGameEventManager:RegisterListener( "send_picked_talents", RegisterTalents ) 

