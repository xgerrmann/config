function unattached_sessions() {
	local panes="$(
		tmux list-panes -a -F '#{session_attached} #{session_name} #{session_created} #{pane_current_path}: #{pane_current_command}' | grep '^0'
	)"
	if [ -n "$panes" ]; then
		echo -e 'There are unattached sessions ("attach \e[0m\e[36m<session_name>\e[0m" to switch):'
		local x name date cmd
		while read x name date cmd; do
			printf "  \e[36m%10s\e[0m (%s): %s\n" "$name" "$(date +'%F %T' --date=@$date)" "$cmd"
		done <<<"$panes"
	fi
}

function attach {
	if [ $# -ne 1 ]; then
		echo "Usage: $0 <session_name>" >&2
		return 1
	fi
	local tmux_session="$(tmux display-message -p '#S')"
	tmux switch-client -t "$1"
	tmux kill-session -t "$tmux_session"
}

if [ -n "$TMUX" ]; then
	if [ -z "$TMUXTTY" ]; then
		# New session
		export TMUXTTY="$(tty)"
		unattached_sessions
	elif [ "$TMUXTTY" != "$(tty)" ]; then
		# About to start new session
		unset TMUX TMUXTTY
	fi
fi

if [[ -z "$NOTMUX" ]] && [[ $- == *i* ]] && test_command tmux; then
	if [ -z "$TMUX" ]; then
		exec tmux new-session "$(ps -p $$ -ocomm=)"
	fi
fi
