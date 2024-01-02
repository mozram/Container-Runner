# Container-Runner

Simple runner script to execute command in work environment.

Simply set `alias dockerunner="{path to script}"`.

Make sure the script configured to your environment first.

To use, just run `dockerunner ./build.sh`. The script will begin to prompt few
questions before executing the command.

If want to pass more than 1 arguments, enclose the rest of the command inside `""`.
For example `dockerunner "./build.sh arg1 arg2"`
