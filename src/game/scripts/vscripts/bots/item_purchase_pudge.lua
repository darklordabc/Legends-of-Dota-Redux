require( GetScriptDirectory().."/item_purchase_generic" )

local tableItemsToBuy = { 
	"item_tango",
	"item_flask",
	"item_courier",
	"item_stout_shield",
	"item_gauntlets",
	"item_boots",
	"item_sobi_mask",
	"item_gauntlets",
	"item_recipe_urn_of_shadows",
	"item_flying_courier",
	"item_ring_of_regen",
	"item_cloak",
	"item_ring_of_health",
	"item_blink",
	"item_chainmail",
	"item_robe",
	"item_broadsword",
	"item_ring_of_regen",
	"item_branches",
	"item_recipe_headdress",
	"item_recipe_pipe",
	"item_recipe_travel_boots",
	"item_staff_of_wizardry",
	"item_ring_of_regen",
	"item_recipe_force_staff",
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
		elseif ( sNextItem == "item_staff_of_wizardry" ) then
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
