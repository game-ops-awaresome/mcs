----------------------------------------
--$Id: power_log_mgr.lua 88866 2016-01-26 07:28:41Z xiongyunkun $
----------------------------------------
--[[
-- 消费日志查询
--
--]]

--钻石金币操作面板展示
function LogShow(self)
	local Options = GetQueryArgs()
	Options.StartTime = Options.StartTime or os.date("%Y-%m-%d %H:%M:%S",ngx.time() - 86400)
	Options.EndTime = Options.EndTime or os.date("%Y-%m-%d %H:%M:%S",ngx.time())
	
	local Platforms = CommonFunc.GetPlatformList()
	--获得服务器列表
	local Servers = CommonFunc.GetServers(Options.PlatformID)
	local Filters = {
		{["Type"] = "Platform",},
		{["Type"] = "Host",},
		{["Type"] = "label",["Text"] = "角色ID:"},
		{["Type"] = "text",["Name"] = "Uid", ["Placeholder"] = "角色ID"},
		{["Type"] = "label",["Text"] = "角色名:"},
		{["Type"] = "text",["Name"] = "Name", ["Placeholder"] = "角色名"},
		{["Type"] = "<br>",},
		{["Type"] = "StartTime",["Format"] = "yyyy-MM-dd HH:mm:ss"},
		{["Type"] = "EndTime", ["Format"] = "yyyy-MM-dd HH:mm:ss"},
		{["Type"] = "Export",},
	}
	--展示数据
	local Titles = {"时间", "平台", "服", "角色ID", "角色名", "体力变化量", '操作后体力', '系统', "渠道", "物品", "数量"}
	local PlatformStr = PlatformID and Platforms[Options.PlatformID] or "all"
	local SeverMap = CommonFunc.GetServers(PlatformID)
	local TableData = {}
	
	if Options.PlatformID and Options.PlatformID ~= "" and Options.HostID and Options.HostID ~= "" then
		local CoinLogList = PowerLogData:Get(Options.PlatformID, Options)
		if #CoinLogList >= 5000 then
			ExtMsg = "数据量太大，请缩小查询范围后查询"
			DataTable = {
				["ID"] = "logTable",
				["DisplayLength"] = 50,
			}
			Viewer:View("template/log/consume_log_list.html")
			return
		end
		for _, CoinLog in ipairs(CoinLogList) do
			if CoinLog.Reason and CoinLog.Reason ~= "" then
				local Data = {}
				table.insert(Data, CoinLog.Time)
				table.insert(Data, Options.PlatformID and Platforms[Options.PlatformID] or "all")
				table.insert(Data, Options.HostID and Servers[tonumber(Options.HostID)] or "all")
				table.insert(Data, CoinLog.Uid)
				table.insert(Data, CoinLog.Name)
				table.insert(Data, CoinLog.DPower)
				table.insert(Data, CoinLog.Power)
				local Names = string.split(CoinLog.Reason, "_")
				table.insert(Data, Names[1])
				table.insert(Data, Names[2] or Names[#Names])
				table.insert(Data, Names[3] or Names[#Names])
				table.insert(Data, 1)
				table.insert(TableData, Data)
			end
		end
		if Options.Submit == "导出" then
			local ExcelStr = CommonFunc.ExportExcel("消费日志.xls", Titles, TableData)
			ngx.say(ExcelStr)
			return
		end
	end
	local DataTable = {
		["ID"] = "logTable",
		["DisplayLength"] = 50,
	}
	local Params = {
		Options = Options,
		Platforms = Platforms,
		Servers = Servers,
		Filters = Filters,
		Titles = Titles,
		TableData = TableData,
		DataTable = DataTable,
	}
	Viewer:View("template/log/consume_log_list.html", Params)
end

DoRequest()
