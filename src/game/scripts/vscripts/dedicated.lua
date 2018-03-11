print('Connection states checker!')

require('lib/timers')
local disconnectedPlayers = {}

ListenToGameEvent('game_rules_state_change', 
  function(keys)
    local state = GameRules:State_Get()
    
    -- Start checking disconnects
    if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and IsDedicatedServer() then
      ListenToGameEvent('player_disconnect', function(keys)
        print('disconnect')
        if keys.networkid ~= 'BOT' and disconnectedPlayers[keys.PlayerID] == nil then
          disconnectedPlayers[keys.PlayerID] = 1
          SU:DisconnectPlayer( keys.PlayerID )
        end
      end, nil)
    end
  end, nil)