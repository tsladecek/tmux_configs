#!/bin/zsh

SESSION='session'

tmux has-session -t $SESSION

if [$? != 0] then
    tmux new -ds $SESSION
fi

tmux attach -t $SESSION
