Chat = Chat or class({})

function Chat:Init()
  CustomGameEventManager:RegisterListener("custom_chat_say", Dynamic_Wrap(Chat, "Say"))
end

function Chat:Say( args )
  if args["PlayerID"] then
    local ply = PlayerResource:GetPlayer(args["PlayerID"])
    if ply then
      local hours, minutes, seconds = string.match(GetSystemTime(), '(%d+)[:](%d+)[:](%d+)')
      
      local timeStamp = hours .. ":" .. minutes
      local channel = args["channel"]
      local msg = args["msg"]
      
      if channel == 'team' then
        local team = PlayerResource:GetTeam(args["PlayerID"])
        CustomGameEventManager:Send_ServerToTeam(team, "custom_chat_send_message", 
          { timeStamp = timeStamp, player = args["PlayerID"], channel = channel, msg = msg, localize = args.localize })
      end

      if channel == 'all' then
        CustomGameEventManager:Send_ServerToAllClients("custom_chat_send_message", 
          { timeStamp = timeStamp, player = args["PlayerID"], channel = channel, msg = msg, localize = args.localize })
      end
      Say(ply, msg, false)
      Commands:OnPlayerChat({
          teamonly = false,
          playerid = args.PlayerID,
          text = msg
      })
    end
  end
end
