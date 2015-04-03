{exec} = require("child_process")

FILES = ["icons", "background.html", "manifest.json", "options.html", "main.js", "options.js", "menu.js"]

task("chrome_dist", "Build the chrome extension to upload to Google", ->
    exec("coffee -c *.coffee")
    exec("zip -r chromedist.zip " + FILES.join(" "), (err, stdout, stderr) ->
        console.log(stdout + stderr) if stdout or stderr
        throw err if err
    );
    console.log("Running zip command...");
)
