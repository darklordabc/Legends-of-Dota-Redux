-- The overall game state has changed
function duskDota:_OnGameRulesStateChange(keys)
  if duskDota._reentrantCheck then
    return
  end

  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    --Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    duskDota:PostLoadPrecache()
    duskDota:OnAllPlayersLoaded()

    if USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS then
      for i=0,9 do
        if PlayerResource:IsValidPlayer(i) then
          local color = TEAM_COLORS[PlayerResource:GetTeam(i)]
          PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
        end
      end
    end
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    duskDota:OnGameInProgress()
  end

  duskDota._reentrantCheck = true
  duskDota:OnGameRulesStateChange(keys)
  duskDota._reentrantCheck = false
end

-- An NPC has spawned somewhere in game.  This includes heroes
function duskDota:_OnNPCSpawned(keys)
  if duskDota._reentrantCheck then
    return
  end

  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() and npc.bFirstSpawned == nil then
    npc.bFirstSpawned = true
    duskDota:OnHeroInGame(npc)
  end

  duskDota._reentrantCheck = true
  duskDota:OnNPCSpawned(keys)
  duskDota._reentrantCheck = false
end

-- An entity died
function duskDota:_OnEntityKilled( keys )
  if duskDota._reentrantCheck then
    return
  end

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  if killedUnit:IsRealHero() then 
    DebugPrint("KILLED, KILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
    if END_GAME_ON_KILLS and GetTeamHeroKills(killerEntity:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
      GameRules:SetSafeToLeave( true )
      GameRules:SetGameWinner( killerEntity:GetTeam() )
    end

    --PlayerResource:GetTeamKills
    if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS) )
    end
  end

  duskDota._reentrantCheck = true
  duskDota:OnEntityKilled( keys )
  duskDota._reentrantCheck = false
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function duskDota:_OnConnectFull(keys)
  if duskDota._reentrantCheck then
    return
  end

  duskDota:_CaptureduskDota()

  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  local userID = keys.userid

  self.vUserIds = self.vUserIds or {}
  self.vUserIds[userID] = ply

  duskDota._reentrantCheck = true
  duskDota:OnConnectFull( keys )
  duskDota._reentrantCheck = false
end
