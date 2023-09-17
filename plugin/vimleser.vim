" ToDo: vimleser
:py3 <<EOF
import os

import speechd

SPD_CLIENT = None

def init_speechd():
    """Initialse and set up the speech dispatcher client."""
    global SPD_CLIENT
    SPD_CLIENT = speechd.Client()
    SPD_CLIENT.set_rate(80)
    SPD_CLIENT.set_volume(-10)
    SPD_CLIENT.set_pitch(-30)
    SPD_CLIENT.set_punctuation("all")

def announce_buffer_name():
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

def announce_lineno():
    """Announce current line.
    As using the range would effectively absorb it (i.e. visual mode), this
    remains unimplemented: querying the exact position in a range if the range
    is lost right after the announcement it useless. """
    SPD_CLIENT.speak(f"{vim.current.range.end + 1}")


def stop_speech():
    """Interrupt current speech."""
    SPD_CLIENT.stop()

init_speechd()
EOF

map \sl :py3 announce_lineno()<cr>
map \st :py3 announce_buffer_name()<cr>
map \ss :py3 stop_speech()<cr>
map <C-s> :py3 stop_speech()<cr>
