# Description:
#  Create pull request from develop to master.
#
# Dependencies:
#   "githubot": "0.4.x"
#
# Configuration:
# HUBOT_GITHUB_TOKEN
# HUBOT_GITHUB_USER
# HUBOT_GITHUB_ORG
# HUBOT_DEPLOY_MESSAGE
# HUBOT_NO_DIFFERENCE_MESSAGE
# HUBOT_PR_EXISTS_MESSAGE
# HUBOT_BRANCH_FROM
# HUBOT_BRANCH_TO
#
# Commands:
#   hubot deploy <repo>
#
# Author:
#   ryonext
#   nozayasu

module.exports = (robot) ->
  github = require("githubot")(robot)

  createPullRequest = (url, data) ->
    github.post url, data, (response) ->
      commits_url = "#{response.commits_url}?per_page=100"
      github.get commits_url, (commits) ->
        pr_body = "These PRs will be released.\n"
        for commit in commits
          unless commit.commit.message.match(/Merge pull request/)
            continue
          pr_body += "- [ ] #{commit.commit.message.replace(/\n\n/g, ' ').replace(/Merge pull request /, '')} by @#{commit.author.login}\n"

        update_data = { body: pr_body }
        github.patch response.url, update_data, (update_response) ->
          msg.send process.env.HUBOT_DEPLOY_MESSAGE || "Ship it!"
          msg.send update_response.html_url

  updatePrSummary = (url, msg) ->
    github.get url, (response) ->
      commits_url = "#{response.commits_url}?per_page=100"
      github.get commits_url, (commits) ->
        pr_body = "These PRs will be released.\n"
        for commit in commits
          unless commit.commit.message.match(/Merge pull request/)
            continue
          pr_body += "- [ ] #{commit.commit.message.replace(/\n\n/g, ' ').replace(/Merge pull request /, '')} by @#{commit.author.login}\n"

        update_data = { body: pr_body }
        github.patch response.url, update_data, (update_response) ->
          msg.send "updated PR summary"
          msg.send update_response.html_url

  robot.respond /deploy ?(.+)/i, (msg) ->
    github.handleErrors (response) ->
      if response.body.indexOf("No commits") > -1
          msg.send process.env.HUBOT_NO_DIFFERENCE_MESSAGE || "There is no difference between two branches :("
    repo = msg.match[1]
    url_api_base = "https://api.github.com"
    data = {
      "title": "deploy",
      "head": process.env.HUBOT_BRANCH_FROM || "develop",
      "base": process.env.HUBOT_BRANCH_TO || "master"
    }
    ghOrg = process.env.HUBOT_GITHUB_ORG
    url = "#{url_api_base}/repos/#{ghOrg}/#{repo}/pulls"
    github.get url, data, (response) ->
      if response.length > 0
        api_url = "#{url_api_base}/repos/#{ghOrg}/#{repo}/pulls/#{response[0].number}"
        msg.send process.env.HUBOT_PR_EXISTS_MESSAGE || "This pull request already exists."
        updatePrSummary(api_url, msg)
      else
        createPullRequest(url, data)

  robot.respond /update summary of deploy (\w+) (\d+)/i, (msg) ->
    repo = msg.match[1]
    number = msg.match[2]
    url_api_base = "https://api.github.com"
    ghOrg = process.env.HUBOT_GITHUB_ORG
    url = "#{url_api_base}/repos/#{ghOrg}/#{repo}/pulls/#{number}"
    updatePrSummary(url)
