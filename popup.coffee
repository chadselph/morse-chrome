render = (ch, symbols) ->
    document.body.innerText = ch + "\n" + symbols

chrome.runtime.onMessage.addListener((message) ->
    switch message?.type
        when "morse-symbol" then render(message.ch, message.symbols)
        when "morse-done" then window.close()
    return false
)
