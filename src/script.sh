#!/usr/bin/env bash

if ! [[ -v SYSTEM_SCRIPTS_CONFIG_ROOT ]]; then
    echo "\$SYSTEM_SCRIPTS_CONFIG_ROOT not set!"
    exit 1
fi

REPO_ROOT=$SYSTEM_SCRIPTS_CONFIG_ROOT
AMEND=$([ "$2" = "amend" ] && echo 0 || echo 1)
COMMAND="${$1,,}"

check_pwd () {
    if ! pwd | grep -q "^$REPO_ROOT"; then
        echo "Please move to $REPO_ROOT first!"
        exit 1
    fi
}

force_sudo () {
    /run/wrappers/bin/sudo true || exit 1
}

check_git () {
    if ! [[ $(git rev-parse --is-inside-work-tree) ]]; then
        echo "Not a git repo!"
        exit 1
    fi
}

commit () {
    if ! [[ $(git rev-parse --is-inside-work-tree) ]]; then return 0; fi
    git add "$REPO_ROOT"
    if [ "$AMEND" -eq 0 ]; then
        git commit --amend --no-edit
        return 0
    fi
    read -p "Commit message: " msg
    git commit -m "$msg"
}

if [[ "$COMMAND" == "--help" || "$COMMAND" == "help" ]]; then
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "    ╔═══════════════════════════════════════════════════════════════════════════════════════════╗    "
    echo "    ║     ____         __              __  __        __     __        __  ____  _ ___ __        ║    "
    echo "    ║    / __/_ _____ / /____ __ _    / / / /__  ___/ /__ _/ /____   / / / / /_(_) (_) /___ __  ║    "
    echo "    ║   _\ \/ // (_-</ __/ -_)  ' \  / /_/ / _ \/ _  / _ \`/ __/ -_) / /_/ / __/ / / / __/ // /  ║    "
    echo "    ║  /___/\_, /___/\__/\__/_/_/_/  \____/ .__/\_,_/\_,_/\__/\__/  \____/\__/_/_/_/\__/\_, /   ║    "
    echo "    ║      /___/                         /_/                                           /___/    ║    " 
    echo "    ║                                                                                           ║    "
    echo "    ╚═══════════════════════════════════════════════════════════════════════════════════════════╝    "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "           system rebuild ... Rebuilds your system to match the configuration                        "
    echo "                              defined in \`/config/flake.nix\`                                         "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "           system update .... Updates \`/config/flake.lock\` with the newest                         "
    echo "                              hashes in each channel and rebuilds the system                         "
    echo "                              if any packages have updates. Append \"amend\"                           "
    echo "                              to amend the last commit with this update                              "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "           system watch ..... Watches for all dconf changes and prints them                          "
    echo "                              to stdout in a Nix-compatible format, ready to                         "
    echo "                              be added to your config. Append \"amend\" to                             "
    echo "                              amend the last commit with this rebuild                                "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "           system commit .... Asks for a commit message and then commits a                           "
    echo "                              change to the system with that message                                 "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "           system log ....... Provides a summary commit history of the system                        "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "                                                                                                     "
    echo "           system version ... Lists the current version of system-scripts                            "
    echo "                                                                                                     "
    echo "                                                                                                     "
elif [[ "$COMMAND" == "--version" || "$COMMAND" == "version" ]]; then
    echo "1.0.0"
elif [[ "$COMMAND" == "rebuild" ]]; then
    check_pwd
    force_sudo
    commit
    /run/wrappers/bin/sudo nixos-rebuild switch --flake "$REPO_ROOT"
elif [[ "$COMMAND" == "update" ]]; then
    check_pwd
    force_sudo
    commit
    /run/wrappers/bin/sudo nix flake update --flake "$REPO_ROOT"
elif [[ "$COMMAND" == "commit" ]]; then
    check_pwd
    check_git
    commit
elif [[ "$COMMAND" == "log" ]]; then
    check_pwd
    check_git
    git log --oneline
elif [[ "$COMMAND" == "watch" ]]; then
    # horrible awk command brought to you by gpt-4o
    dconf watch / | awk '
        $0 ~ /^\// {
            path = substr($0, 2);
            n = split(path, parts, "/");
            key = parts[n];
            ns = "";
            for(i = 1; i < n; i++) {
              ns = ns parts[i] "/";
            }
            ns = substr(ns, 1, length(ns) - 1);

            getline val;
            gsub(/^[ \t]+/, "", val);
            gsub(/[ \t]+$/, "", val);
            if (val ~ /^'\''.*'\''$/) {
              sub(/^'\''/, "", val);
              sub(/'\''$/, "", val);
            }
            printf "\"%s\".%s = \"%s\";\n", ns, key, val;
            next;
        }
    '
else
    echo "Usage: system --help"
fi

exit 0
