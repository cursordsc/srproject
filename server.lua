local mods = {}

addEventHandler("onResourceStart",resourceRoot,function()
	local meta = xmlLoadFile ("meta.xml")
	parseMeta(mods, meta)
end)

addEvent("mods -> load",true);
addEventHandler("mods -> load",root,function()
	triggerLatentClientEvent(client,"mods -> request",client,mods)
end)

function parseMeta(tbl, meta)
	for i, v in ipairs (xmlNodeGetChildren(meta)) do 
		if xmlNodeGetName(v) == "file" then 
			local model = tonumber (xmlNodeGetAttribute(v, "model"));
			local type = tonumber (xmlNodeGetAttribute(v, "type"));
			local name = xmlNodeGetAttribute(v, "name")
			local file = xmlNodeGetAttribute (v, "src");
			local dosya = fileOpen(file)
			local file_size = fileGetSize(dosya)
			fileClose(dosya)
			table.insert (tbl, {name = name, file = file, model = model, file_size = file_size, type = type});	
		end
	end	
end	
