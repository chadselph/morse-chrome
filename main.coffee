audioCtx = null

getAudioCtx = ->
    audioCtx ?= new AudioContext()
    audioCtx.resume() if audioCtx.state == "suspended"
    audioCtx

# Fire-and-forget broadcast. Having no listener (e.g. the popup is
# disabled or already closed) is not an error we care about.
broadcast = (message) ->
    try
        chrome.runtime.sendMessage(message)?.catch?(-> )
    catch error
        # extension context torn down mid-playback


class MorseSequence

    constructor: (frequency, delay=0.5) ->
        @_ctx = getAudioCtx()
        @_gain = @_ctx.createGain()
        @_gain.gain.value = 0
        @_cursor = @_ctx.currentTime + delay
        @_oscilator = @_ctx.createOscillator()
        @_oscilator.connect(@_gain)
        @_gain.connect(@_ctx.destination)
        @_oscilator.frequency.value = frequency
        @_oscilator.start(0)
        @_events = []
        @_timer = setInterval(( => @process_event()), 50)

    sequence_silence: (time) ->
        @_cursor += time
    sequence_tone: (time) ->
        @_gain.gain.setValueAtTime(1.0, @_cursor)
        @_cursor += time
        @_gain.gain.setValueAtTime(0.0, @_cursor)
    end: () ->
        @_oscilator.stop(@_cursor)
        @sequence_event( => clearInterval(@_timer))
    sequence_event: (cb) ->
        @_events.push({cb: cb, at: @_cursor})
    process_event: ->
        while @_events.length != 0 && @_events[0].at <= @_ctx.currentTime
            try
                @_events[0].cb()
            catch error
                console.log error
            @_events = @_events.splice(1)


make_durations = (wpm) ->
    unit = 1.2 / wpm # based on PARIS, 50 units, 60s / 50 units
    short_mark: unit * 1
    long_mark: unit * 3
    element_gap: unit * 1
    short_gap: unit * 3
    long_gap: unit * 7


export encode = (text, wpm=20, frequency=600, popup=true) ->
    duration = make_durations(wpm)
    ms = new MorseSequence(frequency)
    text = text.toLowerCase().trim().replace(/\s+/g, " ")
    dit = -> ms.sequence_tone(duration['short_mark'])
    dah = -> ms.sequence_tone(duration['long_mark'])
    space = -> ms.sequence_silence(duration['long_gap'])
    letter_end = -> ms.sequence_silence(duration['short_gap'])

    lookup_sound = make_table dit, dah, space, letter_end
    lookup_symbols = make_table "•", "−", "", ""
    # lookup all the letters
    characters = ([ch, lookup_sound[ch], lookup_symbols[ch]] for ch in text when lookup_sound[ch]?)

    for [ch, sounds, symbols] in characters
        if popup
            do(ch, symbols) ->
                ms.sequence_event( ->
                    broadcast({
                        type: "morse-symbol"
                        ch: ch
                        symbols: (s for s in symbols when s).join(" ")
                    })
                )
        for sound in sounds
            sound()
            ms.sequence_silence(duration['element_gap'])
    ms.sequence_event( -> broadcast({type: "morse-done"}))
    ms.end()


make_table = (dit, dah, space, letter_end) ->
    # dit and dah could anything, depending on
    # what you want your table for
    morse =
        a: [dit, dah, letter_end]
        b: [dah, dit, dit, dit, letter_end]
        c: [dah, dit, dah, dit, letter_end]
        d: [dah, dit, dit, letter_end]
        e: [dit, letter_end]
        f: [dit, dit, dah, dit, letter_end]
        g: [dah, dah, dit, letter_end]
        h: [dit, dit, dit, dit, letter_end]
        i: [dit, dit, letter_end]
        j: [dit, dah, dah, dah, letter_end]
        k: [dah, dit, dah, letter_end]
        l: [dit, dah, dit, dit, letter_end]
        m: [dah, dah, letter_end]
        n: [dah, dit, letter_end]
        o: [dah, dah, dah, letter_end]
        p: [dit, dah, dah, dit, letter_end]
        q: [dah, dah, dit, dah, letter_end]
        r: [dit, dah, dit, letter_end]
        s: [dit, dit, dit, letter_end]
        t: [dah, letter_end]
        u: [dit, dit, dah, letter_end]
        v: [dit, dit, dit, dah, letter_end]
        w: [dit, dah, dah, letter_end]
        x: [dah, dit, dit, dah, letter_end]
        y: [dah, dit, dah, dah, letter_end]
        z: [dah, dah, dit, dit, letter_end]
        1: [dit, dah, dah, dah, dah, letter_end]
        2: [dit, dit, dah, dah, dah, letter_end]
        3: [dit, dit, dit, dah, dah, letter_end]
        4: [dit, dit, dit, dit, dah, letter_end]
        5: [dit, dit, dit, dit, dit, letter_end]
        6: [dah, dit, dit, dit, dit, letter_end]
        7: [dah, dah, dit, dit, dit, letter_end]
        8: [dah, dah, dah, dit, dit, letter_end]
        9: [dah, dah, dah, dah, dit, letter_end]
        0: [dah, dah, dah, dah, dah, letter_end]
        ".": [dit, dah, dit, dah, dit, dah, letter_end]
        ",": [dah, dah, dit, dit, dah, dah, letter_end]
        "?": [dit, dit, dah, dah, dit, dit, letter_end]
        "'": [dit, dah, dah, dah, dah, dit, letter_end]
        "!": [dah, dit, dah, dit, dah, dah, letter_end]
        "/": [dah, dit, dit, dah, dit, letter_end]
        "(": [dah, dit, dah, dah, dit, letter_end]
        ")": [dah, dit, dah, dah, dit, dah, letter_end]
        "&": [dit, dah, dit, dit, dit, letter_end]
        ":": [dah, dah, dah, dit, dit, dit, letter_end]
        ";": [dah, dit, dah, dit, dah, dit, letter_end]
        "=": [dah, dit, dit, dit, dah, letter_end]
        "+": [dit, dah, dit, dah, dit, letter_end]
        "-": [dah, dit, dit, dit, dah, letter_end]
        "_": [dit, dit, dah, dah, dit, dah, letter_end]
        "\\": [dit, dah, dit, dit, dah, dit, letter_end]
        "$": [dit, dit, dit, dah, dit, dit, dah, letter_end]
        "@": [dit, dah, dah, dit, dah, dit, letter_end]
        " ": [space]
