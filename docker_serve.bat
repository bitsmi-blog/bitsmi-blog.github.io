@echo off

set JEKYLL_VERSION=4.2.2
docker run -d --name jekyll_dev --volume="%CD%:/srv/jekyll" -p 4000:4000 jekyll/jekyll:%JEKYLL_VERSION% jekyll serve
