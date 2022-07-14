{ bemenu
, jq
, sway-unwrapped
, wf-recorder
, writeShellApplication
}:
writeShellApplication {
  name = "mirror-to-x";
  runtimeInputs = [
    bemenu
    jq
    sway-unwrapped
    wf-recorder
  ];
  text = ''
    export SDL_VIDEODRIVER=x11
    outputs=$(swaymsg -t get_outputs)
    output=
    if test "$(echo "$outputs" | jq 'length')" -eq 1; then
      output="$(echo "$outputs" | jq --raw-output '.[].name')"
    else
      selected="$(echo "$outputs" | jq --raw-output '.[] | ["printf", "%s: %s %s\n", .name, .make, .model] | @sh' | sh | bemenu --prompt output --list 5)"
      output="$(echo "$selected" | cut -d':' -f1)"
    fi
    env | grep WAY
    # printf "'%s'" "$output"
    # exit 0
    wf-recorder -c rawvideo -m sdl -f pipe:xwayland-mirror -o "$output"
  '';
}
