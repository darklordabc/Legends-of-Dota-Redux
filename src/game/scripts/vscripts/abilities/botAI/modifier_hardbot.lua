--Taken from the spelllibrary, credits go to valve

modifier_hardbot = class({})


--------------------------------------------------------------------------------

function modifier_hardbot:IsHidden()
    return false
end

--------------------------------------------------------------------------------

function modifier_hardbot:RemoveOnDeath()
    return false
end

function modifier_hardbot:IsPermanent()
	return true	
end

function modifier_hardbot:IsPurgable()
	return false	
end


function modifier_hardbot:GetTexture()
	return "custom/modifier_hardbot"
end

