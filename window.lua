local w, h = 600, 370
local x, y = (screen.x-w)/2, (screen.y-h)/2
local allCounter = 0
local mod_loader_menu = {}
local mod_loader_details = {}
local deactived_models = {}
local pages = {
    {'Araçlar', 'vehicles'},
    {'Kıyafetler', 'skins'},
    {'Silahlar', 'weapons'},
}

local currentRow, maxShowing, allCount = 0, 7, 0
mod_loader_details.page_name = pages[1][2]
mod_loader_details.lastClick = 0
mod_loader_details.menu = 'none'
 
function openModLoader()
    if mod_loader_details.menu == 'none' then
        if getElementData(localPlayer, 'loggedin') == 1 and not getPedOccupiedVehicle(localPlayer) then
		if getElementData(localPlayer, "adminduty") == 1 then return false end
            mod_loader_details.menu = 'open'
            mod_loader_details.tick = getTickCount()
            addEventHandler('onClientKey', root, onClientScroll)
            addEventHandler('onClientRender', root, renderModLoaderMenu)
            deactived_models = loadSetting('mods', 'loader') or toJSON({})
            deactived_models = fromJSON(deactived_models)

            mod_loader_menu = {}
            for index, value in ipairs(mods) do
                if not mod_loader_menu[value.name] then
                    mod_loader_menu[value.name] = value
                    mod_loader_menu[value.name]['status'] = not deactived_models[tostring(value.model)]
                    mod_loader_menu[value.name]['type'] = value.file:find('vehicles') and 'vehicles' or value.file:find('skins') and 'skins' or value.file:find('weapons') and 'weapons' or 'weapons'
                end
            end
        end
    else
        mod_loader_details.menu = 'close'
        mod_loader_details.tick = getTickCount()
    end
end
bindKey('f5', 'down', openModLoader)

function getRealSize(model)
    local file_size = 0
    for index, value in ipairs(mods) do
		if value.model == model then
			file_size = file_size + value.file_size
		end
    end
    return sizeFormat(file_size)
end

function renderModLoaderMenu()

    local duration = ( getTickCount( ) - mod_loader_details.tick ) / 200

    if mod_loader_details.menu == 'open' then
        alpha = interpolateBetween( 15, 0, 0, 240, 0, 0, duration, 'Linear' )
        alpha_low = interpolateBetween( 15, 0, 0, 150, 0, 0, duration, 'Linear' )
    elseif mod_loader_details.menu == 'close' then
        alpha = interpolateBetween( 240, 0, 0, 15, 0, 0, duration, 'Linear' )
        alpha_low = interpolateBetween( 150, 0, 0, 15, 0, 0, duration, 'Linear' )
        if duration >= 1 then
            removeEventHandler('onClientKey', root, onClientScroll)
            removeEventHandler('onClientRender', root, renderModLoaderMenu)
            mod_loader_details.menu = 'none'
        end
    end
	
	if getPedOccupiedVehicle(localPlayer) then
			removeEventHandler('onClientKey', root, onClientScroll)
			removeEventHandler('onClientRender', root, renderModLoaderMenu)
            mod_loader_details.menu = 'none'
		return false
	end

    mainWindow = bringBackTheSvgOrCreateNewOne('mainWindow', w, h, 10, tocolor(255,255,255))
    dxDrawImage(x, y, w, h, mainWindow, 0,0,0, tocolor(15,15,15,alpha))

    dxDrawText('', x+17, y+23, w, h, tocolor(225,225,225,alpha), 1, fonts.FAL)
    dxDrawText('Mod Yöneticisi', x+52, y+14, 0, 0, tocolor(225,225,225,alpha), 1, fonts.robotoBoldBig)
    dxDrawText('Fps konusunda sorun yaşıyorsanız sağ üstten tüm modları kapatın.', x+52,y+40,0,0, tocolor(225,225,225,alpha), 1, fonts.regular_low)

    pages_bubble = bringBackTheSvgOrCreateNewOne('pages_bubble', 100, 30, 15, tocolor(255,255,255))

    for counter, value in ipairs(pages) do
        if isInBox(x-63+(counter*110), y+65, 100, 30) or mod_loader_details.page_name == value[2] then
            dxDrawImage(x-63+(counter*110), y+65, 100, 30, pages_bubble, 0,0,0, tocolor(43,157,156,alpha_low))
            if isInBox(x-63+(counter*110), y+65, 100, 30) then
                if getKeyState('mouse1') and mod_loader_details.lastClick+100 <= getTickCount() then
                    mod_loader_details.lastClick = getTickCount()
                    mod_loader_details.page_name = value[2]
                    currentRow = 0
                end
            end
        else
            dxDrawImage(x-63+(counter*110), y+65, 100, 30, pages_bubble, 0,0,0, tocolor(25,25,25,alpha))
        end
        dxDrawText(value[1], x-12+(counter*110), y+70, x-12+(counter*110), 30, tocolor(200,200,200,alpha), 1, fonts.medium, 'center')        
    end

    backWindow = bringBackTheSvgOrCreateNewOne('backWindow', 550, 245, 10, tocolor(255,255,255))
    dxDrawImage(x+25, y+105, 550, 245, backWindow, 0,0,0, tocolor(25,25,25,alpha))
    dxDrawText('#             İsmi                                                                                                                       Dosya Boyutu', x+40, y+113, 0, 0, tocolor(225,225,225,alpha), 1, fonts.medium)

    buttonBackground = bringBackTheSvgOrCreateNewOne('buttonBackground', 50, 50, 10, tocolor(255,255,255))

    local counter = 0
    allCounter = 0
    local y = y - 12
    for index, value in pairs(mod_loader_menu) do
        if mod_loader_details.page_name == value.type then
            allCounter = allCounter + 1
            if allCounter > currentRow and counter < maxShowing then
                counter = counter + 1

                if isInBox(x+25, y+125+(counter*30), 550, 30) then
                    dxDrawText(value.name, x+75, y+125+(counter*30), 0, 0, tocolor(225,225,225,100), 1, fonts.regular_low)
                    dxDrawText(getRealSize(value.model), x+w-90, y+125+(counter*30), x+w-90, 0, tocolor(225,225,225,100), 1, fonts.regular_low, 'center')  
                    if getKeyState('mouse1') and mod_loader_details.lastClick+300 <= getTickCount() then
                        mod_loader_details.lastClick = getTickCount()
                        toggleMods(value)
                    end
                else
                    dxDrawText((value.name)..' ('..value.model..')', x+75, y+125+(counter*30), 0, 0, tocolor(225,225,225,alpha), 1, fonts.regular_low)
                    dxDrawText(getRealSize(value.model), x+w-90, y+125+(counter*30), x+w-90, 0, tocolor(225,225,225,alpha), 1, fonts.regular_low, 'center')  
                end
                dxDrawText('', x+40, y+125+(counter*30), 0, 0, value.status and tocolor(50,150,50,alpha) or tocolor(150,50,50,alpha), 1, fonts.FAL_med) 

                dxDrawRectangle(x+25, y+120+(counter*30), 550, 1, tocolor(150,150,150,math.min(alpha,25)))
            end
        end
    end 

    createScrollBar(x + w - 29, y + 153, 2, h-170, allCounter, maxShowing, currentRow, tocolor(76,76,76), tocolor(150,150,150))

    local y = y + 10
    
    if isInBox(x+w-45,y+10,35,35) then
        dxDrawImage(x+w-45,y+10,35,35, buttonBackground, 0,0,0, tocolor(150,50,50,alpha))
        if getKeyState('mouse1') and mod_loader_details.lastClick+100 <= getTickCount() then
            mod_loader_details.lastClick = getTickCount()
            toggleAllMods(false)
        end
    else
        dxDrawImage(x+w-45,y+10,35,35, buttonBackground, 0,0,0, tocolor(25,25,25,alpha))
    end
    dxDrawText('', x+w-35,y+18,_,_, tocolor(200,200,200,alpha), 1, fonts.FAL_low)

    local x = x - 40

    if isInBox(x+w-45,y+10,35,35) then
        dxDrawImage(x+w-45,y+10,35,35, buttonBackground, 0,0,0, tocolor(50,100,50,alpha))
        if getKeyState('mouse1') and mod_loader_details.lastClick+100 <= getTickCount() then
            mod_loader_details.lastClick = getTickCount()
            toggleAllMods(true)
        end
    else
        dxDrawImage(x+w-45,y+10,35,35, buttonBackground, 0,0,0, tocolor(25,25,25,alpha))
    end
    dxDrawText('', x+w-37,y+18,_,_, tocolor(200,200,200,alpha), 1, fonts.FAL_low)

end

function toggleMods(mods_details)
    deactived_models = loadSetting('mods', 'loader') or toJSON({})
    deactived_models = fromJSON(deactived_models)
    if mods_details.status then
        engineRestoreModel(mods_details.model)
        deactived_models[tostring(mods_details.model)] = true
    else
        downloadFile('files/'..(mods_details.type)..'/'..mods_details.model..'.txd')
        downloadFile('files/'..(mods_details.type)..'/'..mods_details.model..'.dff')
        deactived_models[tostring(mods_details.model)] = nil
    end
    mods_details.status = not mods_details.status
    saveSetting('mods', toJSON(deactived_models), 'loader')
end

function toggleAllMods(state)
    if state then
        for index, value in pairs(deactived_models) do
            local location = table.find(mods, 'model', tonumber(index))
            if mods[location] then
                downloadFile('files/'..(mods[location].type)..'/'..mods[location].model..'.txd')
                downloadFile('files/'..(mods[location].type)..'/'..mods[location].model..'.dff')
                deactived_models[tostring(index)] = nil
                mods[location].status = true
            end
        end
		exports.el_alert:addBox('success', 'Başarıyla tüm modları açık hale getirdiniz.')
    else
        for index, value in pairs(mod_loader_menu) do
            engineRestoreModel(value.model)
            deactived_models[tostring(value.model)] = true
            mod_loader_menu[index].status = false
        end 
		exports.el_alert:addBox('success', 'Başarıyla tüm modları kapalı hale getirdiniz.')
    end
    saveSetting('mods', toJSON(deactived_models), 'loader')
end

function onClientScroll(button,state)
    if button == 'mouse_wheel_down' or button == 'arrow_d' then
        if (currentRow + maxShowing) < allCounter then
            currentRow = currentRow +1
        end	
    elseif button == 'mouse_wheel_up' or button == 'arrow_u' then
        if currentRow >= 1 then
            currentRow = currentRow -1
        end
    end
end

function createScrollBar(x, y, w, h, total, maxShow, currentShow, color, color2)
    if(total> maxShow) then
        dxDrawRectangle(x, y, w, h, color)
        dxDrawRectangle(x, y+((currentShow)*(h/(total))), w, h/math.max((total/maxShow),1), color2)
    end
end
