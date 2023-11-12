default: watch

# lists available tasks
@list:
    just --list

# init project
init:
    git pull

# open the project in the browser
open:
    gh repo view --web

# start a console
console:
    luajit

# run tests
test path="spec/":
    nvim --headless -c "PlenaryBustedDirectory {{path}}"

dev:
    ls **/*.lua | entr -c nvim --headless -c "PlenaryBustedDirectory spec/"
