require('lib/StatUploader')
local isTest = true
local steamIDs;

ListenToGameEvent('game_rules_state_change', 
  function(keys)
    local state = GameRules:State_Get()

    if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
      SU:Init()
    end
  end, nil)

function SU:BuildSteamIDArray()
    local players = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
      if PlayerResource:IsValidPlayerID(playerID) then
        if not PlayerResource:IsBroadcaster(playerID) then
          table.insert(players, PlayerResource:GetSteamAccountID(playerID))
        end
      end
    end

    return players
end

function SU:Init()
  steamIDs = SU:BuildSteamIDArray()
  DeepPrintTable(steamIDs)
  
  if SU.StatSettings ~= nil then
    if isTest or (not GameRules:IsCheatMode()) then
      ListenToGameEvent('game_rules_state_change', 
        function(keys)
          local state = GameRules:State_Get()
          if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
            SU:SendAuthInfo()
          elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
            SU:LoadPlayersMessages()
          end
        end, nil)
    else
      print("Bad stat recording conditions.")
    end    
  else
    print("StatUploader settings file not found.")
  end
end

function SU:LoadPlayersMessages()
  local requestParams = {
    Command = "LoadPlayersMessages",
    SteamIDs = steamIDs
  }
    
  SU:SendRequest( requestParams, function(obj)
    if type(obj) == "string" then
      print(obj)
      return
    end
      
    for playerID = 0, DOTA_MAX_PLAYERS do
      if PlayerResource:IsValidPlayerID(playerID) then
        if not PlayerResource:IsBroadcaster(playerID) then
          local steamID = PlayerResource:GetSteamAccountID(playerID)
          local messages = table.filter(obj, function(k, v, obj)
            return v.SteamID == tostring(steamID)
          end)

          CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "su_new_messages", messages )
        end
      end
    end 
  end)
end

-- Send message event
CustomGameEventManager:RegisterListener( "su_send_message", Dynamic_Wrap(SU, 'SendPlayerMessage'))

function SU:SendPlayerMessage( args )
  local playerID = args.PlayerID
  local steamID = PlayerResource:GetSteamAccountID(playerID)
  local month, day, year = string.match(GetSystemDate(), '(%d+)[/](%d+)[/](%d+)')  
  
  local requestParams = {
    Command = "SendPlayerMessage",
    Data = {
      SteamID = steamID,
      Nickname = PlayerResource:GetPlayerName(playerID),
      Message = args.message,
      TimeStamp = string.format("20%s%s%s", year, month, day)
    }
  }
  
  SU:SendRequest( requestParams, function(obj)
  end)
end

-- Send message event
CustomGameEventManager:RegisterListener( "su_mark_message_read", Dynamic_Wrap(SU, 'MarkMessageRead'))

function SU:MarkMessageRead( args )
  
  local requestParams = {
    Command = "MarkMessageRead",
    MessageID = args.message_id
  }
  
  SU:SendRequest( requestParams, function(obj)
  end)
end

function SU:SendPlayerBuild( args, pID )
  local abilities = {}

  for i=1,16 do
    local v = args[i]
    if v then
      abilities[i] = v
      print(v)
    end
  end
  
  local requestParams = {
    Command = "SendPlayerBuild",
    Data = {
      AbilityString = json.encode(abilities),
      SteamID = PlayerResource:GetSteamAccountID(pID)
    }
  }
  
  SU:SendRequest( requestParams, function(obj)
  end)
end

function SU:LoadPlayerAbilities( pID )
  local requestParams = {
    Command = "LoadPlayerAbilities",
    SteamID = PlayerResource:GetSteamAccountID(pID)
  }
  
  SU:SendRequest( requestParams, function(obj)
  end)  
end

function SU:LoadGlobalAbilitiesStat()
  local requestParams = {
    Command = "LoadGlobalAbilitiesStat",
  }
  
  SU:SendRequest( requestParams, function(obj)
  end)  
end

return SU