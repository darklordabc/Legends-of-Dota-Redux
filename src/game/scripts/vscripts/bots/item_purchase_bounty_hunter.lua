require( GetScriptDirectory().."/item_purchase_generic" )

local tableItemsToBuy = { 
	"item_tango",
	"item_faerie_fire",
	"item_enchanted_mango",
	"item_flask",
	"item_clarity",
	"item_boots",
	"item_sobi_mask",
	"item_blades_of_attack",
	"item_blades_of_attack",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_urn_of_shadows",
	"item_blight_stone",
	"item_sobi_mask",
	"item_chainmail",
	"item_blade_of_alacrity",
	"item_robe",
	"item_blade_of_alacrity",
	"item_recipe_diffusal_blade",
	"item_sobi_mask",
	"item_robe",
	"item_quarterstaff",
	"item_sobi_mask",
	"item_robe",
	"item_quarterstaff",
	"item_recipe_orchid",
	"item_recipe_diffusal_blade",
	"item_recipe_travel_boots",
	"item_boots",
	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",
	"item_broadsword",
	"item_blades_of_attack",
	"item_recipe_lesser_crit",
	"item_recipe_bloodthorn",
	"item_recipe_travel_boots",
};

function ItemPurchaseThink()

	local npcBot = GetBot();
	
	if ( #tableItemsToBuy == 0 ) then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	local sNextItem = tableItemsToBuy[1];
	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );

	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) ) then
		if ( sNextItem == "item_boots" ) then
			if ( BootsProtocol() ) then
				npcBot:Action_PurchaseItem( sNextItem );
				table.remove( tableItemsToBuy, 1 );
			else
--				print("awaiting boots protocol");
--				print(npcBot:GetUnitName());
			end
		elseif ( sNextItem == "item_ogre_axe" ) then
			if ( TravelsDone() ) then
				npcBot:Action_PurchaseItem( sNextItem );
				table.remove( tableItemsToBuy, 1 );
			else
--				print("awaiting travels");
--				print(npcBot:GetUnitName());
			end
		else
			npcBot:Action_PurchaseItem( sNextItem );
			table.remove( tableItemsToBuy, 1 );
		end
	end
	
	DoStuff();
	
end
