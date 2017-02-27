if eldri_anti_magic == nil then
	eldri_anti_magic = class({})
end

LinkLuaModifier( "anti_magic_mod", "abilities/overflow/eldri_anti_magic/modifier.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "generic_lua_stun", "abilities/overflow/generic_stun.lua", LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "book_eldri_modifier", "abilities/overflow/eldri_book.lua", LUA_MODIFIER_MOTION_NONE )

function eldri_anti_magic:GetBehavior()
	local behav = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	return behav
end


function eldri_anti_magic:GetManaCost()
	return self.BaseClass.GetManaCost( self, self:GetLevel() )
end

function eldri_anti_magic:GetCooldown( nLevel )
	if self:GetCaster():HasScepter() then
		return self.BaseClass.GetCooldown( self, nLevel )
	else
		return self.BaseClass.GetCooldown( self, nLevel )
	end
end


function eldri_anti_magic:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function eldri_anti_magic:OnSpellStart()
	CreateModifierThinker( self:GetCaster(), self, "anti_magic_mod", { duration = self:GetSpecialValueFor("duration") }, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), true )
end

function eldri_anti_magic:OnUpgrade()
	--self:GetCaster():AddNewModifier( self:GetCaster(), self, "book_eldri_modifier", { stacks = 1 } )
end
