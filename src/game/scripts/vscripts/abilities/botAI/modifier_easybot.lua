--Taken from the spelllibrary, credits go to valve

modifier_easybot = class({})


--------------------------------------------------------------------------------

function modifier_easybot:IsHidden()
    return false
end

--------------------------------------------------------------------------------

function modifier_easybot:RemoveOnDeath()
    return false
end

function modifier_easybot:IsPermanent()
	return true	
end

function modifier_easybot:IsPurgable()
	return false	
end


function modifier_easybot:GetTexture()
	return "custom/modifier_easybot"
end

