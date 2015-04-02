root = exports ? this


# Saves options to localStorage.
wpm = null
beep_freq = null

save_options = ->
    wpm.save()
    beep_freq.save()
    status = document.getElementById("status")
    status.innerHTML = "Options Saved."
    setTimeout(->
        status.innerHTML = ""
    , 750)

# Restores select box state to saved value from localStorage.
restore_options = ->
    wpm = new StoredOption("wpm", "wpm", value_updater("wpm_value"))
    beep_freq = new StoredOption("freq", "beep_freq", value_updater("beep_value"))
    wpm.load()
    beep_freq.load()

value_updater = (id) ->
    div = document.getElementById(id)
    (value) -> div.innerHTML = value

class StoredOption
    constructor: (id, storage_key, databinder) ->
        this.databinder = databinder
        this.element = document.getElementById(id)
        this.element.onchange = ->
            databinder(this.value)
        this.storage_key = storage_key

    save: -> localStorage[this.storage_key] = this.value()
    load: ->
        this.element.value = localStorage[this.storage_key]
        this.databinder(this.element.value)  # initialize
    value: -> return this.element.value

sample = -> encode("SOS", wpm.value(), beep_freq.value())

document.addEventListener("DOMContentLoaded", () ->
    restore_options()
    document.getElementById("sample").onclick = sample
    document.getElementById("save").onclick = save_options
)
