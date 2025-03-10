URL = "offscreen.html"

chrome.contextMenus.create({
    "id": "play-morse",
    "title": "Play Morse",
    "contexts": ["selection"]
})

chrome.contextMenus.onClicked.addListener((info, tab) ->
    if (info.menuItemId == "play-morse")
        await getOrCreateOffscreen()
        chrome.runtime.sendMessage({
            selectionText: info.selectionText
        })
)

getOrCreateOffscreen = () =>
    if (!(await hasDocument()))
        await chrome.offscreen.createDocument({
            url: URL,
            reasons: ["AUDIO_PLAYBACK"],
            justification: 'Morse code audio playback'
        })

hasDocument = () =>
  matchedClients = await clients.matchAll()
  for client in matchedClients
    if (client.url.endsWith(URL))
      return true;
  return false;