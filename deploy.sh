#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo # if using a theme, replace by `hugo -t <yourtheme>`

# Check HTML is working
# The URL-swap argument stops it from returning false on the doc 
# URLs like /some/doc/link.rs#123-144 which is handled by js.
htmlproofer public/ --allow-hash-href \
  --check-html \
  --url-swap "(.+)#[0-9]+-[0-9]+:$1" \
  --url-ignore "#deref-methods" \
  --file-ignore "/.+\/javadoc\/.*/"

if [ ! $? -eq 0 ]
  then
  echo -e "\033[0;31mIssues with HTML, exiting.\033[0m"
  exit $?
fi

# Go To Public folder
cd public
# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back
cd ..
