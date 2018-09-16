require("utility")
local amendCfg = nil   --??????????

local pathList = {"C:/Users/Administrator/Desktop/yuenan.txt"}

local languageTranslate = function(path)
	if amendCfg == nil then   
		amendCfg = {}
		local function readLine(str)
			local arr = string.split(str, "\t")
			amendCfg[#amendCfg+1] = {zh=arr[1],wy=arr[2]}
		end
		readFileByLine("????.txt",readLine)

		local s_arr = {"\n","\r","\t","\1","\2","\3","\4"}
		local t_arr = {"\\n","\\r","\\t","\\1","\\2","\\3","\\4"}
		for i=#amendCfg,1 ,-1 do
			if(amendCfg[i].wy == nil) then
				table.remove(amendCfg,i)
			else
				for j,s in ipairs(s_arr) do
					amendCfg[i].zh = string.gsub(amendCfg[i].zh,s,t_arr[j])
					amendCfg[i].wy = string.gsub(amendCfg[i].wy,s,t_arr[j])
				end
				-- if(num>0) then
					-- print("s: ",amendCfg[i].s)
					-- print("t: ",amendCfg[i].t)
				-- end
			end
		end
		table.sort(amendCfg,function(a,b) return string.len(a.zh) > string.len(b.zh) end)
	end
	
	
		local translate = function(file)
			--?????????
			local text = readFile(file)
			local isFix = false
			
			for k,v in ipairs(amendCfg) do
				local pos = 1
				repeat
					local st,sp = string.find(text, v.zh, pos, true)
					if st == nil then
						break
					end
					isFix = true
					text = string.sub(text, 1, st-1)..v.wy..string.sub(text,sp+1,-1)
					pos = sp + 1
					
				until false
			end
			if isFix then  --?и????  ??????д???
				writeFile(file,text)
			end
		end
		print("-???????????У?"..path)
		traverseFiles(path,translate)
	print("-----------------------???????")
end



for i,path in ipairs(pathList) do
	print("?????????",path)
	languageTranslate(path)
end