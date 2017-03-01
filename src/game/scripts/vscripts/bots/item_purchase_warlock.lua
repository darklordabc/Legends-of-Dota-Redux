require( GetScriptDirectory().."/item_purchase_generic" )

local tableItemsToBuy = { 
	"item_tango",
	"item_courier",
	"item_faerie_fire",
	"item_enchanted_mango",
	"item_flask",
	"item_clarity",
	"item_boots",
	"item_flying_courier",
	"item_ring_of_regen",
	"item_ring_of_protection",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_circlet",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_urn_of_shadows",
	"item_sobi_mask",
	"item_staff_of_wizardry",
	"item_ring_of_regen",
	"item_recipe_force_staff",
	"item_helm_of_iron_will",
	"item_mantle",
	"item_circlet",
	"item_recipe_null_talisman",
	"item_mantle",
	"item_circlet",
	"item_recipe_null_talisman",
	"item_recipe_veil_of_discord",
	"item_recipe_travel_boots",
	"item_boots",
	"item_recipe_necronomicon",
	"item_staff_of_wizardry",
	"item_belt_of_strength",
	"item_recipe_necronomicon",
	"item_recipe_necronomicon",
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
		elseif ( sNextItem == "item_recipe_necronomicon" ) then
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
