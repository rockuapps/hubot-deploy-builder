# hubot-deploy-builder

This plugin make pull request from develop to master, and it summarize pull requests which is merged to develop branch.
So, you can see a difference between develop and master and you can judge whether it should be merged to master or not.

## Installation

Add hubot-deploy-builder to your `package.json`

```
"dependencies": {
  "hubot-deploy-builder": ">=0.1.0"
}
```

Add hubot-deploy-builder to your `external-scripts.json`

```
["hubot-deploy-builder"]
```

RUn `npm install`

## Settings for GitHub

Set these parameters for your environmental variable.

* HUBOT_GITHUB_TOKEN

Set your GitHub access token.

* HUBOT_GITHUB_USER

Set your GitHub user name.


* HUBOT_GITHUB_ORG

Set your GitHub organization name.

## Usage


```
hubot deploy [your service]
```

Your bot returns url of pull request and create summary!

If the pull request already exists, it updates summary.
If there is no difference between develop and master branch, it returns error message.

