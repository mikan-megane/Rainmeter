
function Initialize()

	msMeasureW8Color = SKIN:GetMeasure('MeasureW8Color')
	msMeasureW8Balance = SKIN:GetMeasure('MeasureW8ColorBalance')

end -- function Initialize

function Update()

		-- Get data from measures

	DecColor = msMeasureW8Color:GetValue()
	ColorBal = msMeasureW8Balance:GetValue()
	
		-- Split for Processing
	
	HexColor = Dec2Hex(DecColor)
	HexRGB = string.sub(HexColor, 3)
	HexAlpha = string.sub(HexColor, 1,2)
	
		-- Processing
	
	HexRGB = BalColor(HexRGB, (ColorBal/100))
	HexRGBInv = InvColor(HexRGB)
	HexRGBAlt = AltColor(HexRGB)

		-- Save Data	
	
	SKIN:Bang("!WriteKeyValue Variables WinColor " .. HexRGB .. SKIN:ReplaceVariables(" #IncFile# "))
	SKIN:Bang("!WriteKeyValue Variables WinAlpha " .. HexAlpha .. SKIN:ReplaceVariables(" #IncFile# "))
	SKIN:Bang("!WriteKeyValue Variables InvColor " .. HexRGBInv .. SKIN:ReplaceVariables(" #IncFile# "))
	SKIN:Bang("!WriteKeyValue Variables AltColor " .. HexRGBAlt .. SKIN:ReplaceVariables(" #IncFile# "))
	
		SetVars()

	return 0

end

function SetVars( Skin )

	if Skin == nil then Skin = " " end
	
	local Config = Skin
	
	SKIN:Bang("!SetVariable WinColor " .. HexRGB .. " " .. Config)
	SKIN:Bang("!SetVariable WinAlpha " .. HexAlpha .. " " .. Config)
	SKIN:Bang("!SetVariable InvColor " .. HexRGBInv .. " " .. Config)
	SKIN:Bang("!SetVariable AltColor " .. HexRGBAlt .. " " .. Config)
	
end  -- SetVars

function Dec2Hex(nValue)
   -- Convert string to number if needed
   if type(nValue) == "string" then
      nValue = String.ToNumber(nValue)
   end
   nHexVal = string.format("%X", nValue)  
   -- Convert number to string
   sHexVal = nHexVal..""
   return sHexVal
end

function InvColor(HexRGBString)

	local R = tonumber( "0x" .. string.sub(HexRGBString, 1,2) ) / 255
	local G = tonumber( "0x" .. string.sub(HexRGBString, 3,4) ) / 255
	local B = tonumber( "0x" .. string.sub(HexRGBString, 5,6) ) / 255
	
	-- print("RGB: " .. R .. " " .. G .. " " .. B)
	
	-- RGB to HSV
    local H,S,V, Delta
	
    local MAX = math.max(R, G, B)
    local MIN = math.min(R, G, B)
	
	V = MAX
	Delta = MAX - MIN
	
	if MAX ~= 0 then
		S = Delta / MAX
		if MAX == R then
			H = (G - B) / Delta
		elseif MAX == G then
			H = 2 + (B - R) / Delta
		else 
			H = 4 + (R - G) / Delta
		end		
	else
		S, H = 0, -1
	end
	
	H = H * 60
	if H < 0 then H = H + 360 end
	
	-- print("HSV: " .. H .. " " .. S .. " " .. V)
	
	-- HSV Invert
	
	H = (H + 180) % 360
	S = 1 - S
	V = 1 - V	
	
	-- HSV to RGB
	
	local Hi = math.floor(H/60)
	local H = H / 60
    local f = H - Hi
    local p = V * (1-S)
    local q = V * (1-f*S)
    local t = V * (1-(1-f)*S)
    if Hi == 0 then
        R = V 
        G = t 
        B = p
    elseif Hi == 1 then
        R = q 
        G = V 
        B = p
    elseif Hi == 2 then
        R = p 
        G = V 
        B = t
    elseif Hi == 3 then
        R = p 
        G = q 
        B = V
    elseif Hi == 4 then
        R = t 
        G = p 
        B = V
    elseif Hi == 5 then
        R = V 
        G = p 
        B = q
    end
	
    R =  math.floor(R * 255)
    G = math.floor(G * 255)
    B =  math.floor(B * 255)
	
	-- print("InvRGB: " .. R .. " " .. G .. " " .. B)
	
	-- And back
	
	local HexR = string.format("%02X", R) .. ""
	local HexG = string.format("%02X", G) .. ""
	local HexB = string.format("%02X", B) .. ""
	
	return HexR .. HexG .. HexB

end

function AltColor(HexRGBString)

	local R = tonumber( "0x" .. string.sub(HexRGBString, 1,2) )
	local G = tonumber( "0x" .. string.sub(HexRGBString, 3,4) )
	local B = tonumber( "0x" .. string.sub(HexRGBString, 5,6) )
	
	-- print("RGB: " .. R .. " " .. G .. " " .. B)
	
    R =  math.floor((R + 127) % 256)
    G = math.floor((G + 127) % 256)
    B =  math.floor((B + 127) % 256)
	
	-- print("AltRGB: " .. R .. " " .. G .. " " .. B)
	
	-- And back
	
	local HexR = string.format("%02X", R) .. ""
	local HexG = string.format("%02X", G) .. ""
	local HexB = string.format("%02X", B) .. ""
	
	return HexR .. HexG .. HexB

end

function BalColor(HexRGBString, Balance)

	local R = tonumber( "0x" .. string.sub(HexRGBString, 1,2) )
	local G = tonumber( "0x" .. string.sub(HexRGBString, 3,4) )
	local B = tonumber( "0x" .. string.sub(HexRGBString, 5,6) )
	
	-- print("RGB: " .. R .. " " .. G .. " " .. B)
	
    R =  math.floor(( (R * (Balance)) + (218 * (1 - Balance)) ) % 256)
    G =  math.floor(( (G * (Balance)) + (218 * (1 - Balance)) ) % 256)
    B =  math.floor(( (B * (Balance)) + (218 * (1 - Balance)) ) % 256)
	
	-- print("BalRGB: " .. R .. " " .. G .. " " .. B)
	
	-- And back
	
	local HexR = string.format("%02X", R) .. ""
	local HexG = string.format("%02X", G) .. ""
	local HexB = string.format("%02X", B) .. ""
	
	return HexR .. HexG .. HexB

end