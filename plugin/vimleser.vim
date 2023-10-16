" A "vim reader" that augments an existing screen reader with additional functionality.

:py3 <<EOF
import os

import speechd

SPD_CLIENT = None

def init_speechd():
    """Initialse and set up the speech dispatcher client."""
    global SPD_CLIENT
    if SPD_CLIENT:
        try: # try to end old session, if applicable
            SPD_CLIENT.close()
        except:
            pass
    SPD_CLIENT = speechd.Client()
    SPD_CLIENT.set_rate(80)
    SPD_CLIENT.set_volume(-10)
    SPD_CLIENT.set_pitch(-30)
    SPD_CLIENT.set_punctuation("all")

def __announce_buffer_name():
    """Speak the current buffer name.
    To avoid waiting for the file name in a long path, the path is spoken first and $HOME is stripped.
    """
    bufname = vim.current.buffer.name
    home_dir = os.path.expanduser('~')
    if home_dir in bufname:
        bufname = bufname.replace(home_dir, "").lstrip(os.sep)
    bufpath = os.path.dirname(bufname)
    if not bufpath:
        bufpath = "home directory"
    bufname = os.path.basename(bufname)
    SPD_CLIENT.speak(f"{bufname} in {bufpath}")

def __announce_lineno():
    """Announce current line.
    As using the range would effectively absorb it (i.e. visual mode), this
    remains unimplemented: querying the exact position in a range if the range
    is lost right after the announcement it useless. """
    SPD_CLIENT.speak(f"{vim.current.range.end + 1}")


def __stop_speech():
    """Interrupt current speech."""
    SPD_CLIENT.stop()

def perform_safely(func):
    """Perform an action. If it fails, restart the speechd client."""
    try:
        func()
    except speechd.client.SSIPCommunicationError:
        init_speechd()
        try:
            func()
        except speechd.client.SSIPCommunicationError:
            print("Error: no connection to speechd possible.")

init_speechd()
stop_speech = lambda: perform_safely(__stop_speech)
announce_lineno = lambda: perform_safely(__announce_lineno)
announce_buffer_name = lambda: perform_safely(__announce_buffer_name)
EOF

map <leader>sl :py3 announce_lineno()<cr>
map <leader>st :py3 announce_buffer_name()<cr>
map <leader>ss :py3 stop_speech()<cr>
map <C-s> :py3 stop_speech()<cr>
