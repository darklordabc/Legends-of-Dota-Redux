Commands = Commands or class({})
--local timers = require('easytimers')

function Commands:CheckArgs( args, toCheck )
    for k,v in pairs(args) do
        if string.match(args, v) then
            return true
        end
    end
    return false
end

function Commands:OnPlayerChat(keys)    
    local teamonly = keys.teamonly
    local playerID = keys.playerid
    
    local text = string.lower(keys.text)

    local command
    local arguments = {}

    for k,v in pairs(util:split(text, " ")) do
        if string.match(v, "-") then
            command = v
        elseif string.match(v, "#") then
            playerID = tonumber(string.sub(v, 2)) 
        else
            table.insert(arguments, v)
        end
    end

    if not command or not playerID then
        return
    end

    local ply = PlayerResource:GetPlayer(playerID)

    if not ply then
        return
    end

    local function IsCommand(s)
        local len = string.len(s)
        return string.sub(command, 1, len) == s
    end

    ----------------------------
    -- Vote Commands
    ----------------------------
    if IsCommand("-antirat") or IsCommand("-ar") then
        if OptionManager:GetOption('antiRat') == 0 and not ingame.voteEnabledCheatMode then
            util:CreateVoting("lodVotingAntirat", playerID, 10, OptionManager:GetOption('mapname') == 'all_allowed' and 50 or 100, function()
                OptionManager:SetOption('antiRat', 1) 
                ingame:giveAntiRatProtection()
                ingame.voteAntiRat = true
                EmitGlobalSound("Event.CheatEnabled")
                GameRules:SendCustomMessage('Enough players voted to enable anti-rat protection. <font color=\'#70EA72\'>Tier 3 towers cannot be destroyed until all other towers are gone.</font>.',0,0)
            end)
        elseif OptionManager:GetOption('antiRat') == 1 then
            util:DisplayError(playerID, "#antiRatAlreadyOn")
        end
    elseif IsCommand("-doublecreeps") or IsCommand("-dc") then
       if not ingame.voteDoubleCreeps and OptionManager:GetOption('neutralMultiply') < 2 then
            util:CreateVoting("lodVotingDoubleCreeps", playerID, 10, OptionManager:GetOption('mapname') == 'all_allowed' and 70 or 100, function()
                OptionManager:SetOption('neutralMultiply', 2)
               -- pregame:multiplyNeutrals()
                ingame.voteDoubleCreeps = true
                EmitGlobalSound("Event.CheatEnabled")
                GameRules:SendCustomMessage('Enough players voted to enable double neutrals. <font color=\'#70EA72\'>Neutral creep camps are now doubled</font>.',0,0)
            end)
        elseif OptionManager:GetOption('neutralMultiply') > 1 then
            util:DisplayError(playerID, "#multiplyAlreadyOn")
        end
    elseif IsCommand("-universalshops") or IsCommand("-us") then
       if OptionManager:GetOption('universalShops') == 0 then
            util:CreateVoting("lodVotingUniversalShops", playerID, 10, OptionManager:GetOption('mapname') == 'all_allowed' and 50 or 100, function()
                OptionManager:SetOption('universalShops', 1)
                OptionManager:SetOption('turboCourier', 1)
                GameRules:SetUseUniversalShopMode(true)
                local groundCouriers = Entities:FindAllByClassname('npc_dota_courier')
                local flyingCouriers = Entities:FindAllByClassname('npc_dota_flying_courier')
                -- Loop over all ents
                for k,groundCouriers in pairs(groundCouriers) do
                    groundCouriers:AddNewModifier(spawnedUnit, nil, "modifier_turbo_courier", {})               
                end
                for k,flyingCouriers in pairs(flyingCouriers) do
                    flyingCouriers:AddNewModifier(spawnedUnit, nil, "modifier_turbo_courier", {})               
                end
                EmitGlobalSound("Event.CheatEnabled")
                GameRules:SendCustomMessage('Enough players voted to enable universal shops. <font color=\'#70EA72\'>You can now buy any item from any shop and turbo couriers are enabled</font>.',0,0)
            end)
        else
            util:DisplayError(playerID, "#universalShopsAlreadyOn")
        end
    elseif IsCommand("-enablecheat") or IsCommand("-ec") then
        if not ingame.voteEnabledCheatMode and not Convars:GetBool("sv_cheats") then
            util:CreateVoting("lodVotingEnableCheatMode", playerID, 10, 100, function()
                ingame.voteEnabledCheatMode = true
                EmitGlobalSound("Event.CheatEnabled")
                GameRules:SendCustomMessage('<font color=\'#70EA72\'>Everbody voted to enable cheat mode. Cheat mode enabled</font>.',0,0)
            end)
        elseif ingame.voteEnabledCheatMode or Convars:GetBool("sv_cheats") then
            util:DisplayError(playerID, "#cheatModeAlreadyOn")
        end

    elseif IsCommand("-enablekamikaze") or IsCommand("-ek") then
        if not ingame.voteDisableAntiKamikaze then
            util:CreateVoting("lodVotingEnableKamikaze", playerID, 10, 100, function()
                ingame.voteDisableAntiKamikaze = true
                EmitGlobalSound("Event.CheatEnabled")
                GameRules:SendCustomMessage('Everbody voted to disable the anti-Kamikaze mechanic. <font color=\'#70EA72\'>No more peanlty for dying 3 times within 60 seconds</font>.',0,0)
            end)
        elseif ingame.voteDisableAntiKamikaze then
            util:DisplayError(playerID, "#kamikazeAlreadyDeactivated")
        end
    elseif IsCommand("-enablebuilder") or IsCommand("-eb") and OptionManager:GetOption('allowIngameHeroBuilder') == false then
        if not ingame.voteEnableBuilder and OptionManager:GetOption('allowIngameHeroBuilder') ~= true then
            util:CreateVoting("lodVotingEnableHeroBuilder", playerID, 10, 100, function()
                network:enableIngameHeroEditor()
                OptionManager:SetOption('allowIngameHeroBuilder', 1)
                if util:GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS) > 0 and util:GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS) > 0 then
                    OptionManager:SetOption('ingameBuilderPenalty', 30)
                end
                ingame.voteEnableBuilder = true
                EmitGlobalSound("Event.CheatEnabled")
                GameRules:SendCustomMessage('Everbody voted to enable the ingame hero builder. <font color=\'#70EA72\'>You can now change your hero build mid-game</font>.',0,0)
            end)
        elseif OptionManager:GetOption('allowIngameHeroBuilder') == true or ingame.voteEnableBuilder then
            util:DisplayError(playerID, "#heroBuilderAlreadyOn")
        end
    elseif IsCommand("-enablerespawn") or IsCommand("-er") then
        if not ingame.voteDisableRespawnLimit then
            util:CreateVoting("lodVotingEnableRespawn", playerID, 10, 100, function()
                ingame.voteDisableRespawnLimit = true
                if ingame.origianlRespawnRate ~= nil then
                    OptionManager:SetOption('respawnModifierPercentage', ingame.origianlRespawnRate)
                end
                EmitGlobalSound("Event.CheatEnabled")
                GameRules:SendCustomMessage('Everbody voted to disable the increasing-spawn-rate mechanic. <font color=\'#70EA72\'>Respawn rates no longer increase after 40 minutes</font>. Respawn rate is now '.. OptionManager:GetOption('respawnModifierPercentage') .. '%.',0,0)
            end)
        elseif ingame.voteDisableRespawnLimit then
            util:DisplayError(playerID, "#respawnAlreadyDeactivated")
        end
    elseif IsCommand("-enablefat") or IsCommand("-ef") then
        if not ingame.voteEnableFatOMeter then
            util:CreateVoting("lodVotingFatOMeter", playerID, 10, OptionManager:GetOption('mapname') == 'all_allowed' and 50 or 100, function()
                ingame.voteEnableFatOMeter = true
                OptionManager:SetOption('useFatOMeter', 2)
                ingame:StartFatOMeter()
                EmitGlobalSound("Event.CheatEnabled")
            end)
        elseif ingame.voteEnableFatOMeter then
            util:DisplayError(playerID, "#fatOmeterAlreadyOn")
        end
    elseif IsCommand("-enablerefresh") then
        if OptionManager:GetOption('refreshCooldownsOnDeath') ~= 1 and not ingame.voteEnableRefresh then
            util:CreateVoting("lodVotingRefresh", playerID, 10, OptionManager:GetOption('mapname') == 'all_allowed' and 50 or 100, function()
                ingame.voteEnableRefresh = true
                EmitGlobalSound("Event.CheatEnabled")
            end)
        else
            util:DisplayError(playerID, "#refresherAlreadyOn")
        end
    elseif IsCommand("-switchteam") then
        local team = PlayerResource:GetTeam(playerID)
        if (ingame.needsTeamBalance and ingame.takeFromTeam == team) or util:isSinglePlayerMode() or IsInToolsMode() then
            local requiredPercentage = 100
            -- If game is less than 20 minutes in, you only require 50% of the vote to switch teams
            if GameRules:GetDOTATime(false,false) == 0 then
                util:DisplayError(playerID, "#cantSwitchYet")
            else
                if GameRules:GetDOTATime(false,false) < 1200 then
                requiredPercentage = 50
                end
                util:CreateVoting("lodVotingSwitchTeam", playerID, 10, requiredPercentage, function()
                    local oldTeam = PlayerResource:GetCustomTeamAssignment(playerID)
                    local newTeam = otherTeam(oldTeam)
                    local uMoney = PlayerResource:GetUnreliableGold(playerID)
                    local rMoney = PlayerResource:GetReliableGold(playerID)

                    GameRules:SetCustomGameTeamMaxPlayers(newTeam, GameRules:GetCustomGameTeamMaxPlayers(newTeam) + 1)

                    ingame:balancePlayer(playerID, newTeam)
                    PlayerResource:SetGold(playerID, uMoney, false)
                    PlayerResource:SetGold(playerID, rMoney, true)

                    GameRules:SetCustomGameTeamMaxPlayers(oldTeam, GameRules:GetCustomGameTeamMaxPlayers(oldTeam) - 1)
                end)
            end
            
        else
            --Failed, error message
        end
    end

    local hero = PlayerResource:GetSelectedHeroEntity(playerID) 
    -- If not valid hero, return
    if not IsValidEntity(hero) then return end

    ----------------------------
    -- Debug Commands
    ----------------------------
    if IsCommand("-test") then 
        GameRules:SendCustomMessage('testing testing 1. 2. 3.', 0, 0)
        util:DisplayError(playerID, "tested")
        print(OptionManager:GetOption('mapname'))
    elseif IsCommand("-fixhero") then 
        if GameRules.pregame.isWispSpawning and hero and hero:GetUnitName() ~= GameRules.pregame.selectedHeroes[playerID] then
            GameRules.pregame:onIngameBuilder(1, { playerID = playerID, ingamePicking = true })
        end
    elseif IsCommand("-printabilities") then
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
                print(abil:GetName(), abil:IsHidden(), abil:IsActivated())
            end
        end
        print("-----------------------------------")
    elseif IsCommand("gg") then
        if OptionManager:GetOption('memesRedux') == 1 then
            if ingame.heard["gg"] ~= true then
                
                EmitGlobalSound("Memes.GG")
                ingame.heard["gg"] = true

                Timers:CreateTimer( function()
                    ingame.heard["gg"] = false
                end, DoUniqueString('ggAgain'), 5)

            end
        end
    elseif IsCommand("-bot") then
        local splitedcommand = arguments 
        if splitedcommand[1] and splitedcommand[1] == "mode" then
            if not ingame.botsInLateGameMode then 
                ingame:CommandNotification("-botmode", "Bots are in early game mode.", 10)  
            elseif ingame.botsInLateGameMode then 
                ingame:CommandNotification("-botmode", "Bots are in late game mode.", 10)   
            end 
        end
         
    elseif IsCommand("-pid") then
        --if not ingame.voteEnabledCheatMode then
            for playerID=0,24-1 do
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if hero ~= nil and IsValidEntity(hero) then
                    GameRules:SendCustomMessage( string.sub(hero:GetName(),15) .. ': ' .. playerID ,0,0)
                end
            end
    elseif IsCommand("-printabilities") then 
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

    elseif IsCommand("-fixcasting") then 
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
    -- Cheat Commands
    ----------------------------
    if util:isSinglePlayerMode() or Convars:GetBool("sv_cheats") or ingame.voteEnabledCheatMode then
        -- Some cheats that work in tools and cheats mode conflict
        local blockConfliction = util:isSinglePlayerMode() or Convars:GetBool("sv_cheats")
        
        if IsCommand("-gold") then 
            -- Give user max gold, unless they specify a number
            if not ingame.heard["freestuff"] then
                EmitGlobalSound("Event.FreeStuff")
                ingame.heard["freestuff"] = true
            end   
            local goldAmount = 100000
            local splitedcommand = arguments       
            if splitedcommand[1] and tonumber(splitedcommand[1])then
                goldAmount = tonumber(splitedcommand[1])
            end

            Timers:CreateTimer(function()  
                PlayerResource:ModifyGold(hero:GetPlayerOwner():GetPlayerID(), goldAmount, true, 0)      
                ingame:CommandNotification("-gold", 'Cheat Used (-gold): Given ' .. goldAmount .. ' gold to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), .1)

        elseif IsCommand("-points") then 
            -- Give user max gold, unless they specify a number  
            local pointsAmount = 1
            local splitedcommand = arguments       
            if splitedcommand[1] and tonumber(splitedcommand[1])then
                pointsAmount = tonumber(splitedcommand[1])
            end

            Timers:CreateTimer(function()  
                hero:SetAbilityPoints(pointsAmount)  
                ingame:CommandNotification("-points", 'Free Ability Points Used (-points): Given ' .. pointsAmount .. ' ability points to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), .1)

        -- Some Bot commands are cheats
        elseif IsCommand("-bot") then
            local splitedcommand = arguments 
            if splitedcommand[1] and splitedcommand[1] == "switch" then
                if ingame.botsInLateGameMode then
                    ingame.botsInLateGameMode = false
                    GameRules:GetGameModeEntity():SetBotsInLateGame(ingame.botsInLateGameMode)
                else
                    ingame.botsInLateGameMode = true
                    GameRules:GetGameModeEntity():SetBotsInLateGame(ingame.botsInLateGameMode)
                end
                ingame:CommandNotification("-switched", "Bots have switched modes.", 5)
            end    
        
        elseif IsCommand("-god") then 
            Timers:CreateTimer(function()  
                local godMode = hero:FindModifierByName("modifier_invulnerable")
                if godMode then
                    hero:RemoveModifierByName("modifier_invulnerable")
                else
                    hero:AddNewModifier(hero,nil,"modifier_invulnerable",{duration = 240})
                    ingame:CommandNotification("-godmode", 'Cheat Used (-godmode): Given invulnerability to '.. PlayerResource:GetPlayerName(playerID)) 
                end
                             
            end, DoUniqueString('cheat'), .1)
        -- Remove fog of war
        elseif IsCommand("-nofog") then
        GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)

         -- Bring back the fog of war
        elseif IsCommand("-fog") then
        GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)

        elseif IsCommand("-aghs") or IsCommand("-aghanim") or IsCommand("-scepter") then 
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

        elseif IsCommand("-regen") then 
            Timers:CreateTimer(function()  
                local godMode = hero:FindModifierByName("modifier_fountain_aura_buff")
                if godMode then
                    hero:RemoveModifierByName("modifier_fountain_aura_buff")
                else
                    hero:AddNewModifier(hero,nil,"modifier_fountain_aura_buff",{})
                    ingame:CommandNotification("-godmode", 'Cheat Used (-regen): Given foutain regeneration to '.. PlayerResource:GetPlayerName(playerID)) 
                end
                             
            end, DoUniqueString('cheat'), .1)

         elseif IsCommand("-gem") then 
            Timers:CreateTimer(function()  
                local trueSight = hero:FindModifierByName("modifier_tower_truesight_aura")
                if trueSight then
                    hero:RemoveModifierByName("modifier_tower_truesight_aura")
                else
                    hero:AddNewModifier(hero,nil,"modifier_tower_truesight_aura",{})
                    ingame:CommandNotification("-gem", 'Cheat Used (-gem): Given True Sight to '.. PlayerResource:GetPlayerName(playerID)) 
                end
                             
            end, DoUniqueString('cheat'), .1)
            
        elseif IsCommand("-invis") then 
            Timers:CreateTimer(function()
                local invis = hero:FindAbilityByName("riki_permanent_invisibility_lod")

                if invis then
                    hero:RemoveAbility("riki_permanent_invisibility_lod")
                    hero:RemoveModifierByName("modifier_invisible")
                else 
                    invisAbility = hero:AddAbility("riki_permanent_invisibility_lod")
                    hero:AddNewModifier(hero,nil,"modifier_invisible",{})
                    invisAbility:SetActivated(true)
                    invisAbility:SetLevel(3)
                    invisAbility:SetHidden(true)
                    ingame:CommandNotification("-invis", 'Cheat Used (-invis): Given Invisibility to '.. PlayerResource:GetPlayerName(playerID))
                end  
                             
            end, DoUniqueString('cheat'), .1)

        -- Command that can change the difficulty of buts example "-diff 4 #6", 4 is unfair and #6 indentifies a player ID
        elseif IsCommand("-dif") then 
            Timers:CreateTimer(function()
                local splitedcommand = arguments       
                if splitedcommand[1] and tonumber(splitedcommand[1])then
                    difficulty = tonumber(splitedcommand[1])
                end
                hero:SetBotDifficulty(difficulty)
                             
            end, DoUniqueString('botdiff'), .1)

        elseif IsCommand("-reflect") then 
            Timers:CreateTimer(function()
                local reflect = hero:FindAbilityByName("spell_reflect_cheat")

                if reflect then
                    hero:RemoveAbility("spell_reflect_cheat")
                else 
                    reflectAbility = hero:AddAbility("spell_reflect_cheat")
                    reflectAbility:SetActivated(true)
                    reflectAbility:SetLevel(1)
                    reflectAbility:SetHidden(false)
                    ingame:CommandNotification("-reflect", 'Cheat Used (-reflect): Given Spell Reflect to '.. PlayerResource:GetPlayerName(playerID))
                end  
                             
            end, DoUniqueString('cheat'), .1)

        elseif IsCommand("-spellblock") then 
            Timers:CreateTimer(function()
                local block = hero:FindAbilityByName("roshan_spell_block_cheat")

                if block then
                    hero:RemoveAbility("roshan_spell_block_cheat")
                else 
                    blockAbility = hero:AddAbility("roshan_spell_block_cheat")
                    blockAbility:SetActivated(true)
                    blockAbility:SetLevel(1)
                    blockAbility:SetHidden(true)
                    ingame:CommandNotification("-spellblock", 'Cheat Used (-spellblock): Given Spell Block to '.. PlayerResource:GetPlayerName(playerID))
                end  
                             
            end, DoUniqueString('cheat'), .1)

        elseif IsCommand("-cooldown") then 
            Timers:CreateTimer(function()
                local cooldown = hero:FindAbilityByName("jingtong_cheat")

                if cooldown then
                    hero:RemoveAbility("jingtong_cheat")
                else 
                    cooldownAbility = hero:AddAbility("jingtong_cheat")
                    cooldownAbility:SetActivated(true)
                    cooldownAbility:SetLevel(1)
                    cooldownAbility:SetHidden(false)
                    ingame:CommandNotification("-cooldown", 'Cheat Used (-cooldown): Given No Cooldowns to '.. PlayerResource:GetPlayerName(playerID))
                end  
                             
            end, DoUniqueString('cheat'), .1)

        elseif IsCommand("-globalcast") then 
            Timers:CreateTimer(function()
                local globalcast = hero:FindAbilityByName("aether_range_lod_global")

                if globalcast then
                    hero:RemoveAbility("aether_range_lod_global")
                else 
                    globalcastAbility = hero:AddAbility("aether_range_lod_global")
                    globalcastAbility:SetActivated(true)
                    globalcastAbility:SetLevel(1)
                    globalcastAbility:SetHidden(false)
                    ingame:CommandNotification("-globalcast", 'Cheat Used (-globalcast): Given global cast range to '.. PlayerResource:GetPlayerName(playerID))
                end  
                             
            end, DoUniqueString('cheat'), .1)

        elseif (IsCommand("-wtf") and not blockConfliction) or IsCommand("-wtfmenu") then 
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

        elseif IsCommand("-unwtf") and not blockConfliction then 
            Timers:CreateTimer(function()  
                if OptionManager:GetOption('lodOptionCrazyWTF') == 1 then
                    OptionManager:SetOption('lodOptionCrazyWTF', 0)
                    ingame:CommandNotification("-wtfoff", 'Cheat Used (-wtf): WTF mode disabled, spells have regular cooldowns and manacosts.',30)    
                end           
            end, DoUniqueString('cheat'), .1)
 
        elseif IsCommand("-bear") then 
            -- Give user 1 level, unless they specify a number after
            local hAncient = Entities:FindByName( nil, "dota_badguys_fort" )
            hAncient:AddAbility("invasion")
            local ab = hAncient:FindAbilityByName("invasion")
            ab:UpgradeAbility(false)

        elseif IsCommand("-lvlup") then 
            -- Give user 1 level, unless they specify a number after
            local levels = 1
            local splitedcommand = arguments       
            if splitedcommand[1] and tonumber(splitedcommand[1]) then
                levels = tonumber(splitedcommand[1])
            end
            Timers:CreateTimer(function()
                local level = hero:GetLevel() + levels
                while hero:GetLevel() < level and hero:GetLevel() ~= OptionManager:GetOption('maxHeroLevel')do
                    hero:AddExperience(1,DOTA_ModifyXP_Unspecified,false,false)              
                end
                ingame:CommandNotification("-lvlup", 'Cheat Used (-lvlup): Given ' .. levels .. ' level(s) to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), .1)

        elseif IsCommand("-item") then 
            -- Give user 1 level, unless they specify a number after
            Timers:CreateTimer(function()  
                local splitedcommand = arguments       
                local validItem = false
                if splitedcommand[1] then
                    hero:AddItemByName(splitedcommand[1])
                    local findItem = hero:FindItemByName(splitedcommand[1])
                    if findItem then validItem = true end
                end
                if validItem then
                    ingame:CommandNotification("-item", 'Cheat Used (-item): Given ' .. splitedcommand[1] .. ' to '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)

        elseif IsCommand("-addability") or IsCommand("-giveability") or IsCommand("-add") then 
            -- Give user 1 level, unless they specify a number after
            Timers:CreateTimer(function()  
              local splitedcommand = arguments       
              if splitedcommand[1] then 
                local absCustom = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
                for k,v in pairs(absCustom) do
                    --print(k)
                    if string.find(k, splitedcommand[1]) then
                      splitedcommand[1] = k
                    end
                end
                hero:AddAbility(splitedcommand[1])
                    local findAbility = hero:FindAbilityByName(splitedcommand[1])
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
                    ingame:CommandNotification("-addability", 'Cheat Used (-addability): Given ' .. splitedcommand[1] .. ' to '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)

        elseif IsCommand("-spawn") then 
            -- Give user 1 level, unless they specify a number after
            Timers:CreateTimer(function()  
                if string.find(command, "golem") then
                    local spawnLoc = hero:GetAbsOrigin()-hero:GetForwardVector()*200
                    local golem = CreateUnitByName("npc_dota_warlock_golem_1", spawnLoc, true, nil, nil, otherTeam(hero:GetTeamNumber()))
                end

                --ingame:CommandNotification("-addability", 'Cheat Used (-addability): Given ' .. splitedcommand[1] .. ' to '.. PlayerResource:GetPlayerName(playerID)) 
        
            end, DoUniqueString('cheat'), .1)

        elseif IsCommand("-removeability") or IsCommand("-remove") then 
            -- Give user 1 level, unless they specify a number after

            Timers:CreateTimer(function()  
                local splitedcommand = arguments   
                local validAbility = false
                if splitedcommand[1] then    
                    for i=0,32 do
                        local abil = hero:GetAbilityByIndex(i)
                        if abil then
                            if splitedcommand[1] == "all" then
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
                        hero:RemoveAbility(splitedcommand[1])
                    end
                end
                if validAbility then
                    ingame:CommandNotification("-removeability", 'Cheat Used (-removeability): -removeability used by  '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)

        elseif IsCommand("-lvlmax") then 
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

        elseif IsCommand("-dagger") then 
            Timers:CreateTimer(function()
                hero:AddItemByName('item_devDagger')
                ingame:CommandNotification("-item_devDagger", 'Cheat Used (-dagger): Global teleport dagger given to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), 0.2)

        elseif IsCommand("-dagon") then 
            Timers:CreateTimer(function()
                hero:AddItemByName('item_devDagon')
                ingame:CommandNotification("-item_devDagon", 'Cheat Used (-dagon): Ultra dagon dagon given to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), 0.2)


        elseif IsCommand("-teleport") and not blockConfliction then 
            -- Teleport is not exactly reproduced. If the game is in tools mode or has sv_cheats, leave it as it is, if not give players the teleport dagger.
                Timers:CreateTimer(function()
                    hero:AddItemByName('item_devDagger')
                    ingame:CommandNotification("-teleport", 'Cheat Used (-teleport): Global teleport dagger given to '.. PlayerResource:GetPlayerName(playerID)) 
                end, DoUniqueString('cheat'), 0.2)
        
        elseif IsCommand("-startgame") and not blockConfliction then 
            Timers:CreateTimer(function()
                --print(GameRules:GetDOTATime(false,false)) 
                -- If the game has already started, do nothing.
                if GameRules:GetDOTATime(false,false) == 0 then
                    Tutorial:ForceGameStart()
                    ingame:CommandNotification("-startgame", 'Cheat Used (-startgame): Forced game start, by '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)    

        elseif IsCommand("-respawn") then 
            Timers:CreateTimer(function()
                if not hero:IsAlive() then
                    hero:SetTimeUntilRespawn(1)
                end
                ingame:CommandNotification("-respawn", 'Cheat Used (-respawn): Respawned '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), 1)

        elseif IsCommand("-refresh") then 
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
        elseif IsCommand("-fortify_dire") then
            Timers:CreateTimer(function()
                fortify_dire(playerID)
            end, DoUniqueString('cheatrefresh'), .2)
        elseif IsCommand("-fortify_rad") then
            Timers:CreateTimer(function()
                fortify_rad(playerID)
            end, DoUniqueString('cheatrefresh'), .2)
        elseif IsCommand("-fortify") then
            Timers:CreateTimer(function()
                fortify_dire(playerID)
                fortify_rad(playerID)
            end, DoUniqueString('cheatrefresh'), .2)
        end
    end
end

function fortify_dire(playerID)
    DIREFORTIFIED = DIREFORTIFIED or false
    if not DIREFORTIFIED then
        local buildings = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER , false)
        for _,building in pairs(buildings) do
            building:AddNewModifier(nil,nil,"modifier_fountain_glyph",{})
        end
        ingame:CommandNotification("-fortify_dire", 'Cheat Used (-fortify_dire): by '.. PlayerResource:GetPlayerName(playerID).." Dire buildings are fortified") 
    else
        local buildings = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER , false)
        for _,building in pairs(buildings) do
            building:RemoveModifierByName("modifier_fountain_glyph")
        end
        ingame:CommandNotification("-fortify_dire", 'Cheat Used (-fortify_dire): by '.. PlayerResource:GetPlayerName(playerID).." Dire buildings are unfortified") 
    end
    DIREFORTIFIED = not DIREFORTIFIED
end

function fortify_rad(playerID)
    RADIANTFORTIFIED = RADIANTFORTIFIED or false
    if not RADIANTFORTIFIED then
        local buildings = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER , false)
        for _,building in pairs(buildings) do
            building:AddNewModifier(nil,nil,"modifier_fountain_glyph",{})
        end
        ingame:CommandNotification("-fortify_rad", 'Cheat Used (-fortify_rad): by '.. PlayerResource:GetPlayerName(playerID).." Radiant buildings are fortified") 
    else
        local buildings = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER , false)
        for _,building in pairs(buildings) do
            building:RemoveModifierByName("modifier_fountain_glyph")
        end
        ingame:CommandNotification("-fortify_rad", 'Cheat Used (-fortify_rad): by '.. PlayerResource:GetPlayerName(playerID).." Radiant buildings are unfortified") 
    end
    RADIANTFORTIFIED = not RADIANTFORTIFIED
end