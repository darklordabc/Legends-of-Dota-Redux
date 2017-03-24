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
  
  if SU.StatSettings ~= nil then
    if isTest or (not GameRules:IsCheatMode()) then
      ListenToGameEvent('game_rules_state_change', 
        function(keys)
          local state = GameRules:State_Get()
          if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
            SU:SendAuthInfo()
          elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
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

-- Send player build
function SU:SendPlayerBuild( args )
  local Data = {}
 
  for pID = 0, DOTA_MAX_PLAYERS do
    if PlayerResource:IsValidPlayerID(pID) then
      if not PlayerResource:IsBroadcaster(pID) and not util:isPlayerBot(pID) then
        local abilities = {}
        for i=1,16 do
          if args[pID] then
            local v = args[pID][i]
            if v then
              abilities[i] = v
            end
          end
        end
        
        Data[PlayerResource:GetSteamAccountID(pID)] = {
          AbilityString = json.encode(abilities),
          Hero = PlayerResource:GetPlayer(pID):GetAssignedHero():GetUnitName()
        }
        
      end
    end
  end
  
  local requestParams = {
    Command = "SendPlayerBuild",
    Data = Data
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

function SU:DisconnectPlayer( playerID )
  local requestParams = {
    Command = "DisconnectPlayer",
    SteamID = PlayerResource:GetSteamAccountID(playerID)
  }
  
  SU:SendRequest( requestParams, function(obj)
  end)  
end

return SU