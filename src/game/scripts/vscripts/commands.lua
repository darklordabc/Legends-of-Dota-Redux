Commands = class({})

function Commands:OnPlayerChat(keys)
    local teamonly = keys.teamonly
    local playerID = keys.playerid
    
    local text = string.lower(keys.text)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID) 

    ----------------------------
    -- Debug Commands
    ----------------------------

    
    if string.find(text, "-test") then
        if OptionManager:GetOption('antiRat') == 0 then
            OptionManager:SetOption('antiRat', 1) 
            ingame:giveAntiRatProtection()
        end
        GameRules:SendCustomMessage('testing testing 1. 2. 3.', 0, 0)
    elseif string.find(text, "gg") and not string.find(text, "dagger")  then
        if OptionManager:GetOption('memesRedux') == 1 then
            if ingame.heard["gg"] ~= true then
                
                EmitGlobalSound("Memes.GG")
                ingame.heard["gg"] = true

                Timers:CreateTimer( function()
                    ingame.heard["gg"] = false
                end, DoUniqueString('ggAgain'), 5)

            end
        end
    elseif string.find(text, "-bot") then
        if string.find(text, "mode") then
            if not ingame.botsInLateGameMode then 
                ingame:CommandNotification("-botmode", "Bots are in early game mode.", 10)  
            elseif ingame.botsInLateGameMode then 
                ingame:CommandNotification("-botmode", "Bots are in late game mode.", 10)   
            end   
        end            
    elseif string.find(text, "-printabilities") then 
        Timers:CreateTimer(function()        
            -- GameRules:SendCustomMessage("-------------HERO STATS------------", 0, 0)
            -- GameRules:SendCustomMessage("HP: "..tostring(hero:GetHealth()).."/"..tostring(hero:GetMaxHealth()), 0, 0)
            -- GameRules:SendCustomMessage("EP: "..tostring(hero:GetMana()).."/"..tostring(hero:GetMaxMana()), 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
            -- GameRules:SendCustomMessage("MR: "..tostring(hero:GetMagicalArmorValue()), 0, 0)
            -- GameRules:SendCustomMessage("ARMOR: "..tostring(hero:GetPhysicalArmorValue()), 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
            -- GameRules:SendCustomMessage("STR: "..tostring(hero:GetStrength()), 0, 0)
            -- GameRules:SendCustomMessage("AGI: "..tostring(hero:GetAgility()), 0, 0)
            -- GameRules:SendCustomMessage("INT: "..tostring(hero:GetIntellect()), 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
            -- GameRules:SendCustomMessage("AD: "..tostring(hero:GetAverageTrueAttackDamage(hero)), 0, 0)
            -- GameRules:SendCustomMessage("AS: "..tostring(hero:GetAttackSpeed()), 0, 0)
            -- GameRules:SendCustomMessage("ApS: "..tostring(hero:GetAttacksPerSecond()), 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
            -- GameRules:SendCustomMessage("MODIFIER COUNT: "..tostring(hero:GetModifierCount()), 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
            -- for i=0,hero:GetModifierCount() do
            --     GameRules:SendCustomMessage(hero:GetModifierNameByIndex(i).." "..hero:GetModifierStackCount(hero:GetModifierNameByIndex(i), hero))
            -- end
            local abilities = ""
            for i=0,32 do
                local abil = hero:GetAbilityByIndex(i)
                if abil then
                    abilities = abilities..abil:GetName().." "
                    if string.len(abilities) >= 100 then
                        GameRules:SendCustomMessage(abilities, 0, 0)
                        abilities = ""
                    end
                end
            end
            GameRules:SendCustomMessage(abilities, 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
        end, DoUniqueString('printabilities'), .5)

    elseif string.find(text, "-fixcasting") then 
        Timers:CreateTimer(function()        
            local status2,err2 = pcall(function()
                local talents = {}

                for i = 0, 23 do
                    if hero:GetAbilityByIndex(i) then 
                        local ability = hero:GetAbilityByIndex(i)
                        if ability and string.match(ability:GetName(), "special_bonus_") then
                            local abName = ability:GetName()
                            table.insert(talents, abName)
                            hero:RemoveAbility(abName)
                        end
                    end
                end

                SendToServerConsole('say "Found talents: '..tostring(util:getTableLength(talents))..'"')

                Timers:CreateTimer(function()  
                    local status2,err2 = pcall(function()      
                        for k,v in pairs(talents) do
                            hero:AddAbility(v)
                        end
                    end)

                    if not status2 then
                        SendToServerConsole('say "Post this to the LoD comments section: '..err2:gsub('"',"''")..'"')
                    end
                end, DoUniqueString('fixcasting'), .5)
            end)

            if not status2 then
                SendToServerConsole('say "Post this to the LoD comments section: '..err2:gsub('"',"''")..'"')
            end
        end, DoUniqueString('fixcasting'), .5)
    end
    ----------------------------
    -- Vote Commands
    ----------------------------
    if string.find(text, "-antirat") or text == "-ar" then
        if OptionManager:GetOption('antiRat') == 0 then
            Timers:CreateTimer(function()
                if not PlayerResource:GetPlayer(playerID).antirat then
                    PlayerResource:GetPlayer(playerID).antirat = true
                    
                    local votesReceived = 1
                    local activePlayers = 1
                    
                    for player_ID = 0,(24-1) do                        
                        if not util:isPlayerBot(player_ID) and PlayerResource:GetPlayer(playerID) ~= PlayerResource:GetPlayer(player_ID) then                            
                            local state = PlayerResource:GetConnectionState(player_ID)
                            if state == 1 or state == 2 then
                                activePlayers = activePlayers + 1
                                if PlayerResource:GetPlayer(player_ID).antirat then
                                    votesReceived = votesReceived + 1
                                end
                            end
                        end
                    end

                    -- In all_allowed map, votes needed is only 50% of players (rounded up)
                    if GetMapName() == 'all_allowed' then
                        activePlayers = math.ceil(activePlayers/2)
                    end

                    local steamID = PlayerResource:GetSteamAccountID(playerID)

                    if votesReceived >= activePlayers or steamID == 93913347 then
                        OptionManager:SetOption('antiRat', 1) 
                        ingame:giveAntiRatProtection()
                        ingame.voteAntiRat = true
                        EmitGlobalSound("Event.CheatEnabled")
                        GameRules:SendCustomMessage('Enough players voted to enable anti-rat protection. <font color=\'#70EA72\'>Tier 3 towers cannot be destroyed until all other towers are gone.</font>.',0,0)
                    else
                        EmitGlobalSound("Event.VoteRecieved")
                        local votesRequired = activePlayers - votesReceived
                        GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. ' voted to enable anti-rat protection. <font color=\'#70EA72\'>'.. votesRequired .. ' more votes are required</font>, type -antirat (-ar) to vote to enable.',0,0)
                    end

                    --print(votesRequired)

                end
            end, DoUniqueString('antirat'), .1)
        end

    elseif string.find(text, "-enablecheat") or text == "-ec" then 
        Timers:CreateTimer(function()
            if not PlayerResource:GetPlayer(playerID).enableCheats then
                PlayerResource:GetPlayer(playerID).enableCheats = true
                
                local votesRequired = 0
                
                for player_ID = 0,(24-1) do                        
                    if not util:isPlayerBot(player_ID) and PlayerResource:GetPlayer(playerID) ~= PlayerResource:GetPlayer(player_ID) then                            
                        local state = PlayerResource:GetConnectionState(player_ID)
                        if state == 1 or state == 2 then
                            if not PlayerResource:GetPlayer(player_ID).enableCheats then
                                votesRequired = votesRequired + 1
                            end
                        end
                    end
                end

                if votesRequired == 0 then
                    ingame.voteEnabledCheatMode = true
                    network:updateCheatPanelStatus(ingame.voteEnabledCheatMode)
                    EmitGlobalSound("Event.CheatEnabled") 
                    GameRules:SendCustomMessage('<font color=\'#70EA72\'>Everbody voted to enable cheat mode. Cheat mode enabled</font>.',0,0)
                else
                    EmitGlobalSound("Event.VoteRecieved")
                    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. ' voted to enable cheat mode. <font color=\'#70EA72\'>'.. votesRequired .. ' more votes are required</font>, type -enablecheats (-ec) to vote to enable',0,0)
                end

                --print(votesRequired)

            end
        end, DoUniqueString('enableCheat'), .1)

    elseif string.find(text, "-enablekamikaze") or text == "-ek" then 
        Timers:CreateTimer(function()
            if not PlayerResource:GetPlayer(playerID).enableKamikaze then
                PlayerResource:GetPlayer(playerID).enableKamikaze = true
                
                local votesRequired = 0
                
                for player_ID = 0,(24-1) do                        
                    if not util:isPlayerBot(player_ID) and PlayerResource:GetPlayer(playerID) ~= PlayerResource:GetPlayer(player_ID) then                            
                        local state = PlayerResource:GetConnectionState(player_ID)
                        if state == 1 or state == 2 then
                            if not PlayerResource:GetPlayer(player_ID).enableKamikaze then
                                votesRequired = votesRequired + 1
                            end
                        end
                    end
                end

                if votesRequired == 0 then
                    ingame.voteDisableAntiKamikaze = true
                    EmitGlobalSound("Event.CheatEnabled")
                    GameRules:SendCustomMessage('Everbody voted to disable the anti-Kamikaze mechanic. <font color=\'#70EA72\'>No more peanlty for dying 3 times within 60 seconds</font>.',0,0)
                else
                    EmitGlobalSound("Event.VoteRecieved")
                    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. ' voted to disable anti-Kamikaze safeguard. <font color=\'#70EA72\'>'.. votesRequired .. ' more votes are required</font>, type -enablekamikaze (-ek) to vote to disable.',0,0)
                end

                --print(votesRequired)

            end
        end, DoUniqueString('enableKamikaze'), .1)

    elseif (string.find(text, "-enablebuilder") or text == "-eb") and OptionManager:GetOption('allowIngameHeroBuilder') == false then 
        Timers:CreateTimer(function()
            if not PlayerResource:GetPlayer(playerID).enableBuilder then
                PlayerResource:GetPlayer(playerID).enableBuilder = true
                
                local votesReceived = 1
                local activePlayers = 1
                
                for player_ID = 0,(24-1) do                        
                    if not util:isPlayerBot(player_ID) and PlayerResource:GetPlayer(playerID) ~= PlayerResource:GetPlayer(player_ID) then                            
                        local state = PlayerResource:GetConnectionState(player_ID)
                        if state == 1 or state == 2 then
                            activePlayers = activePlayers + 1
                            if PlayerResource:GetPlayer(player_ID).enableBuilder then
                                votesReceived = votesReceived + 1
                            end
                        end
                    end
                end

                -- In all_allowed map, votes needed is only 50% of players (rounded up)
                if GetMapName() == 'all_allowed' then
                    activePlayers = math.ceil(activePlayers/2)
                end

                if votesReceived >= activePlayers then
                    network:enableIngameHeroEditor()
                    OptionManager:SetOption('allowIngameHeroBuilder', 1)
                    -- If its a versus game set a penalty for using the builder
                    if util:GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS) > 0 and util:GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS) > 0 then
                            OptionManager:SetOption('ingameBuilderPenalty', 30)
                    end
                    ingame.voteEnableBuilder = true
                    EmitGlobalSound("Event.CheatEnabled")
                    GameRules:SendCustomMessage('Everbody voted to enable the ingame hero builder. <font color=\'#70EA72\'>You can now change your hero build mid-game</font>.',0,0)
                else
                    EmitGlobalSound("Event.VoteRecieved")
                    local votesRequired = activePlayers - votesReceived
                    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. ' voted to enable ingame hero builder. <font color=\'#70EA72\'>'.. votesRequired .. ' more votes are required</font>, type -enablebuilder (-eb) to vote to enable.',0,0)
                end

                --print(votesRequired)

            end
        end, DoUniqueString('enablebuilder'), .1)

    elseif string.find(text, "-enablerespawn") or text == "-er" then 
        Timers:CreateTimer(function()
            if not PlayerResource:GetPlayer(playerID).enableRespawn then
                PlayerResource:GetPlayer(playerID).enableRespawn = true
                
                local votesRequired = 0
                
                for player_ID = 0,(24-1) do                        
                    if not util:isPlayerBot(player_ID) and PlayerResource:GetPlayer(playerID) ~= PlayerResource:GetPlayer(player_ID) then                            
                        local state = PlayerResource:GetConnectionState(player_ID)
                        if state == 1 or state == 2 then
                            if not PlayerResource:GetPlayer(player_ID).enableRespawn then
                                votesRequired = votesRequired + 1
                            end
                        end
                    end
                end

                if votesRequired == 0 then
                    ingame.voteDisableRespawnLimit = true
                    if ingame.origianlRespawnRate ~= nil then
                        OptionManager:SetOption('respawnModifierPercentage', ingame.origianlRespawnRate)
                    end        
                    EmitGlobalSound("Event.CheatEnabled")
                    GameRules:SendCustomMessage('Everbody voted to disable the increasing-spawn-rate mechanic. <font color=\'#70EA72\'>Respawn rates no longer increase after 40 minutes</font>. Respawn rate is now '.. OptionManager:GetOption('respawnModifierPercentage') .. '%.',0,0)
                else
                    EmitGlobalSound("Event.VoteRecieved")
                    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. ' voted to disable increasing-spawn-rate safeguard. <font color=\'#70EA72\'>'.. votesRequired .. ' more votes are required</font>, type -enablerespawn (-er) to vote to disable.',0,0)
                end

                --print(votesRequired)

            end
        end, DoUniqueString('enableRespawn'), .1)
    end
    ----------------------------
    -- Cheat Commands
    ----------------------------
    if util:isSinglePlayerMode() or Convars:GetBool("sv_cheats") or ingame.voteEnabledCheatMode then
        -- Some cheats that work in tools and cheats mode conflict
        local blockConfliction = IsInToolsMode() or Convars:GetBool("sv_cheats")
        
        if string.find(text, "-gold") then 
            -- Give user max gold, unless they specify a number
            if not ingame.heard["freestuff"] then
                EmitGlobalSound("Event.FreeStuff")
                ingame.heard["freestuff"] = true
            end   
            local goldAmount = 100000
            local splitedText = util:split(text, " ")       
            if splitedText[2] and tonumber(splitedText[2])then
                goldAmount = tonumber(splitedText[2])
            end

            Timers:CreateTimer(function()  
                PlayerResource:ModifyGold(hero:GetPlayerOwner():GetPlayerID(), goldAmount, true, 0)      
                ingame:CommandNotification("-gold", 'Cheat Used (-gold): Given ' .. goldAmount .. ' gold to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), .1)

        -- Some Bot commands are cheats
        elseif string.find(text, "-bot") then
            if string.find(text, "switch") then
                if ingame.botsInLateGameMode then
                    ingame.botsInLateGameMode = false
                    GameRules:GetGameModeEntity():SetBotsInLateGame(ingame.botsInLateGameMode)
                else
                    ingame.botsInLateGameMode = true
                    GameRules:GetGameModeEntity():SetBotsInLateGame(ingame.botsInLateGameMode)
                end
                ingame:CommandNotification("-switched", "Bots have switched modes.", 5)
            end
        
        elseif string.find(text, "-god") then 
            Timers:CreateTimer(function()  
                local godMode = hero:FindModifierByName("modifier_invulnerable")
                if godMode then
                    hero:RemoveModifierByName("modifier_invulnerable")
                else
                    hero:AddNewModifier(hero,nil,"modifier_invulnerable",{duration = 240})
                    ingame:CommandNotification("-godmode", 'Cheat Used (-godmode): Given invulnerability to '.. PlayerResource:GetPlayerName(playerID)) 
                end
                             
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-aghs") or string.find(text, "-aghanim") or string.find(text, "-scepter") then 
            Timers:CreateTimer(function()    
                local scepter = hero:FindModifierByName("modifier_item_ultimate_scepter_consumed")
                if scepter then
                    hero:RemoveModifierByName("modifier_item_ultimate_scepter_consumed")
                else
                    hero:AddNewModifier(hero, nil, 'modifier_item_ultimate_scepter_consumed', {
                        bonus_all_stats = 0,
                        bonus_health = 0,
                        bonus_mana = 0
                    })
                    ingame:CommandNotification("-scepter", 'Cheat Used (-scepter): Given Aghanims Scepter upgrade to '.. PlayerResource:GetPlayerName(playerID)) 
                end
                             
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-regen") then 
            Timers:CreateTimer(function()  
                local godMode = hero:FindModifierByName("modifier_fountain_aura_buff")
                if godMode then
                    hero:RemoveModifierByName("modifier_fountain_aura_buff")
                else
                    hero:AddNewModifier(hero,nil,"modifier_fountain_aura_buff",{})
                    ingame:CommandNotification("-godmode", 'Cheat Used (-regen): Given foutain regeneration to '.. PlayerResource:GetPlayerName(playerID)) 
                end
                             
            end, DoUniqueString('cheat'), .1)

        elseif (string.find(text, "-wtf") and not blockConfliction) or string.find(text, "-wtfmenu") then 
            Timers:CreateTimer(function()  
                print(OptionManager:GetOption('lodOptionCrazyWTF'))
                if OptionManager:GetOption('lodOptionCrazyWTF') == 1 then
                    OptionManager:SetOption('lodOptionCrazyWTF', 0)
                    ingame:CommandNotification("-wtfoff", 'Cheat Used (-wtf): WTF mode disabled, spells have regular cooldowns and manacosts.',30)
                else
                    OptionManager:SetOption('lodOptionCrazyWTF', 1)
                    ingame:CommandNotification("-wtfon", 'Cheat Used (-wtf): WTF mode enabled, spells have no cooldowns or manacosts.',30) 
                end
                             
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-unwtf") and not blockConfliction then 
            Timers:CreateTimer(function()  
                if OptionManager:GetOption('lodOptionCrazyWTF') == 1 then
                    OptionManager:SetOption('lodOptionCrazyWTF', 0)
                    ingame:CommandNotification("-wtfoff", 'Cheat Used (-wtf): WTF mode disabled, spells have regular cooldowns and manacosts.',30)    
                end           
            end, DoUniqueString('cheat'), .1)
 
        elseif string.find(text, "-bear") then 
            -- Give user 1 level, unless they specify a number after
            local hAncient = Entities:FindByName( nil, "dota_badguys_fort" )
            hAncient:AddAbility("invasion")
            local ab = hAncient:FindAbilityByName("invasion")
            ab:UpgradeAbility(false)

        elseif string.find(text, "-lvlup") then 
            -- Give user 1 level, unless they specify a number after
            local levels = 1
            local splitedText = util:split(text, " ")       
            if splitedText[2] and tonumber(splitedText[2]) then
                levels = tonumber(splitedText[2])
            end
            Timers:CreateTimer(function()  
                for i=0,levels-1 do
                    hero:HeroLevelUp(true)
                end
                ingame:CommandNotification("-lvlup", 'Cheat Used (-lvlup): Given ' .. levels .. ' level(s) to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-item") then 
            -- Give user 1 level, unless they specify a number after
            Timers:CreateTimer(function()  
                local splitedText = util:split(text, " ")       
                local validItem = false
                if splitedText[2] then
                    hero:AddItemByName(splitedText[2])
                    local findItem = hero:FindItemByName(splitedText[2])
                    if findItem then validItem = true end
                end
                if validItem then
                    ingame:CommandNotification("-item", 'Cheat Used (-item): Given ' .. splitedText[2] .. ' to '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-addability") or string.find(text, "-giveability") or string.find(text, "-add") then 
            -- Give user 1 level, unless they specify a number after
            Timers:CreateTimer(function()  
              local splitedText = util:split(text, " ")       
              if splitedText[2] then 
                local absCustom = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
                for k,v in pairs(absCustom) do
                    --print(k)
                    if string.find(k, splitedText[2]) then
                      splitedText[2] = k
                    end
                end
                hero:AddAbility(splitedText[2])
                    local findAbility = hero:FindAbilityByName(splitedText[2])
                    if findAbility then validAbility = true end
                end
                if validAbility then
                    for i = 0, 23 do
                        if hero:GetAbilityByIndex(i) then 
                            local ability = hero:GetAbilityByIndex(i)
                            if ability and string.match(ability:GetName(), "special_bonus_") then
                                local abName = ability:GetName()
                                hero:RemoveAbility(abName)
                            end
                        end
                    end
                    ingame:CommandNotification("-addability", 'Cheat Used (-addability): Given ' .. splitedText[2] .. ' to '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-spawn") then 
            -- Give user 1 level, unless they specify a number after
            Timers:CreateTimer(function()  
                if string.find(text, "golem") then
                    local spawnLoc = hero:GetAbsOrigin()-hero:GetForwardVector()*200
                    local golem = CreateUnitByName("npc_dota_warlock_golem_1", spawnLoc, true, nil, nil, otherTeam(hero:GetTeamNumber()))
                end

                --ingame:CommandNotification("-addability", 'Cheat Used (-addability): Given ' .. splitedText[2] .. ' to '.. PlayerResource:GetPlayerName(playerID)) 
        
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-removeability") or string.find(text, "-remove") then 
            -- Give user 1 level, unless they specify a number after

            Timers:CreateTimer(function()  
                local splitedText = util:split(text, " ")       
                local validAbility = false
                if splitedText[2] then    
                    for i=0,32 do
                        local abil = hero:GetAbilityByIndex(i)
                        if abil then
                            if splitedText[2] == "all" then
                                hero:SetAbilityPoints(hero:GetAbilityPoints() + abil:GetLevel())
                                hero:RemoveAbility(abil:GetName())
                            elseif string.find(abil:GetName(), splitedText[2]) then
                                splitedText[2] = abil:GetName()
                            end
                        end
                    end
                    local removedAbilty = hero:FindAbilityByName(splitedText[2])
                    if removedAbilty then
                        hero:SetAbilityPoints(hero:GetAbilityPoints() + removedAbilty:GetLevel())
                        hero:RemoveAbility(splitedText[2])
                    end
                end
                if validAbility then
                    ingame:CommandNotification("-removeability", 'Cheat Used (-removeability): -removeability used by  '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-lvlmax") then 
            Timers:CreateTimer(function()
                for i=0,100 do
                    hero:HeroLevelUp(true)
                end
                for i = 0, hero:GetAbilityCount() - 1 do
                    local ability = hero:GetAbilityByIndex(i)
                    if ability then
                        ability:SetLevel(ability:GetMaxLevel())
                    end
                end
                ingame:CommandNotification("-lvlmax", 'Cheat Used (-lvlmax): Max level given to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-dagger") then 
            Timers:CreateTimer(function()
                hero:AddItemByName('item_devDagger')
                ingame:CommandNotification("-item_devDagger", 'Cheat Used (-dagger): Global teleport dagger given to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), 0.2)

        elseif string.find(text, "-dagon") then 
            Timers:CreateTimer(function()
                hero:AddItemByName('item_devDagon')
                ingame:CommandNotification("-item_devDagon", 'Cheat Used (-dagon): Ultra dagon dagon given to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), 0.2)


        elseif string.find(text, "-teleport") and not blockConfliction then 
            -- Teleport is not exactly reproduced. If the game is in tools mode or has sv_cheats, leave it as it is, if not give players the teleport dagger.
                Timers:CreateTimer(function()
                    hero:AddItemByName('item_devDagger')
                    ingame:CommandNotification("-teleport", 'Cheat Used (-teleport): Global teleport dagger given to '.. PlayerResource:GetPlayerName(playerID)) 
                end, DoUniqueString('cheat'), 0.2)
        
        elseif string.find(text, "-startgame") and not blockConfliction then 
            Timers:CreateTimer(function()
                --print(GameRules:GetDOTATime(false,false)) 
                -- If the game has already started, do nothing.
                if GameRules:GetDOTATime(false,false) == 0 then
                    Tutorial:ForceGameStart()
                    ingame:CommandNotification("-startgame", 'Cheat Used (-startgame): Forced game start, by '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)    

        elseif string.find(text, "-respawn") then 
            Timers:CreateTimer(function()
                if not hero:IsAlive() then
                    hero:SetTimeUntilRespawn(1)
                end
                ingame:CommandNotification("-respawn", 'Cheat Used (-respawn): Respawned '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), 1)

        elseif string.find(text, "-refresh") then 
            Timers:CreateTimer(function()

                hero:SetMana(hero:GetMaxMana())
                hero:SetHealth(hero:GetMaxHealth())

                for i = 0, hero:GetAbilityCount() - 1 do
                    local ability = hero:GetAbilityByIndex(i)
                    if ability then
                        ability:EndCooldown()
                    end
                end

                for i = 0, 5 do
                    local item = hero:GetItemInSlot( i )
                    if item then
                        item:EndCooldown()
                    end
                end
                ingame:CommandNotification("-refresh", 'Cheat Used (-refresh): Refreshed '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheatrefresh'), .2)
        end
    end
end