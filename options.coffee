root = exports ? this


# Saves options to localStorage.
wpm = null
beep_freq = null
enable_popup = null

save_options = ->
    wpm.save()
    beep_freq.save()
    enable_popup.save()
    status = document.getElementById("status")
    status.innerHTML = "Options Saved."
    setTimeout(->
        status.innerHTML = ""
    , 750)

# Restores select box state to saved value from localStorage.
restore_options = ->
    wpm = new StoredOption("wpm", "wpm", value_updater("wpm_value"), 20)
    beep_freq = new StoredOption("freq", "beep_freq", value_updater("beep_value"), 600)
    enable_popup = new StoredBoolean("popup", "popup")
    wpm.load()
    beep_freq.load()
    enable_popup.load()

value_updater = (id) ->
    div = document.getElementById(id)
    (value) -> div.innerHTML = value

class StoredOption
    constructor: (id, @storage_key, @databinder, @default_value) ->
        @element = document.getElementById(id)
        @element.onchange = =>
            @databinder(@value())

    save: -> localStorage[@storage_key] = @value()
    load: ->
        @element.value = localStorage[@storage_key] || @default_value
        @databinder(@value())  # initialize
    value: -> @element.value

class StoredBoolean extends StoredOption
    constructor: (id, storage_key) ->
        super(id, storage_key, (value) -> )
    value: -> @element.checked
    load: -> @element.checked = localStorage[@storage_key] != "false"

sample = -> encode("SOS", wpm.value(), beep_freq.value(), enable_popup.value())

document.addEventListener("DOMContentLoaded", () ->
    restore_options()
    document.getElementById("sample").onclick = sample
    document.getElementById("save").onclick = save_options
)
