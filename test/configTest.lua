--
-- Created by IntelliJ IDEA.
-- User: zhuyu
-- Date: 2018/9/16
-- Time: 20:36
-- To change this template use File | Settings | File Templates.
--
local Path1=""
local Path2=""
local tablePath={}


for line in io.lines("config.txt") do
    table.insert(tablePath,string.sub(line,7,string.len(line)))
end
print(tablePath[1])
print(tablePath[2])
