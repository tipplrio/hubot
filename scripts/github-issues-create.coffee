# Description:
#   Create issues with hubot
#
# Commands:
#   hubot create issue {user}/{repo} #label1,label2# <title> -- <content>
#
# Notes:
#   This script is a fork of `hubot-github-create-issues`, which was originally written by Soulou.
#   Cf. https://github.com/Soulou/hubot-github-create-issues
#
# Author:
#   James G. Kim

githubot = require('githubot')

module.exports = (robot) ->
  robot.respond /create\s+issue\s+(?:(?:for\s+)?((?:\w[\w-]+\/)?[\w-_\.]+)(?:\s+))?(?:(?:#)(.+)(?:#\s+))?(.+)(?:\s+(?:--|—)\s+)(.+)/im, (res) ->
    repo = githubot.qualified_repo res.match[1]
    payload = {}
    payload.labels = res.match[2].replace(/\s*(,)\s*/g, "$1").split(',') if res.match[2]
    payload.title = res.match[3]
    payload.body = res.match[4] if res.match[4]
    url  = "/repos/#{repo}/issues"
    user = res.envelope.user.name

    robot.identity.findToken user, (err, token) ->
      if err
        switch err.type
          when 'github user'
            res.reply "Sorry, you haven't told me your GitHub username."
          else
            res.reply "Oops: #{err}"
      else
        githubot(robot, 'token': token).post url, payload, (issue) ->
          res.reply "I've opened the issue ##{issue.number} for #{user} (#{issue.html_url})"
