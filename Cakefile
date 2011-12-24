{exec} = require("child_process")

FILES = ["icons", "background.html", "manifest.json", "style.css"]

task("chrome_dist", "Build the chrome extension to upload to Google", ->
    exec("zip -r chromedist.zip " + FILES.join(" "), (err, stdout, stderr) ->
        console.log(stdout + stderr) if stdout or stderr
        throw err if err
    );
    console.log("Running zip command...");
)
