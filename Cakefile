{execSync} = require("child_process")
fs = require("fs")

FILES = [
    "icons"
    "manifest.json"
    "offscreen.html"
    "options.html"
    "popup.html"
    "main.js"
    "menu.js"
    "offscreen.js"
    "options.js"
    "popup.js"
    "popupwin.js"
]

task("chrome_dist", "Build the chrome extension to upload to Google", ->
    # Compile first and wait for it: the old async exec() let zip run
    # against stale (or missing) .js files.
    console.log("Compiling CoffeeScript...")
    execSync("coffee -c *.coffee", {stdio: "inherit"})

    missing = (f for f in FILES when not fs.existsSync(f))
    if missing.length
        throw new Error("Refusing to package, missing: " + missing.join(", "))

    fs.rmSync("chromedist.zip", {force: true})
    console.log("Zipping...")
    execSync("zip -r chromedist.zip " + FILES.join(" "), {stdio: "inherit"})
    console.log("Built chromedist.zip")
)
