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

	f = io.open(minetest.get_modpath("auriskins") .. "/textures/preview_" .. i .. ".png")
	if f then
		auriskins.skindata[i].preview = "preview_" .. i .. ".png"
		f:close()
	else
		auriskins.skindata[i].preview = nil
	end
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
	if player and auriskins.playerskins[player:get_player_name()] then
		if minetest.get_modpath("3d_armor") then
			--Handle 3D-Armor Layers
			if armor.textures then --Check if loaded

				armor.textures[player:get_player_name()].skin = 
					auriskins.skindata[ auriskins.playerskins[ player:get_player_name() ] ].skin

				armor:update_player_visuals(player)
			end
		else
			player_api.set_textures(player, {auriskins.skindata[auriskins.playerskins[player:get_player_name()]].skin})
		end
		auriskins.save()
	end
end

function auriskins.get_skin_data(player)
	return auriskins.skindata[auriskins.playerskins[player:get_player_name()]]
end

function auriskins.set_skin(player, skin)
	auriskins.playerskins[player:get_player_name()] = skin
	auriskins.update_skin(player:get_player_name())
end

minetest.register_on_joinplayer(function(player)
	if auriskins.playerskins[player:get_player_name()] ~= nil then
		auriskins.update_skin(player)
	end
end)

minetest.register_chatcommand("skin", {
	params = "<skinid>",
	func = function(name, param)
		auriskins.playerskins[name] = param
		auriskins.update_skin(minetest.get_player_by_name(name))
	end,
})