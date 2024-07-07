screen = Vector2(guiGetScreenSize())
mods, dowland_mods, all_mods, loading_mod_details = {}, {}, {}, {}

function allDowlandMods()
    for index, value in ipairs(dowland_mods) do
        local file = value.file
		downloadFile(file)
    end
end		

addEvent('mods -> request', true)
addEventHandler('mods -> request', root,
	function(modsTable)
        if modsTable then
            mods, dowland_mods = modsTable, {}
            local deactived_models = loadSetting('mods', 'loader') or toJSON({})
			local deactived_models = fromJSON(deactived_models)
            for index, value in ipairs(mods) do
                if not deactived_models[tostring(value.model)] then
                    table.insert(dowland_mods, value)
                end
            end
            allDowlandMods()
        end
    end
)

addEventHandler("onClientResourceStart",resourceRoot,function()
	triggerServerEvent("mods -> load",localPlayer)
	addEventHandler("onClientRender",root,renderFileDowloadMenu)
end)

addEventHandler('onClientFileDownloadComplete', root,
	function(name, success)
		if (source == resourceRoot) then
			if success then
                local index = table.find(mods, 'file', name)
				if index then 
                    all_mods[name] = true
                    local model = mods[index].model
                    loading_mod_details['name'] = mods[index].name
                    if name:find('.dff') then
                        local dff = engineLoadDFF(name)
                        engineReplaceModel(dff, model)
                    elseif name:find('.txd') then
                        local txd = engineLoadTXD(name)
                        engineImportTXD(txd, model)
                    elseif name:find('.col') then 
                        local col = engineLoadCOL(name)
                        engineReplaceCOL(col, model)
                    end
                    loading_mod_details['close_render'] = getTickCount() + 2000
                end
			end
		end
	end
)		

local w, h = 250, 35
local x, y = (screen.x-w)/2, (screen.y-h)-25

function renderFileDowloadMenu()
    if not dowland_mods then return end
	if next(dowland_mods) then
		local now = getTickCount()
		local count = 0
		for _ in pairs(all_mods) do 
			count = count + 1
		end

        if count == #dowland_mods then 
			if getTickCount() > loading_mod_details['close_render'] then 
                removeEventHandler('onClientRender', root, renderFileDowloadMenu)
			end	
		end

        local percent = math.ceil((count/#dowland_mods)*100)
        local percent_rectangle = math.ceil((count/#dowland_mods)*w-12)

        mainBackground = bringBackTheSvgOrCreateNewOne('mainBackground', w, h, 10, tocolor(255,255,255))
        dxDrawImage(x, y, w, h, mainBackground, 0,0,0, tocolor(15,15,15,200))
        dxDrawImage(x+6, y+6, percent_rectangle, h-12, mainBackground, 0,0,0, tocolor(43,157,156,150))

        if isInBox(x, y, w, h) then
            dxDrawText('%'..percent, x, y+8, x+w, h, tocolor(200,200,200), 1, fonts.medium, 'center')
        else
            dxDrawText(loading_mod_details['name'], x, y+8, x+w, h, tocolor(200,200,200), 1, fonts.medium, 'center')
        end
    end
end