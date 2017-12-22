# hubot-glassfrog
A hubot script to dynamically process Glassfrog organizational data

## Installation

[The script can be installed via npm.](https://www.npmjs.com/package/hubot-glassfrog)

In your hubot project repo, run:

`npm install hubot-glassfrog --save`

Then add **hubot-glassfrog** to your `external-scripts.json`:

```json
[
  "hubot-glassfrog"
]
```

## Environment Variables

+  `HUBOT_GLASSFROG_APIKEY` - Required, [API key for your Glassfrog organization](https://app.glassfrog.com/api_keys)
+  `HUBOT_GLASSFROG_REFRESHRATE` - Default value is 60, minimum number of seconds allowed between refresh requests

## Usage Example

```
gf = require "hubot-glassfrog"

module.exports = (robot) ->
  
  db = new GlassfrogData()

  #callback passes back err or undefined
  verifyData = (robot, msg, callback) ->
    if db and db.secondsSinceLastRefresh() < env.
      callback(undefined)
    else
      msg.reply "Retrieving glassfrog data :loading:"
      db.refresh robot, callback

  robot.respond /glassfrog domains$/i, (msg) ->
    verifyData robot, msg, (err) ->
      if err
        console.log("There was an issue retrieving glassfrog data for domains")
        console.log(err)
        msg.reply "Sorry, I encountered an error while retrieving glassfrog domain data."
        return

      domains = db.domains
```
