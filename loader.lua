local gh = 'https://github.com/kederal/lopSecure/blob/main/Games/'

local SupportedGames = {
    [3183403065] = 'Anime-Adventures.lua'
}

for i, v in pairs(SupportedGames) do
    if i == game.PlaceId or i == game.GameId then
        loadstring(game:HttpGet(gh .. v .. '?raw=true'))()
    end
end
