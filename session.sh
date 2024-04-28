#!/bin/zsh

DEFAULT_DIRECTORY=~
PROJECT=

print_help ()
{
    echo "Create new tmux session with a layout"
    echo "Usage: ./session.sh -s|--session session_name [-d|--dir default=~] [-p|--project python/c/node/ default=] [-h|--help]"
}


# print help if no arguments are passed
if [[ "$#" == 0 ]]
then
    print_help
    exit 0;
fi

# parse arguments
while [[ "$#" -gt 0 ]]
do case $1 in
    -s|--session) SESSION=$2
    shift;;
    -d|--dir) DEFAULT_DIRECTORY=$2
    shift;;
    -p|--project) PROJECT=$2
    shift;;
    -h|--help) print_help
    exit 0;;
    *) echo "Invalid parameter passed: $1"
    exit 1;;
    esac
shift
done

if [[ $SESSION == "" ]]
then 
    echo "ERROR: Session argument missing. Please declare session name with the -s|--session flag"
    exit 1;
fi

setup_default() {
    tmux new -c $DEFAULT_DIRECTORY -d -s "$SESSION" -n "console"
}

setup_python ()
{
    tmux new -c $DEFAULT_DIRECTORY -d -s "$SESSION" -n "ide"

    tmux new-window -c $DEFAULT_DIRECTORY -t $SESSION:1 -n "console"
    tmux split-window -c $DEFAULT_DIRECTORY -t $SESSION:1.0 -h -l "50%"

    tmux send-keys -t $SESSION:0.0 "pipenv run nvim" C-m
    tmux send-keys -t $SESSION:1.0 "pipenv run python main.py" # hanging, waiting for user to press enter
    tmux send-keys -t $SESSION:1.1 "pipenv run python" C-m
    tmux send-keys -t $SESSION:1.1 C-l
}

setup_node ()
{
    tmux new -c $DEFAULT_DIRECTORY -d -s "$SESSION" -n "ide"

    tmux new-window -c $DEFAULT_DIRECTORY -t $SESSION:1 -n "console"
    tmux split-window -c $DEFAULT_DIRECTORY -t $SESSION:1.0 -h -l "50%"

    tmux send-keys -t $SESSION:0.0 "nvim" C-m
    tmux send-keys -t $SESSION:1.0 "yarn start" # hanging, waiting for user to press enter
    tmux send-keys -t $SESSION:1.1 "node" C-m
    tmux send-keys -t $SESSION:1.1 C-l 
}

setup_c ()
{
    tmux new -c $DEFAULT_DIRECTORY -d -s "$SESSION" -n "ide"
    tmux new-window -c $DEFAULT_DIRECTORY -t $SESSION:1 -n "console"
    tmux send-keys -t $SESSION:0.0 "nvim" C-m
}

tmux has-session -t "$SESSION"

if [ $? != 0 ]
then
    case $PROJECT in
    python) setup_python;;
    node) setup_node;;
    c) setup_c;;
    *) setup_default;;
    esac

    # use ide session as default + open nvim
    tmux select-window -t $SESSION:0
fi

tmux attach -t $SESSION
