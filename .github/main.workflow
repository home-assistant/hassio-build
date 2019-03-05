workflow "Linting" {
  on = "push"
  resolves = ["\tactions/bin/shellcheck@master"]
}

action "\tactions/bin/shellcheck@master" {
  uses = "\tactions/bin/shellcheck@master"
}
