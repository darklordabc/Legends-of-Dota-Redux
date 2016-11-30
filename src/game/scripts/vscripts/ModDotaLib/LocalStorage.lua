-- TODO: Move to some util file
function PrintTable(t, indent, done)
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
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
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


local SUCCESS = 0
local WRITE_NOT_SUCCESSFUL = 1

local storage = class({sequenceNumber = 0})

--This also exists in the Panorama section of the library
function storage:setKey(playerID, filename, key, value, callback)
    if self.sequenceNumber == nil then
        self.sequenceNumber = 0
        self.db = {}
    end
    print("[ModDotaLib - LocalStorage] " .. self.sequenceNumber)
    self.sequenceNumber = self.sequenceNumber + 1
    if IsInToolsMode() then
        print("[ModDotaLib - LocalStorage] WARNING: Running LocalStorage in tools mode. Using alternate location to prevent read-only storage for end users")
    end
    FireGameEvent("moddota_localstorage_set", {
        filename = "scripts/" ..(IsInToolsMode() and "tools/" or "") .. filename .. ".kv",
        key = key,
        value = value,
        sequenceNumber = self.sequenceNumber,
        pid = playerID
    })
    self.db[self.sequenceNumber] = {
        callback = callback,
        pid = playerID
    }
    return self.sequenceNumber
end
function storage:getKey(playerID, filename, key, callback)
    if self.sequenceNumber == nil then
        self.sequenceNumber = 0
        self.db = {}
    end
    self.sequenceNumber = self.sequenceNumber + 1
    FireGameEvent("moddota_localstorage_get", {
        filename = "scripts/" .. (IsInToolsMode() and "tools/" or "") .. filename .. ".kv",
        key = key,
        sequenceNumber = self.sequenceNumber,
        pid = playerID
    })
    self.db[self.sequenceNumber] = {
        callback = callback,
        pid = playerID
    }
    return self.sequenceNumber
end
Convars:RegisterCommand("moddota_localstorage_ack", function(cmdname, success, sequenceNumber, pid)
    if tonumber(pid) == 255 then
        CustomGameEventManager:Send_ServerToPlayer(Convars:GetCommandClient(), "moddota_localstorage_ack", {
            success = tonumber(success),
            sequenceNumber = tonumber(sequenceNumber)
        })
        return
    end
    if tonumber(success) ~= SUCCESS then
        print("[ModDotaLib - LocalStorage] Save failed. (" .. sequenceNumber .. ")")
    end
    --Regardless of success or failure, we need to report back to the gamemode
    PrintTable(storage)
    storage.db[tonumber(sequenceNumber)].callback(tonumber(sequenceNumber), tonumber(success))
end, "Fuck", 0)
Convars:RegisterCommand("moddota_localstorage_value", function(cmdname, success, sequenceNumber, pid, value)
    if tonumber(pid) == 255 then
        CustomGameEventManager:Send_ServerToPlayer(Convars:GetCommandClient(), "moddota_localstorage_value", {
            success = tonumber(success),
            sequenceNumber = tonumber(sequenceNumber),
            value = value
        })
        return
    end
    if tonumber(success) ~= SUCCESS then
        print("[ModDotaLib - LocalStorage] Load failed.")
        --TODO: Do more detailed analysis of why it fucked up.
        storage.db[tonumber(sequenceNumber)].callback(tonumber(sequenceNumber), tonumber(success))
    else
        storage.db[tonumber(sequenceNumber)].callback(tonumber(sequenceNumber), tonumber(success), value)
    end
end, "Fuck", 0)

return storage