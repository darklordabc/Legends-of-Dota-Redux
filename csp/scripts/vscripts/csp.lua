if CSP == nil then
    CSP = {}
    CSP.szEntityClassName = "csp"
    CSP.szNativeClassName = "dota_base_game_mode"
end

function CSP:new(o)
    o = o or {}
    setmetatable(o, CSP)
    return o
end

function CSP:InitGameMode()
end

EntityFramework:RegisterScriptClass(CSP)
