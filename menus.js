function encode() {
    console.log(arguments);
}
chrome.contextMenus.create({"title": "Play Morse", "contexts": ["selection"], "onclick": encode});
