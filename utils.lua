fonts = {
    medium = exports.el_components:getFont('medium',10),
    robotoBoldBig = exports.el_components:getFont('robotoBold',15),
    FAD = exports.el_components:getFont('FAD',15),
    FAL = exports.el_components:getFont('FAL',15),
	FAL_low = exports.el_components:getFont('FAL',10),
    FAL_med = exports.el_components:getFont('FAL',12),
    FAL_big = exports.el_components:getFont('FAL',35),
    regular = exports.el_components:getFont('regular',11),
    regular_low = exports.el_components:getFont('regular',10),
}

local tempSVG = {}
function bringBackTheSvgOrCreateNewOne(index, width, height, ratio, color1, borderWidth, color2)
    if tempSVG[index] then
        return tempSVG[index]
    else
        local r,g,b,a = bitExtract(color1,16,8),bitExtract(color1,8,8), bitExtract(color1,0,8), bitExtract(color1,24,8)
        local _color1 = string.format('#%.2X%.2X%.2X', r,g,b)
        local r2,g2,b2,a2 = bitExtract((color2 or color1),16,8),bitExtract((color2 or color1),8,8), bitExtract((color2 or color1),0,8), bitExtract((color2 or color1),24,8)
        local _color2 = string.format('#%.2X%.2X%.2X', r2,g2,b2)
        local rawSvgData = [[
            <svg width=']]..(width+0.5)..[[' height=']]..(height+0.5)..[['>
                <rect x='0.5' y='0.5' rx=']]..ratio..[[' ry=']]..ratio..[[' width=']]..(width-0.5)..[[' height=']]..(height-0.5)..[['
                fill=']].._color1..[[' stroke=']].._color2..[[' stroke-width=']]..(borderWidth or 0)..[[' stroke-opacity=']]..(a2/255)..[[' opacity=']]..(a/255)..[[' />
            </svg>
        ]]
        tempSVG[index] = svgCreate(width, height, rawSvgData)
        return tempSVG[index]
    end
end

function isInBox(posX, posY, width, height)
    if isCursorShowing() then
        local MouseX, MouseY = getCursorPosition()
        local clientW, clientH = guiGetScreenSize()
        local MouseX, MouseY = MouseX * clientW, MouseY * clientH
        if (MouseX > posX and MouseX < (posX + width) and MouseY > posY and MouseY < (posY + height)) then
            return true
        end
    end
    return false
end

function table.find(myTable, index, value)
	for i, v in pairs(myTable) do 
		if v[index] == value then 
			return i
		end
	end
	return false
end	

function saveSetting(settingName, settingValue, resName)
	local settingsXML = xmlLoadFile("@settings.xml") or xmlCreateFile("@settings.xml", "settings")
	if not settingsXML then return false end
	
	local resourceName = resName or getResourceName(sourceResource)
	local resourceNode = xmlFindChild(settingsXML, resourceName, 0) or xmlCreateChild(settingsXML, resourceName)
	local settingsNode = xmlFindChild(resourceNode, settingName, 0) or xmlCreateChild(resourceNode, settingName)

	if xmlNodeSetValue( settingsNode, tostring(settingValue) ) and xmlSaveFile(settingsXML) then 
		xmlUnloadFile(settingsXML) 
		return true	
	else
		xmlUnloadFile(settingsXML) 
		return false
	end
end

function loadSetting(settingName, resName)
	local settingsXML = xmlLoadFile("@settings.xml") or xmlCreateFile("@settings.xml", "settings")
	if not settingsXML then return nil end
	
	local resourceName = resName or getResourceName(sourceResource)
	local resourceNode = xmlFindChild(settingsXML, resourceName, 0)
	local settingsNode = resourceNode and xmlFindChild(resourceNode, settingName, 0)
	local settingValue = settingsNode and xmlNodeGetValue(settingsNode)
	
	xmlUnloadFile(settingsXML)
	return convertValue(settingValue) --converts string to a bool or returns string untouched if it isn't a bool
end

function convertValue(value)
	if value == "true" then
		return true
	elseif value == "false" then
		return false
	elseif value then
		return value
	elseif not value then
		return nil 
	end
end

function sizeFormat(size)
	local size = tostring(size)
	if size:len() >= 4 then		
		if size:len() >= 7 then
			if size:len() >= 9 then
				local returning = size:sub(1, size:len()-9)
				if returning:len() <= 1 then
					returning = returning.."."..size:sub(2, size:len()-7)
				end
				return returning.." GB";
			else				
				local returning = size:sub(1, size:len()-6)
				if returning:len() <= 1 then
					returning = returning.."."..size:sub(2, size:len()-4)
				end
				return returning.." MB";
			end
		else		
			local returning = size:sub(1, size:len()-3)
			if returning:len() <= 1 then
				returning = returning.."."..size:sub(2, size:len()-1)
			end
			return returning.." KB";
		end
	else
		return size.." B";
	end
end

function createScrollBar(x, y, w, h, total, maxShow, currentShow, color, color2)
    if(total> maxShow) then
     dxDrawRectangle(x, y, w, h, color)
     dxDrawRectangle(x, y+((currentShow)*(h/(total))), w, h/math.max((total/maxShow),1), color2)
    end
 end