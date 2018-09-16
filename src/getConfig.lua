--
-- Created by IntelliJ IDEA.
-- User: zhuyu
-- Date: 2018/9/16
-- Time: 22:10
-- To change this template use File | Settings | File Templates.
--

local tablePath={}
for line in io.lines("config.txt") do
    table.insert(tablePath,string.sub(line,7,string.len(line)))
end
local oldZhFile =tablePath[1]
local newZhFile =tablePath[2]
local pathList =tablePath[3]
local pathList =tablePath[4]