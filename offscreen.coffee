import {encode} from "./main.js"

chrome.runtime.onMessage.addListener((message) ->
    if message?.type == "morse-play"
        encode(message.text, message.wpm, message.frequency, message.popup)
    return false
)
