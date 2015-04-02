chrome.contextMenus.create({
    "title": "Play Morse",
    "contexts": ["selection"],
    "onclick": (info, _tab) ->
        wpm = localStorage['wpm']
        frq = localStorage['beep_freq']
        encode(info.selectionText, wpm, frq)
})
