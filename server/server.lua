local totalMoney = {}
local webhook = ""

local function sendToDiscord(message)
    local time = os.date("*t")
    local embed = {
        {
            ["color"] = 65352,
            ["author"] = {
                ["icon_url"] = "",
                ["name"] = "Topp Money",  
            },
            ["title"] = "**Uang Terbanyak**",  
            ["description"] = message,
            ["footer"] = {
                ["text"] = '' ..time.year.. '/' ..time.month..'/'..time.day..' '.. time.hour.. ':'..time.min,
            },
        }
    }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Top Money Player", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

local function MoneyFormat(amount)
    local formatted = tostring(amount)
    local function reverse(str)
        return string.reverse(str)
    end
    formatted = reverse(formatted):gsub("(%d%d%d)", "%1,"):reverse()
    if formatted:sub(1, 1) == "," then
        formatted = formatted:sub(2)
    end
    return 'Rp. ' .. formatted
end

local function TopMoney()
    local topRichestPlayers
    local resultWithLicense = ''
    local result = nil

    topRichestPlayers = MySQL.Sync.fetchAll(
        "SELECT `citizenid`, `charinfo`, JSON_VALUE(`money`, '$.cash') + JSON_VALUE(`money`, '$.bank') AS `total_money` FROM `players` ORDER BY `total_money` DESC LIMIT ?", 
        {50}
    )

    for _, v in pairs(topRichestPlayers) do
        local charinfo = json.decode(v.charinfo)
        local full_name = charinfo.firstname .. ' ' .. charinfo.lastname
        totalMoney[#totalMoney+1] = {
            name = full_name,
            total_money = MoneyFormat(v["total_money"])
        }
        resultWithLicense = resultWithLicense .. "`" .. _ .. ". " .. full_name .. " | " .. v["citizenid"] .. " | TOTAL UANG: " .. MoneyFormat(v["total_money"]) .. "`\n"
    end
 
    sendToDiscord(resultWithLicense)
end

lib.addCommand("topmoney", {
    help = "Melihat daftar player terkaya",
    restricted = {'group.admin' }
}, function(source, args, raw)
    local topPlayers = {}
    for i = 1, math.min(10, #totalMoney) do
        table.insert(topPlayers, {
            name = totalMoney[i].name,
            money = totalMoney[i].total_money
        })
    end
    TriggerClientEvent('rys:client:showTopMoney', source, topPlayers)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TopMoney()
    end
end)