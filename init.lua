auriskins = {}
auriskins.file = minetest.get_worldpath() .. "/skins.mt"
auriskins.skindata = {}

auriskins.skinsloaded = 0

local i = 0
while true do
	i = i + 1

	local f = io.open(minetest.get_modpath("auriskins") .. "/textures/char_" .. i .. ".png")
	if not f then break end
	f:close()

	auriskins.skindata[i] = {}
	auriskins.skindata[i].skin = "char_" .. i .. ".png"

	f = io.open(minetest.get_modpath("auriskins") .. "/textures/meta_" .. i .. ".txt")
	if f then
		local d = minetest.deserialize("return {" .. f:read('*all') .. "}")

		if d ~= nil then
			auriskins.skindata[i].name = d.name or ""
			auriskins.skindata[i].author = d.author or ""
		end

		f:close()
	end

	--[[
	THIS PART GENERATES PREVIEWS FROM SKIN FILES INDEPENDANT OF *ANY* EXTERNAL SCRIPS
	How it works:

	'([combine:         16x32 :         -16,-12 =               char_1.png     ^[mask:     auriskins_mask_chest.png)^'
						Size of completed image   Position of part    Image to copy from         Mask for what part of image to copy
	]]

	--Chest
	local skin = '([combine:16x32:-16,-12=char_' .. i .. '.png^[mask:auriskins_mask_chest.png)^'
	--Head
	skin = skin .. '([combine:16x32:-4,-8=char_' .. i .. '.png^[mask:auriskins_mask_head.png)^'
	--Hat
	skin = skin .. '([combine:16x32:-36,-8=char_' .. i .. '.png^[mask:auriskins_mask_head.png)^'
	--Left Arm
	skin = skin .. '([combine:16x32:-44,-12=char_' .. i .. '.png^[mask:auriskins_mask_larm.png)^'
	--Right Arm
	skin = skin .. '([combine:16x32:-44,-12=char_' .. i .. '.png^[mask:auriskins_mask_larm.png^[transformFX)^'
	--Left Leg
	skin = skin .. '([combine:16x32:0,0=char_' .. i .. '.png^[mask:auriskins_mask_lleg.png)^'
	--Right Leg
	skin = skin .. '([combine:16x32:0,0=char_' .. i .. '.png^[mask:auriskins_mask_lleg.png^[transformFX)'

	auriskins.skindata[i].preview = skin
end
auriskins.skinsloaded = i - 1

function auriskins.load()
	local input = io.open(auriskins.file, "r")
	local storedskins = nil
	if input then
		storedskins = input:read('*all')
	end
	if storedskins and storedskins ~= "" then
		auriskins.playerskins = minetest.deserialize(storedskins)
		io.close(input)
	end
end

function auriskins.save()
	local output = io.open(auriskins.file, "w")
	output:write(minetest.serialize(auriskins.playerskins))
	io.close(output)
end

auriskins.playerskins = {}
auriskins.load();

function auriskins.update_skin(player)
	if player and player:is_player() then
		if auriskins.playerskins[player:get_player_name()] then

			local detail = minetest.setting_get("skin_detail")
			if not detail then minetest.setting_set("skin_detail", "1"); detail = "1" end
			detail = tonumber(detail)

			local r = "^[resize:1024x512";
			if detail == 1 then
				r = "^[resize:64x32"
			elseif detail == 2 then
				r = "^[resize:128x64"
			elseif detail == 3 then
				r = "^[resize:256x128"
			elseif detail == 4 then
				r = "^[resize:512x256"
			elseif detail == 0.5 then
				r = "^[resize:32x16"
			end

			local trans = minetest.setting_get("skin_transparency")
			if not trans then minetest.setting_set("skin_transparency", "0"); trans = "0" end
			trans = tonumber(trans)

			local t = ""
			if trans == 0 then
				t = "(auriskins_no_transparency.png" .. r .. ")^"
			end

			local skinval =  t .. "(" .. auriskins.skindata[ auriskins.playerskins[ player:get_player_name() ]].skin .. r .. ")"

			if minetest.get_modpath("3d_armor") then
				--Handle 3D-Armor Layers
				if armor.textures then --Check if loaded
					armor.textures[player:get_player_name()].skin = skinval
					armor:update_player_visuals(player)
				end
			else
				player_api.set_textures(player, {skinval})
			end
			auriskins.save()
		end
	end
end

function auriskins.get_skin_data(player)
	if not auriskins.playerskins[player:get_player_name()] then
		auriskins.set_skin(player, 1) -- ARRAY INDEXES START AT 1
	end
	return auriskins.skindata[auriskins.playerskins[player:get_player_name()]]
end

function auriskins.set_skin(player, skin)
	auriskins.playerskins[player:get_player_name()] = skin
	auriskins.update_skin(player)
end

minetest.register_on_joinplayer(function(player)
	if not auriskins.playerskins[player:get_player_name()] then
		auriskins.set_skin(player, 1) -- ARRAY INDEXES START AT 1
	end
	auriskins.update_skin(player)
	minetest.after(3, function(player) auriskins.update_skin(player) end, player)
	minetest.after(5, function(player) auriskins.update_skin(player) end, player)
end)

minetest.register_chatcommand("skin", {
	params = "<skinid>",
	func = function(name, param)
		local ind = tonumber(param)
		if ind and ind > 0 and ind <= #auriskins.skindata then
			auriskins.set_skin(minetest.get_player_by_name(name), ind) -- ARRAY INDEXES START AT 1
			-- auriskins.update_skin(minetest.get_player_by_name(name))
		end
	end,
})