chrome.contextMenus.create({
    "id": "play-morse",
    "title": "Play Morse",
    "contexts": ["selection"]
})

chrome.contextMenus.onClicked.addListener((info, tab) ->
    if (info.menuItemId == "play-morse")
        wpm = localStorage['wpm']
        frq = localStorage['beep_freq']
        popup = localStorage['popup'] != "false"
        encode(info.selectionText, wpm, frq, popup)
)