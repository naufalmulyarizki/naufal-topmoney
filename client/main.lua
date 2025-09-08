RegisterNetEvent('rys:client:showTopMoney', function(data)
    local options = {}
    for i, player in ipairs(data) do
        table.insert(options, {
            title = player.name,
            description = player.money,
            metadata = {
                {label = 'CitizenID', value = player.citizenid}
            }
        })
    end
    lib.registerContext({
        id = 'top_money_menu',
        title = 'Top 10 Terkaya',
        options = options
    })
    lib.showContext('top_money_menu')
end)