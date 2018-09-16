require"lfs"

function string.split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if(delimiter == '') then return false end
	local pos, arr = 0, {}
	-- for each divider found
	for st, sp in function() return string.find(input, delimiter, pos, true) end do
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(input, pos))
	return arr
end

--一些打包过程的实用方法
toBatPath = function(path)
	return string.gsub(path, "/", "\\")
end

toSimplePath = function(path)
	return string.gsub(path,"//","/")
end

--打包图片成  pvr
imagesToPvr = function(src,des)
	os.execute("toPvr.bat "..toBatPath(TexturePackToolPath).." "..toBatPath(src).." "..toBatPath(des))
end

--压缩 资源成 zip
zipRes = function(src,des)
	os.execute("zipRes.bat "..toBatPath(ZipToolPath).." "..src.." "..des)
end

--压缩代码
zipScript = function(path,target,name)
	os.remove(target)
	os.execute("zipScript.bat "..toBatPath(path).." "..toBatPath(target).." "..name)
end

--混淆代码
mixScript = function(path,target,name)
	os.execute("rd /s /q "..toBatPath(target))  --删除旧的 脚本
	os.execute("mixScript.bat "..toBatPath(path).." "..toBatPath(target).." "..name)
end

--处理lua代码 lua配置
hanldScript = function(path,target,name)
	if isMixScript then
		mixScript(path,target,"")
	else
		zipScript(path,target,name)
	end
end



--svn 拉取改变文件
pullSvnChangeFile = function(svn,targetPath,fromVer,toVer)
	os.execute("export_svn_changes.py "..svn.." "..toBatPath(targetPath).." "..fromVer.." "..toVer)
end

--修改 plist文件  全部改成1
changePlist = function(path)
	os.execute("PlistChangeCmd.exe "..toBatPath(path))
end

function table.indexOf(list, target)
	for i,v in ipairs(list) do
		if v == target then
			return i
		end
	end
	return -1
end

function writeFile(file_name,content)
	local f = assert(io.open(file_name, 'w'))
	f:write(content)
	f:close()
end


function readFile(file_name)
  local f = assert(io.open(file_name, 'r'))
  local content = f:read("*all")
  f:close()
  return content
end

function readFileByLine(file_name,readFun)
	local f = assert(io.open(file_name, 'r'))
	repeat
		local content = f:read("*l")
		if content == nil then
			break
		end
		readFun(content)
	until false
	f:close()
end

--遍历处理文件
traverseFiles = nil
traverseFiles = function(path,handle)
	for file in lfs.dir(path)  do
		if file ~= "." and file ~= ".." then
			local f = path.."/"..file
			local attr = lfs.attributes(f)
			if attr.mode == "directory" then
				traverseFiles(f,handle)
			else
				handle(f)
			end
		end
	end
end

--判断文件夹里面是否有文件
hasFile = nil
hasFile = function(path)
	for file in lfs.dir(path)  do
		if file ~= "." and file ~= ".." then
			local f = path.."/"..file
			local attr = lfs.attributes(f)
			if attr.mode == "directory" then
				if hasFile(f) then
					return true
				end
			else
				return true
			end
		end
	end
	return false
end

copy_file = nil    --拷贝方法
copy_file = function(srcPath,desPath,without,changeName)
	if string.byte(srcPath,string.len(srcPath)) == 47 then
		srcPath = string.sub(srcPath,1,string.len(srcPath) -1)
	end
	--srcPath = string.gsub(srcPath,"//","/")
	print("拷贝路径:\n从"..srcPath.." \n到"..desPath)
	os.execute("md "..toBatPath(desPath).." >nul 2>nul") --创建目标目录
	for file in lfs.dir(srcPath)  do
		if file ~= "." and file ~= ".." then
			local f = srcPath.."/"..file
			if without and table.indexOf(without,f) >= 0 then  --在排除名单外   不进行拷贝
            
			else
				local attr = lfs.attributes(f)
				if attr.mode == "directory" then
					local des_path = desPath.."/"..file
					copy_file(f,des_path,without,changeName)
				else
					local des_file = desPath.."/"..file
					if changeName then
						if string.find(des_file,changeName.path) then
							des_file = string.gsub(des_file, changeName.src, changeName.des)
						end
					end
					os.execute("copy /y "..toBatPath(f).." "..toBatPath(des_file).." >nul")
				end
			end
		end
	end
end

--移动文件
move_file = nil
move_file = function(srcPath,desPath)
	os.execute("md "..toBatPath(desPath).." >nul 2>nul") --创建目标目录
	for file in lfs.dir(srcPath)  do
		if file ~= "." and file ~= ".." then
			local f = srcPath.."/"..file
			local attr = lfs.attributes(f)
			if attr.mode == "directory" then
				local des_path = desPath.."/"..file
				move_file(f,des_path)
			else
				local des_file = desPath.."/"..file
				os.execute("move /y "..toBatPath(f).." "..toBatPath(des_file).." >nul")
			end
		end
	end
end

del_file = nil --删除文件 方法
del_file = function(path,without)
	for file in lfs.dir(path)  do
		if file ~= "." and file ~= ".." then
			local f = path.."/"..file
			if without and table.indexOf(without,f) >= 0 then  --在排除名单外   不进行拷贝
				--print("删除文件 文件："..f,without[1])
			else
				local attr = lfs.attributes(f)
				if attr.mode == "directory" then
					del_file(f,without)
				else
					os.remove(f)
				end
			end
		end
	end
	lfs.rmdir(path)
end

--修改文件
function modifyFile(file,srcStr,desStr)
	local text = readFile(file)
	if text then
		text=string.gsub(text,srcStr,desStr);   --替换修改 
		writeFile(file,text)
	end
end

--lua  文件 处理
function vardump(object, label, returnTable)
    local lookupTable = {}
    local result = {}
 
    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end
 
    local function _vardump(object, label, indent, nest)

        label = label or ""
        local postfix = ""
        if nest > 1 then postfix = "," end
        if type(object) ~= "table" then
            if type(label) == "string" then
                result[#result +1] = string.format("%s[\"%s\"] = %s%s", indent, label, _v(object), postfix)
            else
                result[#result +1] = string.format("%s%s%s", indent, _v(object), postfix)
            end
        elseif not lookupTable[object] then
            lookupTable[object] = true
 
            if type(label) == "string" then
                result[#result +1 ] = string.format("%s%s = {", indent, label)
            else
                result[#result +1 ] = string.format("%s{", indent)
            end
            local indent2 = indent .. "    "
            local keys = {}
            local values = {}
            for k, v in pairs(object) do
                keys[#keys + 1] = k
                values[k] = v
            end
            table.sort(keys, function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                else
                    return tostring(a) < tostring(b)
                end
            end)
            for i, k in ipairs(keys) do
                _vardump(values[k], k, indent2, nest + 1)
            end
            
            result[#result +1] = string.format("%s}%s", indent, postfix)
        end
    end
    _vardump(object, label, "", 1)
 
    if returnTable then return result end
    return table.concat(result, "\n")
end

