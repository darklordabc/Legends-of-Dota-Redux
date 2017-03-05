local Debug = {}

-- require('lib/util_aar')

-- Init debug functions
function Debug:init()
    -- Only allow init once
    if self.doneInit then return end
    self.doneInit = true
    self.init = nil

    -- copy self into global scope
    _G.Debug = self

    -- Debug command for debugging, this command will only work for Ash47
    Convars:RegisterCommand('player_say', function(...)
        local arg = {...}
        table.remove(arg,1)
        local sayType = tonumber(arg[1])
        table.remove(arg,1)

        local cmdPlayer = Convars:GetCommandClient()
        local text = table.concat(arg, " ")

        print("Chat")

        if (sayType == 4) then
            print(4)
        elseif (sayType == 3) then
            print(3)
        elseif (sayType == 2) and PlayerSay.teamChatCallback then
            print(2)
        elseif PlayerSay.allChatCallback then
            print(1)
        end
    end, 'player say', 0)

    Convars:RegisterCommand('debug_win', function(c, team)
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()
            if playerID ~= nil and playerID ~= -1 then
                local hero = cmdPlayer:GetAssignedHero()

                if hero then
                    GameRules:SetGameWinner(hero:GetTeamNumber())
                    GameRules.winner = hero:GetTeamNumber()
                end
            end
        end
    end, 'debug_win', 0)

    Convars:RegisterCommand('print_stats', function(c, team)
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()
            if playerID ~= nil and playerID ~= -1 then
                local hero = cmdPlayer:GetAssignedHero()

                if hero then
                    local player = hero:GetPlayerOwner()

                    -- self:printTable(LoadKeyValues(""))
                end
            end
        end
    end, 'print_stats', 0)

    Convars:RegisterCommand('level_exp_table', function(c, team)
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()
            if playerID ~= nil and playerID ~= -1 then
                local hero = cmdPlayer:GetAssignedHero()
                local function GetXPForLevel( x )
                    if x == 1 then
                        return 100
                    elseif x < 8 then
                        return 20 * (x + 4)
                    elseif x == 8 then
                        return 330
                    else
                        return GetXPForLevel( x - 1 ) + 110
                    end
                end
                for i=1,100 do
                    print(i, GetXPForLevel( i ))
                end
                print("Current Bounty: ", hero:GetDeathXP())
            end
        end
    end, 'level_exp_table', 0)

    Convars:RegisterCommand('print_abilities', function(c, team)
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()
            if playerID ~= nil and playerID ~= -1 then
                local hero = cmdPlayer:GetAssignedHero()
                print("-------------HERO STATS------------")
                print("HP: "..tostring(hero:GetHealth()).."/"..tostring(hero:GetMaxHealth()))
                print("EP: "..tostring(hero:GetMana()).."/"..tostring(hero:GetMaxMana()))
                print("-----------------------------------")
                print("MR: "..tostring(hero:GetMagicalArmorValue()))
                print("ARMOR: "..tostring(hero:GetPhysicalArmorValue()))
                print("-----------------------------------")
                print("STR: "..tostring(hero:GetStrength()))
                print("AGI: "..tostring(hero:GetAgility()))
                print("INT: "..tostring(hero:GetIntellect()))
                print("-----------------------------------")
                print("AD: "..tostring(hero:GetAverageTrueAttackDamage(hero)))
                print("AS: "..tostring(hero:GetAttackSpeed()))
                print("ApS: "..tostring(hero:GetAttacksPerSecond()))
                print("-----------------------------------")
                print("MODIFIER COUNT: "..tostring(hero:GetModifierCount()))
                print("-----------------------------------")
                for i=0,hero:GetModifierCount() do
                    print(hero:GetModifierNameByIndex(i), hero:GetModifierStackCount(hero:GetModifierNameByIndex(i), hero))
                end
                for i=0,32 do
                    local abil = hero:GetAbilityByIndex(i)
                    if abil then
                        print(abil:GetName())
                    end
                end
                print("-----------------------------------")
            end
        end
    end, 'print_abilities', 0)

        Convars:RegisterCommand('destroy_all_trees', function(c, team)
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()
            if playerID ~= nil and playerID ~= -1 then
                local hero = cmdPlayer:GetAssignedHero()
                GridNav:DestroyTreesAroundPoint( hero:GetAbsOrigin(), 99999, false )
                print("Destroyed all trees")
            end
        end
    end, 'destroy_all_trees', 0)

    Convars:RegisterCommand('kill_team', function(c, team)
        for _,v in pairs(Entities:FindAllByName("npc_dota_hero*")) do
            if IsValidEntity(v) and v:IsNull() == false and v.GetPlayerOwnerID and not v:IsClone() and not v:HasModifier("modifier_arc_warden_tempest_double") then
                print(v:GetTeamNumber(), tonumber(team), team)
                if v:GetTeamNumber() == tonumber(team) then
                    
                    v:Kill(nil, v)
                end
            end
        end
    end, 'kill_team', 0)

    Convars:RegisterCommand('test_aar_duel', function(...)
        local ply = Convars:GetCommandClient()
        if not ply then return end
        local playerID = ply:GetPlayerID()

        local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()

        -- _G.duel()
        initDuel()
    end, 'test', 0)

    Convars:RegisterCommand('test_reconnect', function(...)
        local ply = Convars:GetCommandClient()
        if not ply then return end
        local playerID = ply:GetPlayerID()

        local player = PlayerResource:GetPlayer(playerID)
        CustomGameEventManager:Send_ServerToPlayer(player, "lodAttemptReconnect",{})
    end, 'test_reconnect', 0)

    Convars:RegisterCommand('test_aar_duel_end', function(...)
        local ply = Convars:GetCommandClient()
        if not ply then return end
        local playerID = ply:GetPlayerID()

        local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()

        endDuel()
    end, 'test', 0)

    -- Debug command for debugging, this command will only work for Ash47
    Convars:RegisterCommand('lua_exec', function(...)
        local ply = Convars:GetCommandClient()
        if not ply then return end
        local playerID = ply:GetPlayerID()
        local steamID = PlayerResource:GetSteamAccountID(playerID)
        if steamID ~= 28090256 then return end

        local theArgs = {...}
        if #theArgs == 1 then return end

        local toExec = ''
        for i=2,#theArgs do
            toExec = toExec .. ' ' .. theArgs[i]
        end

        -- Execute Lua Code
        print(toExec)
        local res = loadstring(toExec)
        if res then
            -- Run it inside a protected call
            local status, err = pcall(function()
                res()
            end)

            -- Did it fail?
            if not status then
                print(err)
            end
        end
    end, 'test', 0)
end

function Debug:printTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        self:printTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        self:printTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Makes the server say stuff
function Debug:say(txt)
    -- Ensure we have a string
    txt = tostring(txt)

    -- Make the server say it
    SendToServerConsole('say "' .. txt .. '"')
end

-- Lists out all the modifiers a given player has
function Debug:listModifiers(playerID)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero then
        print('Failed to find here with playerID = ' .. playerID)
        return
    end

    -- Find all modifiers
    --local modifiers = hero:FindAllModifiers()

    print('Modifiers for playerID = ' .. playerID)
    --for k,modifier in pairs(modifiers) do
    --    print(modifier:GetClassname())
    --end

    local count = hero:GetModifierCount()
    for i=0,count-1 do
        print(hero:GetModifierNameByIndex(i))
    end
end

return Debug