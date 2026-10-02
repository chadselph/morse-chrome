import {openPopup} from "./popupwin.js"

OFFSCREEN_URL = "offscreen.html"

DEFAULTS =
    wpm: 20
    beep_freq: 600
    popup: true

# Context menus persist across service worker restarts, so creating the
# item at top level would throw a duplicate-id error on every wake-up
# and abort the rest of this module.
chrome.runtime.onInstalled.addListener(->
    chrome.contextMenus.removeAll(->
        chrome.contextMenus.create({
            "id": "play-morse"
            "title": "Play Morse"
            "contexts": ["selection"]
        })
    )
)

chrome.contextMenus.onClicked.addListener((info, tab) ->
    if (info.menuItemId == "play-morse")
        settings = await chrome.storage.local.get(DEFAULTS)
        await getOrCreateOffscreen()
        await openPopup() if settings.popup
        chrome.runtime.sendMessage({
            type: "morse-play"
            text: info.selectionText
            wpm: Number(settings.wpm)
            frequency: Number(settings.beep_freq)
            popup: settings.popup
        })
)

chrome.runtime.onMessage.addListener((message) ->
    closeOffscreen() if message?.type == "morse-done"
    return false
)

creating = null

getOrCreateOffscreen = () =>
    return if await chrome.offscreen.hasDocument()
    if creating?
        await creating
    else
        creating = chrome.offscreen.createDocument({
            url: OFFSCREEN_URL
            reasons: ["AUDIO_PLAYBACK"]
            justification: "Morse code audio playback"
        })
        try
            await creating
        finally
            creating = null

closeOffscreen = () =>
    try
        await chrome.offscreen.closeDocument() if await chrome.offscreen.hasDocument()
    catch error
        # nothing to close (e.g. the options page played the sample itself)
