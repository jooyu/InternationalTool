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

--һЩ������̵�ʵ�÷���
toBatPath = function(path)
	return string.gsub(path, "/", "\\")
end

toSimplePath = function(path)
	return string.gsub(path,"//","/")
end

--���ͼƬ��  pvr
imagesToPvr = function(src,des)
	os.execute("toPvr.bat "..toBatPath(TexturePackToolPath).." "..toBatPath(src).." "..toBatPath(des))
end

--ѹ�� ��Դ�� zip
zipRes = function(src,des)
	os.execute("zipRes.bat "..toBatPath(ZipToolPath).." "..src.." "..des)
end

--ѹ������
zipScript = function(path,target,name)
	os.remove(target)
	os.execute("zipScript.bat "..toBatPath(path).." "..toBatPath(target).." "..name)
end

--��������
mixScript = function(path,target,name)
	os.execute("rd /s /q "..toBatPath(target))  --ɾ���ɵ� �ű�
	os.execute("mixScript.bat "..toBatPath(path).." "..toBatPath(target).." "..name)
end

--����lua���� lua����
hanldScript = function(path,target,name)
	if isMixScript then
		mixScript(path,target,"")
	else
		zipScript(path,target,name)
	end
end



--svn ��ȡ�ı��ļ�
pullSvnChangeFile = function(svn,targetPath,fromVer,toVer)
	os.execute("export_svn_changes.py "..svn.." "..toBatPath(targetPath).." "..fromVer.." "..toVer)
end

--�޸� plist�ļ�  ȫ���ĳ�1
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

--���������ļ�
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

--�ж��ļ��������Ƿ����ļ�
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

copy_file = nil    --��������
copy_file = function(srcPath,desPath,without,changeName)
	if string.byte(srcPath,string.len(srcPath)) == 47 then
		srcPath = string.sub(srcPath,1,string.len(srcPath) -1)
	end
	--srcPath = string.gsub(srcPath,"//","/")
	print("����·��:\n��"..srcPath.." \n��"..desPath)
	os.execute("md "..toBatPath(desPath).." >nul 2>nul") --����Ŀ��Ŀ¼
	for file in lfs.dir(srcPath)  do
		if file ~= "." and file ~= ".." then
			local f = srcPath.."/"..file
			if without and table.indexOf(without,f) >= 0 then  --���ų�������   �����п���
            
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

--�ƶ��ļ�
move_file = nil
move_file = function(srcPath,desPath)
	os.execute("md "..toBatPath(desPath).." >nul 2>nul") --����Ŀ��Ŀ¼
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

del_file = nil --ɾ���ļ� ����
del_file = function(path,without)
	for file in lfs.dir(path)  do
		if file ~= "." and file ~= ".." then
			local f = path.."/"..file
			if without and table.indexOf(without,f) >= 0 then  --���ų�������   �����п���
				--print("ɾ���ļ� �ļ���"..f,without[1])
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

--�޸��ļ�
function modifyFile(file,srcStr,desStr)
	local text = readFile(file)
	if text then
		text=string.gsub(text,srcStr,desStr);   --�滻�޸� 
		writeFile(file,text)
	end
end

--lua  �ļ� ����
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

