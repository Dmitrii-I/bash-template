# bash-template

[![Netlify Status](https://api.netlify.com/api/v1/badges/27f68a8d-1ace-4287-8df5-61a587c47fba/deploy-status)](https://app.netlify.com/sites/bash-template/deploys)

Template script for defensive bash programming.

## Usage

### Web browser
Open [http://www.bash-template.com](http://www.bash-template.com), then copy and paste.

### wget
`wget -O - http://www.bash-template.com -o /dev/null`

### HTTPie
`http -b http://www.bash-template.com`

### curl
`curl http://www.bash-template.com`

## Building website
Run `make www` to build the static website inside `www` directory.

## Website hosting
I tried hosting on [zeit.co](https://zeit.co), but they [do not support](https://github.com/zeit/now/issues/1745) turning off http to https redirects. This means `curl bash-template.com` won't work, and you must use `curl -L bash-template.com`. I do not want that since it is easy to forget that you must use `-L`.
