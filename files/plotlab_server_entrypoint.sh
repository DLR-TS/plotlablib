#!/usr/bin/env bash

function echoerr { echo "$@" >&2; exit 1;}
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PLOTLAB_SERVER_BINARY_DIRECTORY="$(realpath ${SCRIPT_DIRECTORY}/../server/build)"

cd "${SCRIPT_DIRECTORY}"

bash plotlab_server_plot_recorder.sh >> /var/log/plotlab/plotlab_server_plot_recorder.log 2>&1 &

cd "${PLOTLAB_SERVER_BINARY_DIRECTORY}"

echo "Plotlab server DISPLAY_MODE: ${DISPLAY_MODE}"
echo "  Possible display modes: native, window_manager, headless"
echo "    To change the display mode modify the DISPLAY_MODE environmental variable in the docker-compose.yaml"
echo "    DISPLAY_MODE descriptions: "
echo "        native: plotlab windows will be displaed as native windows within the host system window manager (does not support video recording)" 
echo "        window_manager: plotlab windows will be displaed within a nested i3 window manager (supports video recording)" 
echo "        headless: plotlab server windows will be displayed on a virtual xvfb display suitable for headless host systems (supports video recording)" 
echo ""

mkdir -p /var/log/plotlab/

touch /var/log/plotlab/i3.log
touch /var/log/plotlab/plotlabserver.log

if [ "$DISPLAY_MODE" != "native" ] && [ "${DISPLAY_MODE}" != "window_manager" ] && [ "${DISPLAY_MODE}" != "headless" ]; then
  echoerr "ERROR: Unsupported display mode: ${DISPLAY_MODE}."
fi

echo "DISPLAY: ${DISPLAY}"


# window manager
if [[ "${DISPLAY_MODE}" == "window_manager" ]]; then
  echo "  running in window_manager mode..."
  Xephyr -br -ac -noreset -softCursor -screen ${VIRTUAL_DISPLAY_RESOLUTION} ${VIRTUAL_DISPLAY_ID} &
  sleep .1s
  xdotool search --name "Xephyr" set_window --name "Plotlab Server (ctrl+shift to capture and release mouse and keyboard)"
  DISPLAY="${VIRTUAL_DISPLAY_ID}" i3 > /var/log/plotlab/i3.log 2>&1 &
  sleep 1s
  DISPLAY="${VIRTUAL_DISPLAY_ID}" ./plotlabserver > /var/log/plotlab/plotlabserver.log 2>&1 &
  tail -f /var/log/plotlab/plotlabserver.log
fi

# headless
if [[ "${DISPLAY_MODE}" == "headless" ]]; then
  echo "  running in headless mode..."
  Xvfb "${VIRTUAL_DISPLAY_ID}" -screen 0 "${VIRTUAL_DISPLAY_RESOLUTION}x16" \
                             -nolisten tcp >> "/var/log/plotlab/xvfb.log" 2>&1 &
  sleep 1s
  DISPLAY=${VIRTUAL_DISPLAY_ID} i3 > /var/log/plotlab/i3.log 2>&1 &
  sleep 1s
  DISPLAY=${VIRTUAL_DISPLAY_ID} unclutter -idle .1 &
  DISPLAY=${VIRTUAL_DISPLAY_ID} ./plotlabserver > /var/log/plotlab/plotlabserver.log 2>&1 &
  tail -f /var/log/plotlab/plotlabserver.log
fi

# native
if [[ "${DISPLAY_MODE}" == "native" ]]; then
  echo "  running in native mode..."
  ./plotlabserver 2>&1 | tee /var/log/plotlab/plotlabserver.log
fi
