require("utility")

require("getConfig")
-- local pathList = {"../../../client/project/game/scripts","../../../client/project/game/update","../../../client/project/game/res/uilayer/zh_cn"
					-- ,"../../../client/project/game/res/config"}

--local tablePath={}
--for line in io.lines("config.txt") do
--	table.insert(tablePath,string.sub(line,7,string.len(line)))
--end
--local oldZhFile =tablePath[1]
--local newZhFile =tablePath[2]
--local pathList =tablePath[3]

local oldMap = {}

local function readLine(str)
	oldMap[str] = true
end
readFileByLine(oldZhFile,readLine)

for str,a in pairs(oldMap) do
	print(str)
	break
end

local zhList = {}
local function getWord(f)
	local str = readFile(f)
	local pos = 1
	local length = str:len()
	local curZH = nil
	local midd = nil
	
	while pos <= length do
		
		local l = 1
		local isZH = nil
		local sbyte = string.byte(str, pos)
		if sbyte > 0xFB then
			l = 6
			isZH = true
		elseif sbyte > 0xF7 then
			l = 5
			isZH = true
		elseif sbyte > 0xEF then
			l = 4
			isZH = true
		elseif sbyte > 0xDF then
			l = 3
			isZH = true
		elseif sbyte > 0x7F then
			l = 2
			isZH = true
		else
			
		end
		if isZH then
			if curZH then
				if midd then
					if midd == '"' then
						print("fuck")
					end
					curZH = curZH ..midd.. str:sub(pos , pos+l-1)
					midd = nil
				else
					curZH = curZH .. str:sub(pos , pos+l-1)
				end
			else
				if pos > 10 and str:sub(pos-10,pos-1) == "CCLuaLog(\""then
					curZH = "-"..str:sub(pos , pos+l-1)
				elseif pos > 7 and str:sub(pos-7,pos-1) == "print(\"" then
					curZH = "-"..str:sub(pos , pos+l-1)
				elseif pos > 2 and str:sub(pos-2,pos-1) == "//" then
					curZH = "-"..str:sub(pos , pos+l-1)
				else
					curZH = str:sub(pos , pos+l-1)
				end
			end
		else
			if curZH then
				local addMidd = str:sub(pos , pos+l-1)
				if string.find(addMidd,'"') ~= nil then
					sbyte = 10
				end

				if midd or sbyte == 10 or sbyte == 13 then
					if sbyte == 10 or sbyte == 13 or (midd:len() >4) or (string.find(midd,'"') ~= nil) then
						if not oldMap[curZH] then
							if not aa then
								print("22",curZH)
								aa = 1
							end
						
							zhList[#zhList+1] = curZH
						end
						curZH = nil
						midd = nil
					else
						midd = midd .. str:sub(pos , pos+l-1)
					end
				else
					if midd == '"' then
						print("aaaaaaa   ",midd, string.find(midd,'"'))
					end
					midd = str:sub(pos , pos+l-1)
				end
			end
		end
		pos = pos + l
	end
	if curZH then
		if not oldMap[curZH] then
			if not aa then
				print("22",curZH)
				aa = 1
			end
			zhList[#zhList+1] = curZH
		end
	end
end

for i,path in ipairs(pathList) do
	print("正在提取：",path)
	traverseFiles(path,getWord)
end
	
local zhMap = {}

for i= #zhList,1,-1 do
	local str = zhList[i]
	if not zhMap[str] then
		zhMap[str] = true
		if not str or str == "" or str == "：" or str:sub(1,1) == "-" then
			table.remove(zhList,i)
		end
	else
		table.remove(zhList,i)
	end
end

local str = table.concat(zhList,"\n")
writeFile(newZhFile,str)