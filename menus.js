chrome.contextMenus.create({
    "title": "Play Morse",
    "contexts": ["selection"],
    "onclick": function (info, _tab) {
        var wpm = localStorage['wpm'];
        var frq = localStorage['beep_freq'];
        encode(info.selectionText, wpm, frq);
    }
});
