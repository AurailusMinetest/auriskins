local path = minetest.get_modpath("auriskins")

dofile(path .. "/formspecs/formspec_skins.lua")

ainv.register_inventory_screen("skins", auriskins.gen_formspec_skins, {
	name = "Skins",
	image = "auriinventory_tab_icon_12.png",
	image_hover = "auriinventory_tab_icon_13.png"
})

ainv.register_callback("skins", function (player, fields)
	if fields.skinlist then
			local datatable = minetest.explode_textlist_event(fields.skinlist)
			if datatable.type == "CHG" then
				auriskins.playerskins[player:get_player_name()] = datatable.index
				auriskins.update_skin(player)
				ainv.reloadInventory(player)
				return false --End iterating
			end
		end
end)