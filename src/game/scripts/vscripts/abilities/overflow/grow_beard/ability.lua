if grow_beard == nil then
	grow_beard = class({})
end

LinkLuaModifier("grow_beard_mod", "abilities/overflow/grow_beard/modifier.lua", LUA_MODIFIER_MOTION_NONE)

function grow_beard:GetBehavior() 
	local behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT
	return behav
end

function grow_beard:OnSpellStart()
	local hCaster = self:GetCaster()
	local hMod = hCaster:FindModifierByNameAndCaster("grow_beard_mod", hCaster)
	local nStack = hMod:GetStackCount()
	local nGold = self:GetSpecialValueFor("gold") * nStack * nStack
	local pID = self:GetCaster():GetPlayerID()
	local player = PlayerResource:GetPlayer( pID )

	hMod:SetStackCount(0)
	hCaster:ModifyGold(nGold, true, DOTA_ModifyGold_Unspecified) 
	EmitSoundOnClient("General.Coins", player)
	hCaster:PopupNumbers(hCaster, "gold", Vector(255, 215, 0), 2.0, nGold, 0, nil)
end

function grow_beard:GetIntrinsicModifierName() return "grow_beard_mod" end
