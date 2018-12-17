
-- Lua Library Imports
LinkLuaModifier("modifier_redux_tower_ability","abilities/pocket_tower.lua",LUA_MODIFIER_MOTION_NONE);
require("abilities/builder");
item_redux_pocket_tower = item_redux_pocket_tower or builder.new()
item_redux_pocket_tower.__index = item_redux_pocket_tower
item_redux_pocket_tower.__base = builder
function item_redux_pocket_tower.new(construct, ...)
    local self = setmetatable({}, item_redux_pocket_tower)
    if construct and item_redux_pocket_tower.constructor then item_redux_pocket_tower.constructor(self, ...) end
    return self
end
function item_redux_pocket_tower.constructor(self)
end
function item_redux_pocket_tower.GetUnitName(self)
    if self:GetCaster():GetTeamNumber()==DOTA_TEAM_GOODGUYS then
        return "npc_dota_goodguys_tower4"
    else
        return "npc_dota_badguys_tower4"
    end
end
function item_redux_pocket_tower.OnBuildingPlaced(self,location,building)
    building:AddNewModifier(self:GetCaster(),self,"modifier_redux_tower_ability",{});
    if OptionManager:GetOption("strongTowers") then
        ingame:updateStrongTowers(building);
    end
    self:SetCurrentCharges(self:GetCurrentCharges()-1);
    if self:GetCurrentCharges()<=0 then
        self:Destroy();
    end
end
