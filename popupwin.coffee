# Shared popup-window management. The offscreen document cannot open
# windows, so whoever triggers playback (service worker or options page)
# opens the popup and the offscreen document just messages it.

popup_window_id = null

chrome.windows.onRemoved.addListener((id) ->
    popup_window_id = null if id == popup_window_id
)

export openPopup = () =>
    if popup_window_id?
        try
            await chrome.windows.update(popup_window_id, {focused: true})
            return popup_window_id
        catch error
            popup_window_id = null
    win = await chrome.windows.create({
        url: "popup.html"
        type: "popup"
        width: 320
        height: 220
    })
    popup_window_id = win.id
    popup_window_id
