#!/usr/bin/env bash
#
# Turns a minimal Debian-family install (Debian, Raspberry Pi OS Lite, Ubuntu Server) into a
# NoGa OS appliance: power on, no login prompt, no Linux desktop, NoGa OS owning the screen.
#
#     wget -qO install-kiosk.sh https://celtric.github.io/nogaos-site/install-kiosk.sh && sudo bash install-kiosk.sh
#     wget -qO- https://celtric.github.io/nogaos-site/install-kiosk.sh | sudo bash -s -- --yes --lid ignore
#
# Every step asks first and can be skipped, which leaves that part of the machine untouched; --yes
# runs them all without asking. Safe to run again: every file it owns is rewritten whole, so a
# second run repairs a half-finished first one, and running it with different choices changes the
# setup (keeping the console reachable unlocks a locked machine). docs/kiosk-setup.md in the source
# tree explains each step.

set -euo pipefail

RELEASES_API="https://api.github.com/repos/celtric/nogaos-site/releases/latest"

KIOSK_USER="nogaos"
LID_ACTION="suspend"
LOCKDOWN="no"
ASSUME_YES="no"

usage() {
    cat <<'EOF'
Usage: install-kiosk.sh [options]

  --user NAME       account NoGa OS runs as; created if missing (default: nogaos)
  --lid ACTION      closing a laptop lid: suspend, poweroff or ignore (default: suspend)
  --lockdown        make Ctrl+Alt+F1..F6 and the other ways out to a Linux console do
                    nothing, with SSH switched on as the way back in
  --no-lockdown     keep those keys working (the default); also removes the lockdown a
                    previous run applied
  --yes             run every step without asking, with the choices above
  --help            show this text

Without --yes each step is shown first and can be run or skipped; --lid and
--lockdown then only pick which answer is preselected.
EOF
}

EXIT_EXPLAINED="no"
die() {
    EXIT_EXPLAINED="yes"
    echo "install-kiosk: $*" >&2
    exit 1
}

step() {
    echo
    echo "==> $*"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --user) KIOSK_USER="${2:-}"; shift 2 || die "--user needs a name" ;;
        --lid) LID_ACTION="${2:-}"; shift 2 || die "--lid needs an action" ;;
        --lockdown) LOCKDOWN="yes"; shift ;;
        --no-lockdown) LOCKDOWN="no"; shift ;;
        --yes) ASSUME_YES="yes"; shift ;;
        --help) usage; exit 0 ;;
        *) usage >&2; die "unknown option: $1" ;;
    esac
done

[ "$(id -u)" -eq 0 ] || die "run me as root (pipe into 'sudo bash')"
[[ "$KIOSK_USER" =~ ^[a-z_][a-z0-9_-]*$ ]] || die "not a valid user name: $KIOSK_USER"
[ "$KIOSK_USER" != "root" ] || die "NoGa OS must not run as root"
case "$LID_ACTION" in
    poweroff|suspend|ignore) ;;
    *) die "--lid must be poweroff, suspend or ignore" ;;
esac

# Everything below except the package installs and the GRUB step is plain systemd + Xorg and would
# work on any distribution; the package names are what tie this script to the Debian family.
# shellcheck disable=SC1091
. /etc/os-release
case " ${ID:-} ${ID_LIKE:-} " in
    *" debian "*) ;;
    *) die "this installer supports Debian, Raspberry Pi OS and Ubuntu; found '${PRETTY_NAME:-unknown}'" ;;
esac
command -v systemctl >/dev/null || die "systemd is required"

#---[ Questions ]-------------------------------------------------------------------------------------------------------

# whiptail comes with every Debian-family install (raspi-config is built on it), so the dialogs cost
# no download; where it is missing the same questions are asked as plain text.
#
# The questions need the script to be run from a file, not piped from wget. Debian's sudo runs its
# command on a pseudo-terminal of its own (`use_pty`), and when sudo's stdin is a pipe it passes the
# keyboard into it a line at a time, with the console echoing every key: arrows show as ^[[B and no
# dialog gets them. Reading the console sudo was started from directly does not help either, since
# whiptail takes its keys from its controlling terminal (sudo's) whatever its stdin is, and sudo
# keeps reading that console alongside it. Piped with --yes nothing is asked, so that still works.
BACKTITLE="NoGa OS kiosk installer"
UI="none"
TTY=/dev/tty
if [ "$ASSUME_YES" = "no" ]; then
    if [ ! -t 0 ]; then
        die "piped, the keyboard does not reach the questions. Download the installer and run it:
    wget -qO install-kiosk.sh https://celtric.github.io/nogaos-site/install-kiosk.sh && sudo bash install-kiosk.sh
or pipe it with --yes to run every step without asking."
    fi
    [ -r "$TTY" ] || die "no terminal to ask on; pass --yes to run every step without asking"
    if command -v whiptail >/dev/null; then
        UI="whiptail"
    else
        UI="text"
    fi
fi

DH=20
DW=76
dialog_size() {
    local rows cols
    read -r rows cols < <(stty size <"$TTY" 2>/dev/null || echo "24 80")
    DH=$(( rows > 26 ? 22 : rows - 4 ))
    DW=$(( cols > 84 ? 78 : cols - 6 ))
    [ "$DH" -ge 10 ] || DH=10
    [ "$DW" -ge 40 ] || DW=40
}

# --scrolltext gives the keyboard to the text first, so Enter does nothing until Tab reaches a
# button; it is only added when the text would not fit. whiptail wraps at DW - 4 columns and leaves
# DH - 6 lines for the text; one of them is kept spare since fold does not break lines exactly as
# whiptail does.
SCROLL=()
scroll_if_needed() {
    SCROLL=()
    if [ "$(fold -s -w $(( DW - 4 )) <<<"$1" | wc -l)" -gt $(( DH - 7 )) ]; then
        SCROLL=(--scrolltext)
    fi
}

# whiptail draws on stdout and reports the answer on stderr, so the drawing goes to the terminal
# and the answer to WT_OUT. whiptail reports its own failures there too, with the exit code of
# the second button or of Esc: a dialog text starting with "-" is an unknown option to it, so it
# exits 1 and, before the "--" callers now put in front of the text, a step was skipped without
# ever being shown. The buttons and Esc print nothing, so a message with a non-zero code is always
# a failure, and it stops the installer rather than counting as an answer.
WT_OUT=""
wt() {
    local rc=0
    WT_OUT="$(whiptail --backtitle "$BACKTITLE" "$@" 2>&1 >"$TTY" <"$TTY")" || rc=$?
    if [ "$rc" -ne 0 ] && [ -n "$WT_OUT" ]; then
        clear_screen
        die "whiptail could not show a dialog: ${WT_OUT}"
    fi
    return "$rc"
}

confirm_stop() {
    local text="Stop the installer here?

The steps already run stay done. Running the installer again goes through every step from the start."
    case "$UI" in
        whiptail)
            dialog_size
            local rc=0
            wt --title "Stop" --yes-button "Stop" --no-button "Go back" --defaultno \
                --yesno -- "$text" "$DH" "$DW" || rc=$?
            [ "$rc" -eq 1 ] && return 0
            ;;
        text)
            local answer
            printf '\n%s\n\nStop? [y]es, [n]o: ' "$text" >"$TTY"
            read -r answer <"$TTY" || die "no answer on the terminal"
            case "$answer" in y|Y|yes) ;; *) return 0 ;; esac
            ;;
    esac
    clear_screen
    EXIT_EXPLAINED="yes"
    echo "Stopped by request."
    print_summary
    exit 1
}

clear_screen() {
    [ "$UI" != "whiptail" ] || clear >"$TTY" 2>/dev/null || true
}

# Returns 0 to run the step, 1 to skip it. Esc (q in text mode) offers to stop the installer.
ask_step() {
    local title="$1" text="$2"
    while true; do
        case "$UI" in
            none) return 0 ;;
            whiptail)
                dialog_size
                scroll_if_needed "$text"
                local rc=0
                wt --title "$title" --yes-button "Run" --no-button "Skip" "${SCROLL[@]}" \
                    --yesno -- "$text" "$DH" "$DW" || rc=$?
                case "$rc" in
                    0) clear_screen; return 0 ;;
                    1) return 1 ;;
                esac
                ;;
            text)
                local answer
                printf '\n--- %s ---\n\n%s\n\n[r]un, [s]kip or [q]uit: ' "$title" "$text" >"$TTY"
                read -r answer <"$TTY" || die "no answer on the terminal"
                case "$answer" in
                    r|R|run|y|Y|yes) return 0 ;;
                    s|S|skip) return 1 ;;
                    q|Q|quit) ;;
                    *) continue ;;
                esac
                ;;
        esac
        confirm_stop
    done
}

# Sets CHOICE to one of the tags, or to "skip". The arguments after the default are tag/label pairs.
CHOICE=""
ask_choice() {
    local title="$1" text="$2" default="$3"
    shift 3
    while true; do
        case "$UI" in
            none) CHOICE="$default"; return ;;
            whiptail)
                dialog_size
                local rc=0
                wt --title "$title" --ok-button "Run" --cancel-button "Skip" --default-item "$default" \
                    --menu -- "$text" "$DH" "$DW" $(( $# / 2 )) "$@" || rc=$?
                case "$rc" in
                    0) CHOICE="$WT_OUT"; clear_screen; return ;;
                    1) CHOICE="skip"; return ;;
                esac
                ;;
            text)
                local pairs=("$@") tags=() i marker answer
                printf '\n--- %s ---\n\n%s\n\n' "$title" "$text" >"$TTY"
                for (( i = 0; i < ${#pairs[@]}; i += 2 )); do
                    tags+=("${pairs[$i]}")
                    marker=""
                    if [ "${pairs[$i]}" = "$default" ]; then marker=" (suggested)"; fi
                    printf '  %d) %s%s\n' "${#tags[@]}" "${pairs[$(( i + 1 ))]}" "$marker" >"$TTY"
                done
                printf '\nRun with [1-%d], [s]kip or [q]uit: ' "${#tags[@]}" >"$TTY"
                read -r answer <"$TTY" || die "no answer on the terminal"
                case "$answer" in
                    s|S|skip) CHOICE="skip"; return ;;
                    q|Q|quit) ;;
                    *)
                        if [[ "$answer" =~ ^[0-9]+$ ]] && [ "$answer" -ge 1 ] && [ "$answer" -le "${#tags[@]}" ]; then
                            CHOICE="${tags[$(( answer - 1 ))]}"
                            return
                        fi
                        continue
                        ;;
                esac
                ;;
        esac
        confirm_stop
    done
}

show_message() {
    local title="$1" text="$2"
    case "$UI" in
        whiptail)
            dialog_size
            scroll_if_needed "$text"
            wt --title "$title" "${SCROLL[@]}" --msgbox -- "$text" "$DH" "$DW" || true
            clear_screen
            ;;
        *) printf '\n%s\n' "$text" ;;
    esac
}

#---[ Steps ]-----------------------------------------------------------------------------------------------------------

SUMMARY=()
NOTES=()
STEP_NUMBER=0
STEP_COUNT=0

note() {
    NOTES+=("$*")
    echo "$*"
}

STEP_TITLE=""
next_step() {
    STEP_NUMBER=$(( STEP_NUMBER + 1 ))
    STEP_TITLE="Step ${STEP_NUMBER} of ${STEP_COUNT}: $1"
}

user_exists() {
    id "$KIOSK_USER" >/dev/null 2>&1
}

kiosk_home() {
    getent passwd "$KIOSK_USER" | cut -d: -f6
}

as_kiosk_user() {
    runuser -u "$KIOSK_USER" -- "$@"
}

# Steps that write into the kiosk user's home cannot run without it; they are reported instead of
# failing halfway through.
run_step() {
    local name="$1" function="$2" text="$3" needs_user="${4:-}"
    next_step "$name"
    if [ -n "$needs_user" ] && ! user_exists; then
        SUMMARY+=("Not run  ${name} (user ${KIOSK_USER} does not exist)")
        return
    fi
    if ask_step "$STEP_TITLE" "$text"; then
        step "$name"
        "$function"
        SUMMARY+=("Done     ${name}")
    else
        SUMMARY+=("Skipped  ${name}")
    fi
}

APT_UPDATED="no"
apt_install() {
    export DEBIAN_FRONTEND=noninteractive
    if [ "$APT_UPDATED" = "no" ]; then
        apt-get update
        APT_UPDATED="yes"
    fi
    apt-get install -y --no-install-recommends "$@"
}

first_available() {
    local candidate
    for candidate in "$@"; do
        if apt-cache show "$candidate" >/dev/null 2>&1; then
            echo "$candidate"
            return
        fi
    done
    die "none of these packages exist here: $*"
}

install_packages() {
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    APT_UPDATED="yes"
    local java
    java="$(first_available openjdk-21-jre openjdk-17-jre default-jre)"
    local packages=(
        xserver-xorg xinit x11-xserver-utils
        "$java" fonts-dejavu-core
        # Java plays through ALSA, so without pipewire-alsa it fights PipeWire for the raw device and
        # stays silent; without dbus-user-session the PipeWire user services never start at all.
        # --no-install-recommends skips both, which is why they are spelled out.
        pipewire pipewire-pulse pipewire-alsa wireplumber dbus-user-session rtkit
        pulseaudio-utils alsa-utils
        udisks2 polkitd
        vlc
        # The camera applet streams video only through ffmpeg; the other tools it knows take one
        # photo per frame, and none of them comes with a minimal install.
        ffmpeg
        network-manager
        wget ca-certificates
    )
    apt_install "${packages[@]}"
}

prepare_user() {
    if ! user_exists; then
        adduser --disabled-password --gecos "NoGa OS" "$KIOSK_USER"
        note "Created '${KIOSK_USER}' without a password: it can only log in automatically on the console." \
            "Give it one with 'sudo passwd ${KIOSK_USER}' if you want to reach it over SSH."
    fi
    local group
    for group in audio video input render plugdev netdev; do
        if getent group "$group" >/dev/null; then
            adduser --quiet "$KIOSK_USER" "$group" >/dev/null
        fi
    done
    [ -d "$(kiosk_home)" ] || die "home directory of ${KIOSK_USER} not found: $(kiosk_home)"
}

# ~/.nogaos/nogaos.jar -> versions/<file> is the layout the Updates applet maintains, so launching
# the link is what lets the machine update itself later.
download_nogaos() {
    local nogaos_dir
    nogaos_dir="$(kiosk_home)/.nogaos"
    as_kiosk_user mkdir -p "${nogaos_dir}/versions"
    if [ -e "${nogaos_dir}/nogaos.jar" ]; then
        echo "Already installed ($(readlink "${nogaos_dir}/nogaos.jar" || echo nogaos.jar)); updates are the Updates applet's job."
        return
    fi
    local release jar_url jar_name
    release="$(wget -qO- "$RELEASES_API")" || die "could not reach GitHub to find the latest NoGa OS; is the network up?"
    jar_url="$(grep -o '"browser_download_url": *"[^"]*\.jar"' <<<"$release" | head -n 1 | cut -d'"' -f4 || true)"
    [ -n "$jar_url" ] || die "the latest NoGa OS release on GitHub has no download to install"
    jar_name="$(basename "$jar_url")"
    as_kiosk_user wget -q --show-progress -O "${nogaos_dir}/versions/${jar_name}.part" "$jar_url" \
        || die "the download of ${jar_url} failed; is the network up?"
    as_kiosk_user mv "${nogaos_dir}/versions/${jar_name}.part" "${nogaos_dir}/versions/${jar_name}"
    as_kiosk_user ln -sfn "versions/${jar_name}" "${nogaos_dir}/nogaos.jar"
    note "Installed ${jar_name}."
}

start_at_boot() {
    local home
    home="$(kiosk_home)"

    mkdir -p /etc/systemd/system/getty@tty1.service.d
    cat > /etc/systemd/system/getty@tty1.service.d/nogaos-autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${KIOSK_USER} --noclear %I \$TERM
EOF

    # No window manager: Java owns the screen. The loop means a crash or a self-update restart shows an
    # empty screen for a second, never a way out.
    as_kiosk_user tee "${home}/.xinitrc" >/dev/null <<'EOF'
#!/bin/sh
xset s off
xset -dpms
xset s noblank

# Debian leaves /usr/sbin off an ordinary user's PATH; NoGa OS versions that power off through
# 'shutdown' cannot find it without this, and come straight back instead of shutting down.
export PATH="$PATH:/usr/sbin:/sbin"

while true; do
    java -jar "$HOME/.nogaos/nogaos.jar"
    sleep 1
done
EOF
    chmod +x "${home}/.xinitrc"

    # When X cannot start, say so and retry instead of dropping the kid into a shell: the traps keep
    # Ctrl+C from interrupting the profile, and 'exit' hands the console back to the autologin.
    #
    # The block goes into the file a bash login reads, which is the first of these that exists. An
    # earlier installer always created .bash_profile, and a .bash_profile holding nothing but the
    # block hides the account's .profile from bash (and with it ~/bin and ~/.local/bin on PATH), so
    # that one is removed rather than kept.
    local begin_mark="# >>> nogaos kiosk >>>"
    local end_mark="# <<< nogaos kiosk <<<"
    local file profile=""
    for file in .bash_profile .bash_login .profile; do
        [ -f "${home}/${file}" ] || continue
        sed -i "/^${begin_mark}\$/,/^${end_mark}\$/d" "${home}/${file}"
        if [ "$file" = ".bash_profile" ] && ! grep -q '[^[:space:]]' "${home}/${file}"; then
            rm -f "${home}/${file}"
        elif [ -z "$profile" ]; then
            profile="${home}/${file}"
        fi
    done
    [ -n "$profile" ] || profile="${home}/.profile"
    as_kiosk_user touch "$profile"
    as_kiosk_user tee -a "$profile" >/dev/null <<EOF
${begin_mark}
if [ -z "\${DISPLAY:-}" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    trap '' INT TSTP QUIT
    startx >"\$HOME/.nogaos/kiosk-display.log" 2>&1
    echo
    echo "NoGa OS could not start the display. Trying again in 10 seconds."
    echo "Details: ~/.nogaos/kiosk-display.log (read it from another console or over SSH)."
    sleep 10
    exit
fi
${end_mark}
EOF

    systemctl --global enable pipewire.socket pipewire-pulse.socket wireplumber.service >/dev/null 2>&1 || true
    systemctl daemon-reload || true
}

configure_touchpad() {
    mkdir -p /etc/X11/xorg.conf.d
    cat > /etc/X11/xorg.conf.d/30-nogaos-touchpad.conf <<'EOF'
Section "InputClass"
    Identifier "nogaos touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
EndSection
EOF
}

configure_lid() {
    mkdir -p /etc/systemd/logind.conf.d
    cat > /etc/systemd/logind.conf.d/nogaos.conf <<EOF
[Login]
HandleLidSwitch=${LID_ACTION}
HandleLidSwitchExternalPower=${LID_ACTION}
HandlePowerKey=poweroff
EOF
}

# A kiosk runs no desktop automounter, so NoGa OS mounts plugged media itself through udisks2, and
# a session started from a bare console is not always allowed to without this rule.
configure_removable() {
    mkdir -p /etc/polkit-1/rules.d
    cat > /etc/polkit-1/rules.d/50-nogaos-removable.rules <<EOF
polkit.addRule(function(action, subject) {
    if (subject.user == "${KIOSK_USER}" && action.id.indexOf("org.freedesktop.udisks2.filesystem-mount") == 0) {
        return polkit.Result.YES;
    }
});
EOF
}

# Debian's installer, run without a desktop, writes the Wi-Fi it joined into /etc/network/interfaces,
# and NetworkManager leaves every interface listed there alone: the Wi-Fi applet then finds no
# networks on a machine that is online. Each such network becomes a NetworkManager profile named
# after the network (the applet takes a profile's name for the network's) and its lines are
# commented out. The old setup keeps the connection until the restart this installer ends with, so
# an install over SSH is not cut off halfway. A static address is not moved, only reported.
INTERFACES=/etc/network/interfaces

wifi_in_interfaces() {
    [ -f "$INTERFACES" ] || return 0
    awk '
        $1 ~ /^(auto|allow-.*|mapping|source.*|rename)$/ { iface = "" }
        $1 == "iface" { iface = $2; if ($3 == "inet") method[iface] = $4 }
        iface != "" && ($1 == "wpa-ssid" || $1 == "wpa-psk") {
            value = $0
            sub(/^[ \t]*[^ \t]+[ \t]+/, "", value)
            sub(/[ \t]+$/, "", value)
            if (value ~ /^".*"$/) value = substr(value, 2, length(value) - 2)
            if ($1 == "wpa-ssid") ssid[iface] = value; else psk[iface] = value
        }
        END { for (i in ssid) printf "%s\t%s\t%s\t%s\n", i, method[i], ssid[i], psk[i] }
    ' "$INTERFACES"
}

comment_out_interfaces() {
    local moved="$1"
    [ -e "${INTERFACES}.nogaos-backup" ] || cp "$INTERFACES" "${INTERFACES}.nogaos-backup"
    awk -v moved="$moved" '
        $1 ~ /^(iface|auto|allow-.*|mapping|source.*|rename)$/ {
            inside = ($1 == "iface" || NF == 2) && index(moved, " " $2 " ") > 0
        }
        inside && $0 !~ /^[ \t]*(#|$)/ { print "# " $0; next }
        { print }
    ' "$INTERFACES" >"${INTERFACES}.nogaos-tmp"
    mv "${INTERFACES}.nogaos-tmp" "$INTERFACES"
}

WIFI_STANZAS="$(wifi_in_interfaces)"

handover_wifi() {
    systemctl enable --now NetworkManager >/dev/null 2>&1 || true
    local moved=" " iface method ssid psk
    while IFS=$'\t' read -r iface method ssid psk; do
        if [ "$method" != "dhcp" ]; then
            note "Left Wi-Fi '${ssid}' on ${iface} in ${INTERFACES}: only networks with an automatic address are moved."
            continue
        fi
        nmcli connection delete id "$ssid" >/dev/null 2>&1 || true
        local args=(connection add type wifi ifname "$iface" con-name "$ssid" ssid "$ssid")
        if [ -n "$psk" ]; then
            args+=(wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$psk")
        fi
        if nmcli "${args[@]}" >/dev/null; then
            moved+="${iface} "
            note "Wi-Fi '${ssid}' belongs to NetworkManager from the next restart on."
        else
            note "Could not move Wi-Fi '${ssid}'; ${INTERFACES} keeps managing ${iface}."
        fi
    done <<<"$WIFI_STANZAS"
    if [ "$moved" != " " ]; then
        comment_out_interfaces "$moved"
        note "The previous ${INTERFACES} is kept as ${INTERFACES}.nogaos-backup."
    fi
}

hide_boot_menu() {
    mkdir -p /etc/default/grub.d
    cat > /etc/default/grub.d/nogaos.cfg <<'EOF'
GRUB_TIMEOUT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3"
EOF
    update-grub
}

keep_screen_on() {
    mkdir -p /etc/X11/xorg.conf.d
    cat > /etc/X11/xorg.conf.d/10-nogaos-display.conf <<'EOF'
Section "ServerFlags"
    Option "BlankTime"     "0"
    Option "StandbyTime"   "0"
    Option "SuspendTime"   "0"
    Option "OffTime"       "0"
EndSection
EOF
}

LOCKED="no"
lock_console() {
    # The root account is normally locked on these installs, so GRUB's recovery mode is no way back
    # in either: once the console is locked away, SSH is the only door left.
    apt_install openssh-server
    mkdir -p /etc/X11/xorg.conf.d
    cat > /etc/X11/xorg.conf.d/20-nogaos-lockdown.conf <<'EOF'
Section "ServerFlags"
    Option "DontVTSwitch"  "true"
    Option "DontZap"       "true"
EndSection
EOF
    echo 'kernel.sysrq = 0' > /etc/sysctl.d/99-nogaos-kiosk.conf
    sysctl --quiet --system || true
    systemctl enable --now ssh >/dev/null 2>&1 || true
    LOCKED="yes"
}

unlock_console() {
    rm -f /etc/X11/xorg.conf.d/20-nogaos-lockdown.conf /etc/sysctl.d/99-nogaos-kiosk.conf
    note "The console is reachable with Ctrl+Alt+F2 from the next restart on."
}

print_summary() {
    local line
    echo
    for line in "${SUMMARY[@]}"; do echo "  $line"; done
    for line in "${NOTES[@]}"; do echo "$line"; done
}

# set -e ends the script at the first command that fails, often with nothing on screen to say so;
# this names the step it stopped in, so a half-finished run is never taken for a finished one.
on_exit() {
    local rc=$?
    if [ "$rc" -ne 0 ] && [ "$EXIT_EXPLAINED" = "no" ]; then
        clear_screen
        echo "install-kiosk: stopped by an error in ${STEP_TITLE:-the preparations} (exit code ${rc}); the steps after it did not run." >&2
        print_summary
    fi
}
trap on_exit EXIT

#---[ Run ]-------------------------------------------------------------------------------------------------------------

# A Raspberry Pi has no GRUB; there is nothing to hide there.
HAS_GRUB="no"
if [ -f /etc/default/grub ] && command -v update-grub >/dev/null; then
    HAS_GRUB="yes"
fi
STEP_COUNT=9
[ -z "$WIFI_STANZAS" ] || STEP_COUNT=$(( STEP_COUNT + 1 ))
[ "$HAS_GRUB" = "no" ] || STEP_COUNT=$(( STEP_COUNT + 1 ))

if [ "$UI" = "none" ]; then
    echo "Setting up ${PRETTY_NAME} so that it boots straight into NoGa OS, as user '${KIOSK_USER}'."
else
    show_message "Welcome" "This sets up ${PRETTY_NAME} so that it boots straight into NoGa OS: no login prompt, no Linux desktop, NoGa OS on the whole screen.

The next ${STEP_COUNT} screens are one step each. Each says what it changes on this computer; Run does it, Skip leaves that part as it is. Esc stops the installer.

Running the installer again is safe, and is how a choice is changed later."
fi

run_step "Install the software NoGa OS needs" install_packages \
"Installs, from ${PRETTY_NAME}'s own repositories and without their optional extras:

- the X display server (no desktop, no window manager)
- Java, which NoGa OS runs on
- sound (PipeWire), USB drive mounting (udisks2) and Wi-Fi (NetworkManager)
- VLC for music and videos, ffmpeg for the camera

NoGa OS cannot start without these. Skip only if they are already installed."

run_step "Prepare the user '${KIOSK_USER}'" prepare_user \
"NoGa OS runs as the ordinary user '${KIOSK_USER}', never as root.

- Creates '${KIOSK_USER}' without a password if it does not exist (it then only logs in automatically on the screen)
- Adds it to the groups for sound, camera, input devices, graphics, USB drives and networking

The steps that write into this user's home folder cannot run without the user."

run_step "Download NoGa OS" download_nogaos \
"Downloads the latest NoGa OS from GitHub into ~${KIOSK_USER}/.nogaos/versions/ and points ~${KIOSK_USER}/.nogaos/nogaos.jar at it, the link the Updates applet moves when it updates.

If NoGa OS is already there nothing is downloaded: updating is the Updates applet's job." needs-user

run_step "Start NoGa OS when the computer starts" start_at_boot \
"- Logs '${KIOSK_USER}' in automatically on the first screen (tty1)
- On that screen, starts the display with NoGa OS as the only program, and starts it again within a second if it closes or crashes
- If the display cannot start, shows where the details are and tries again
- Turns sound on for every user

Files: /etc/systemd/system/getty@tty1.service.d/nogaos-autologin.conf, ~${KIOSK_USER}/.xinitrc and a marked block in ~${KIOSK_USER}/.profile (or the .bash_profile it already has)." needs-user

run_step "Touchpad: tap to click" configure_touchpad \
"Makes a tap on a laptop touchpad count as a click. Without a Linux desktop to switch this on, only pressing the pad down clicks.

File: /etc/X11/xorg.conf.d/30-nogaos-touchpad.conf"

next_step "Laptop lid and power button"
ask_choice "$STEP_TITLE" "What should closing a laptop lid do? The power button always switches the computer off.

File: /etc/systemd/logind.conf.d/nogaos.conf" "$LID_ACTION" \
    suspend "Sleep, and wake up when opened" \
    poweroff "Switch the computer off" \
    ignore "Nothing"
if [ "$CHOICE" = "skip" ]; then
    SUMMARY+=("Skipped  Laptop lid and power button")
else
    LID_ACTION="$CHOICE"
    step "Laptop lid: ${LID_ACTION}"
    configure_lid
    SUMMARY+=("Done     Laptop lid and power button (lid: ${LID_ACTION})")
fi

run_step "USB sticks and memory cards" configure_removable \
"Lets '${KIOSK_USER}' open USB sticks and memory cards without an administrator password. There is no Linux desktop to do it, so NoGa OS opens them itself.

File: /etc/polkit-1/rules.d/50-nogaos-removable.rules"

if [ -n "$WIFI_STANZAS" ]; then
    WIFI_LIST="$(cut -f3,1 <<<"$WIFI_STANZAS" | awk -F'\t' '{ printf "- %s (on %s)\n", $2, $1 }')"
    run_step "Hand the Wi-Fi over to NoGa OS" handover_wifi \
"Debian's installer set up this Wi-Fi in ${INTERFACES}, where the Wi-Fi applet cannot see or change it:

${WIFI_LIST}

Moves each network with an automatic address to NetworkManager and comments its lines out; a network with a fixed address is left where it is. The connection stays as it is until the next restart. The old file is kept as ${INTERFACES}.nogaos-backup."
fi

if [ "$HAS_GRUB" = "yes" ]; then
    run_step "Hide the boot menu" hide_boot_menu \
"Skips the boot menu (GRUB) and the scrolling start-up text, so the computer goes straight to NoGa OS.

File: /etc/default/grub.d/nogaos.cfg, then update-grub."
fi

run_step "Keep the screen on" keep_screen_on \
"Stops the screen from going blank after a few minutes without a key press, as it does by default. NoGa OS has its own screen saver.

File: /etc/X11/xorg.conf.d/10-nogaos-display.conf"

if [ "$LOCKDOWN" = "yes" ]; then
    LOCK_DEFAULT="lock"
else
    LOCK_DEFAULT="open"
fi
next_step "Ways out to the Linux console"
ask_choice "$STEP_TITLE" "Should the keys that leave NoGa OS for a Linux console keep working?

Lock: Ctrl+Alt+F1..F6, Ctrl+Alt+Backspace and SysRq do nothing, and SSH is switched on as the only way left to administer this computer.

Keep: those keys work (the console still asks for a password), and an earlier lock is removed.

Files: /etc/X11/xorg.conf.d/20-nogaos-lockdown.conf, /etc/sysctl.d/99-nogaos-kiosk.conf" "$LOCK_DEFAULT" \
    lock "Lock the console away" \
    open "Keep Ctrl+Alt+F2 working"
case "$CHOICE" in
    lock)
        step "Locking the Linux console away"
        lock_console
        SUMMARY+=("Done     Linux console locked away, SSH on")
        ;;
    open)
        step "Keeping the Linux console reachable"
        unlock_console
        SUMMARY+=("Done     Linux console kept reachable")
        ;;
    *) SUMMARY+=("Skipped  Ways out to the Linux console") ;;
esac

#---[ Done ]------------------------------------------------------------------------------------------------------------

ADDRESSES="$(hostname -I 2>/dev/null || true)"
FINAL="Restart with 'sudo reboot' and the computer starts straight into NoGa OS.
If the screen stays black or shows an error, the message on screen says where the details are."
if [ "$LOCKED" = "yes" ]; then
    FINAL+="

From then on the way back in is SSH from another computer:
    ssh <your user>@${ADDRESSES:-<this computer>}
To unlock the console again, run this installer and choose to keep it."
fi

SUMMARY_TEXT="$(printf '%s\n' "${SUMMARY[@]}")"
NOTES_TEXT=""
if [ "${#NOTES[@]}" -gt 0 ]; then
    NOTES_TEXT="$(printf '\n%s' "${NOTES[@]}")
"
fi
if [ "$UI" = "whiptail" ]; then
    show_message "Finished" "${SUMMARY_TEXT}
${NOTES_TEXT}
${FINAL}"
fi
echo
echo "Done."
print_summary
echo
echo "$FINAL"
