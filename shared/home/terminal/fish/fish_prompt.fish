function synclangm
  cd ~/Documents/languages
  git add -A
  git commit -am $argv
  git push && cd -
end
