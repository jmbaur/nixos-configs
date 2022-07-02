pinentry_output=$(printf "SETPROMPT master password:\nGETPIN\n" | pinentry-bemenu)
ready=0
pin=""
for line in $pinentry_output; do
	if [ $ready -eq 1 ]; then
		pin="$line"
		break
	fi
	if [ "$line" == "D" ]; then
		ready=1
	fi
done

if [ "$pin" == "" ]; then
	echo "empty pin"
	exit 1
fi

session_token=$(bw unlock "$pin" --raw)
export BW_SESSION=$session_token

readarray -t items < <(bw list items | jq -r '.[] | select(.type == 1) | "\(.id):\(.name) (\(.login.username))"')

selected=$(printf "%s\n" "${items[@]}" | cut -d ':' -f 2 | bemenu --list 10 --prompt "login")

found=""
for item in "${items[@]}"; do
	if [ "$selected" == "$(echo "$item" | cut -d ':' -f 2)" ]; then
		found=$(echo "$item" | cut -d ':' -f 1)
	fi
done

if [ "$found" == "" ]; then
	exit 1
fi

item_json=$(bw get item "$found")
password=$(echo "$item_json" | jq -r '.login.password')
totp=$(echo "$item_json" | jq -r '.login.totp')

options=()
if [ "$password" != "" ]; then
	options+=("password")
fi
if [ "$totp" != "" ]; then
	options+=("totp")
fi

case ${#options[@]} in
	0)
		exit 1
		;;
	1)
		to_copy=${options[0]}
		;;
	*)
		to_copy=$(printf "%s\n" "${options[@]}" | bemenu --list 10 --prompt "item to copy")
		;;
esac

case $to_copy in
	"password")
		echo "copied password"
		wl-copy --paste-once "$(bw get password "$found")"
		;;
	"totp")
		echo "copied totp"
		wl-copy --paste-once "$(bw get totp "$found")"
		;;
esac
