import {encode} from "./main.js"
import {openPopup} from "./popupwin.js"

# chrome.storage, not localStorage: the service worker needs to read
# these settings and has no access to localStorage.
DEFAULTS =
    wpm: 20
    beep_freq: 600
    popup: true

el = {}

wpm = -> Number(el.wpm.value)
beep_freq = -> Number(el.freq.value)
popup_enabled = -> el.popup.checked

update_labels = ->
    document.getElementById("wpm_value").innerHTML = el.wpm.value
    document.getElementById("beep_value").innerHTML = el.freq.value

restore_options = ->
    settings = await chrome.storage.local.get(DEFAULTS)
    el.wpm.value = settings.wpm
    el.freq.value = settings.beep_freq
    el.popup.checked = settings.popup
    update_labels()

save_options = ->
    await chrome.storage.local.set({
        wpm: wpm()
        beep_freq: beep_freq()
        popup: popup_enabled()
    })
    status = document.getElementById("status")
    status.innerHTML = "Options Saved."
    setTimeout(->
        status.innerHTML = ""
    , 750)

sample = ->
    await openPopup() if popup_enabled()
    encode("SOS", wpm(), beep_freq(), popup_enabled())

document.addEventListener("DOMContentLoaded", ->
    el.wpm = document.getElementById("wpm")
    el.freq = document.getElementById("freq")
    el.popup = document.getElementById("popup")
    el.wpm.onchange = el.wpm.oninput = update_labels
    el.freq.onchange = el.freq.oninput = update_labels
    document.getElementById("sample").onclick = sample
    document.getElementById("save").onclick = save_options
    restore_options()
)
