function auriskins.gen_formspec_skins (player)
	local fs = ainv.formspec_base(player)
	fs = fs .. ainv.create_tabs()

	--Labels
	fs = fs .. [[
		label[7,0;Available Skins]
	]]

	local playerdata = auriskins.get_skin_data(player)
	if playerdata.preview then
		fs = fs .. "image[3.5,1;3,6;" .. playerdata.preview .. "]"
	else
		fs = fs .. "image[2.6,2.6;5,2.5;" .. playerdata.skin .. "]"
	end

	fs = fs .. "textlist[7,0.5;4,7;skinlist;"

	for i = 1, auriskins.skinsloaded do
		if auriskins.skindata[i].name then
			fs = fs .. auriskins.skindata[i].name .. " (" .. auriskins.skindata[i].author .. ")"
		else
			fs = fs .. "#ff9999Skin " .. i .. " (No Metadata)"
		end
		if i ~= auriskins.skinsloaded then
			fs = fs .. ","
		end
	end
	
	fs = fs .. "]" .. ainv.formspec_base_end(player)

	return fs
end