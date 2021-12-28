#!/bin/bash

#toolbox run --container jekyll bundle exec jekyll serve
export JEKYLL_VERSION=3.8

rm "${PWD}/Gemfile.lock"
touch "${PWD}/Gemfile.lock"
chmod 666 "${PWD}/Gemfile.lock"
podman run --rm \
  --volume="$PWD:/srv/jekyll:z" \
  --publish [::1]:4000:4000 \
  jekyll/jekyll:$JEKYLL_VERSION \
  jekyll serve --watch --drafts
