#!/bin/bash

# --- Configuration ---
mirrors=(
  "https://mirrors.tuna.tsinghua.edu.cn/termux/termux-main"
  "https://termux.mentality.rip/termux-main"
  "https://mirrors.cqu.edu.cn/termux/termux-main/"
  "https://mirror.albony.xyz/termux/termux-main/"
  "https://mirror.accum.se/termux/termux-main/"
  "https://packages.termux.org/apt/termux-main"
  "https://termux.cdn.lumito.net/termux-main/"
  "https://termux.astra.in.th/apt/termux-main/"
  "https://ftp.gwdg.de/pub/misc/termux/termux-main/"
  "https://termux.mirror.wearetriple.com/termux-main/"

)

# Packages to install (carefully selected for general use)
packages_to_install=(
  "neovim"       # Powerful text editor (alternative to vim)
  "python"       # Essential programming language
  "python-pip"   # Package installer for Python
  "rust"         # For compiling and running Rust code (increasingly popular)
  "clang"        # Compiler for C/C++ (useful for compiling many tools)
  "curl"         # Tool for transferring data with URLs
  "wget"         # Tool for non-interactive download of files from the web
  "git"          # Distributed version control system
  "openssh"      # Secure shell for remote access
  "htop"         # Interactive process viewer (better than top)
  "proot"        # For running distributions in a compatibility layer
  "tar"          # Archiving utility
  "gzip"         # Compression utility
  "bzip2"        # Another compression utility
  "dialog"       # For creating interactive dialog boxes in the script
  "fd"           # Faster and user-friendly alternative to 'find'
  "ripgrep"      # Faster and user-friendly alternative to 'grep'
  "libsqlite"    # SQLite library (often a dependency for other tools)
  "libxml2"      # XML library (often a dependency)
  "libxslt"      # XSLT library (often a dependency)
  "nmap"         # Network scanning and discovery tool
  "tcpdump"      # Network traffic analyzer
  "tree"         # Display directory structure as a tree
  "ncdu"         # Disk usage analyzer (ncurses-based)
  "rsync"        # Fast file copying tool (local and remote)
  "unzip"        # For extracting zip archives
  "zip"          # For creating zip archives
  "ffmpeg"       # Multimedia framework (audio/video processing)
)

# --- Script Metadata ---
script_name=$(basename "$0")
script_version="2.9"
log_file="/data/data/com.termux/files/home/$script_name.log"
script_url="" # Set this to the URL where the script can be downloaded for self-repair
script_hash="93c8b6308e0b0b843b2a57acf07cb33c99ae01fd272122db8882f997266a6cd6"  # <<<--- Replace with the actual hash of your script

# --- Spinner Characters ---
spinners=(
  "✨🦐🥒🦶<(^-^o) |🦐🥒🦶<(^o^)>🔥🧹🗑| (o^-^)>✨️🍶🥣🍽✨"  # Resetting
  "✨ 👵📖💻<(^-^o) | 👵📖💻<(^o^)>💭👓⏳️| (o^-^)>💕📝🎵✨" # Lookup
  "✨ 🎣<(^-^o) | 🎣<(^o^)>🐟 | (o^-^)>🐟🐟✨"           # Testing
  "✨🐟🐟<(^_^o) | 🐟🐟<(^O^)>🔥 | 🔪 (o^_^)>🍥🍣✨"         # Final Settings
  "✨🍖🦴🍽<(^-^o) | 🍖🦴🗑️<(^o^)> | 🧹🗑️🧼  (o^-^)> 🍾🥂🍻✨" # Cleanup
  "✨ 🛠️<(^-^o) | 🛠️<(^o^)> ⚙️ | (o^-^)> 🚀✨"       # Package Installation
  "✨ 🧽<(^-^o) | 🧽<(^o^)> 🫧 | (o^-^)> ✨🧽✨"       # Cleaning
  "✨ 🔍<(^-^o) | 🔍<(^o^)> ✅ | (o^-^)> 💯✨"    # Verification and Update
  "✨ 🐳<(^-^o) | 🐳<(^o^)> 🛟 | (o^-^)> 🔒✨"       # Container Integrity
  "✨ 🕵️<(^-^o) | 🕵️<(^o^)> 🚨 | (o^-^)> 🛡️✨"   # Anomaly Detection
)

# --- Functions ---

# --- Progress Spinner Function ---
progress_spinner() {
  local spinner_index frames num_frames i
  spinner_index=$1
  mapfile -d '|' -t frames < <(printf '%s|' "${spinners[$spinner_index]}")
  num_frames=${#frames[@]}
  i=0

  # Hide cursor
  echo -ne "\033[?25l"

  # Save cursor position
  echo -ne "\033[s"

  while true; do
    # Restore cursor position
    echo -ne "\033[u"

    # Clear the line
    echo -ne "\r\033[K"

    # Build the progress bar
    local progress_bar=""
    for ((j = 0; j < num_frames; j++)); do
      if ((j <= i)); then
        progress_bar+=" ${frames[$j]}"
      else
        progress_bar+=" -"
      fi
    done

    # Print the progress bar
    printf "\r%s" "$progress_bar"

    i=$(((i + 1) % num_frames))
    sleep 0.3

    # Check if the parent process has finished
    if ! kill -0 "$2" 2>/dev/null; then
      break
    fi
  done

  # Show cursor again
  echo -ne "\033[?25h"
}

# --- Mirror Test Function ---
test_mirror() {
  local mirror temp_file start_time end_time download_time
  mirror="$1"
  temp_file=$(mktemp)
  start_time=$(date +%s.%N)

  # Using curl with progress bar, timing, and timeout reduced to 5 seconds
  if curl --max-time 5 -s -w "%{time_total}" -o "$temp_file" "$mirror/dists/stable/main/binary-$(dpkg --print-architecture)/coreutils_*.deb" > /dev/null; then
    end_time=$(date +%s.%N)
    download_time=$(echo "scale=3; $end_time - $start_time" | bc)
    if (( $(echo "$download_time > 0" | bc -l) )); then
      rm -f "$temp_file"
      echo "$download_time"
      return 0 # Success
    fi
  else
    log_message "WARNING" "Mirror $mirror timed out or failed."
  fi
  rm -f "$temp_file"
  return 1
}

# --- Logging Function ---
log_message() {
  local log_level message timestamp
  log_level="$1"
  message="$2"
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  echo "[$timestamp] [$log_level] $message" >> "$log_file"
}

# --- Error Handling Function ---
error_handler() {
  local error_message exit_code
  error_message="$1"
  exit_code="${2:-1}"

  log_message "ERROR" "$error_message"

  # Send error message to standard error
  echo -e "\n❌ Error: $error_message" >&2

  # Attempt to send a Termux notification (if termux-api is installed)
  if command -v termux-notification &> /dev/null; then
    termux-notification --id "$script_name-error" --title "Error in $script_name" --content "$error_message"
  fi

  # Offer to open the log file or attempt self-repair
  if command -v termux-open &> /dev/null; then
    if dialog --yesno "An error occurred. Do you want to open the log file ($log_file) or attempt self-repair?" 0 0; then
      if dialog --yesno "Do you want to open the log file?" 0 0; then
        termux-open "$log_file"
      elif dialog --yesno "Do you want to attempt self-repair?" 0 0; then
        self_repair
      fi
    fi
  fi

  exit "$exit_code"
}

# --- Self-Repair Function ---
self_repair() {
  log_message "INFO" "Attempting self-repair..."

  # 1. Re-download the script (if a URL is provided)
  if [[ -n "$script_url" ]]; then
    log_message "INFO" "Re-downloading script from $script_url"

    # Get the expected hash from a separate URL (or other trusted source)
    script_hash_url="$script_url.sha256"
    expected_hash=$(curl -s "$script_hash_url")

    if ! curl -s -o "$0" "$script_url"; then
      error_handler "Failed to re-download script during self-repair"
    fi

    # 2. Verify the downloaded script's hash
    downloaded_hash=$(sha256sum "$0" | awk '{print $1}')
    if [[ "$downloaded_hash" != "$expected_hash" ]]; then
      error_handler "Downloaded script hash does not match expected hash! Aborting self-repair."
    fi

    log_message "INFO" "Downloaded script hash verified successfully."

  else
    log_message "WARNING" "Script URL not provided. Cannot re-download during self-repair."
  fi

  # 3. Make the script executable again
  chmod +x "$0" || error_handler "Failed to make script executable during self-repair"

  # 4. Re-run the script
  log_message "INFO" "Re-running the script..."
  exec "$0" || error_handler "Failed to re-run the script during self-repair"
}

# --- Package Installation Function ---
install_packages() {
  echo -e "\n"
  {
    printf "Installing packages...\n"
    for package in "${packages_to_install[@]}"; do
      if ! termux-chroot apt show "$package" &> /dev/null; then
        log_message "WARNING" "Package '$package' is not available."
        continue
      fi
      if ! termux-chroot apt install -y "$package"; then
        log_message "ERROR" "Failed to install package: $package"

        # Attempt to fix broken dependencies
        if ! termux-chroot apt --fix-broken install -y; then
          log_message "ERROR" "Failed to fix broken dependencies after '$package' installation failure."
        else
          log_message "INFO" "Attempted to fix broken dependencies."
          if ! termux-chroot apt install -y "$package"; then # Retry installing the package
            log_message "ERROR" "Still failed to install package: $package"
          else
            log_message "INFO" "Package $package installed successfully after fixing dependencies."
          fi
        fi
      else
        log_message "INFO" "Package $package installed successfully."
      fi
    done
  } &>/dev/null &
  progress_spinner 5 $! &
  spinner_pid=$!
  wait
  kill "$spinner_pid"
  wait "$spinner_pid"
  echo -e "\rPackage installation... Done"
}

# --- Cleanup Function ---
clean_termux() {
  echo -e "\n"
  {
    printf "Cleaning up Termux installation...\n"

    # Remove orphaned packages
    printf "Removing orphaned packages...\n"
    if ! termux-chroot apt autoremove -y; then
      log_message "WARNING" "Failed to remove orphaned packages"
    fi

    # Clean apt cache
    printf "Cleaning apt cache...\n"
    if ! termux-chroot apt clean; then
      log_message "WARNING" "Failed to clean apt cache"
    fi

    # Remove unnecessary files (customize as needed)
    printf "Removing unnecessary files...\n"
    termux-chroot find /data/data/com.termux/files/usr/tmp -type f -delete -print | while IFS= read -r file; do
      log_message "INFO" "Deleted file: $file"
    done

    # Add more cleanup steps here if needed
  } &>/dev/null &
  progress_spinner 6 $! &
  spinner_pid=$!
  wait
  kill "$spinner_pid"
  wait "$spinner_pid"
  echo -e "\rTermux cleanup... Done"
}

# --- Path and Environment Verification Function ---
verify_environment() {
  echo -e "\n"
  {
    printf "Verifying environment...\n"

    # Determine the user's shell
    local user_shell
    user_shell=$(getent passwd "$(whoami)" | cut -d: -f7)

    # Determine the profile file based on the shell
    local profile_file
    if [[ "$user_shell" == *"/bash" ]]; then
      profile_file="/data/data/com.termux/files/usr/etc/bash.bashrc"
    elif [[ "$user_shell" == *"/zsh" ]]; then
      profile_file="/data/data/com.termux/files/usr/etc/zshrc"
    else
      log_message "WARNING" "Unsupported shell: $user_shell. Profile file check skipped."
      profile_file=""
    fi

    # Check if $PREFIX is set correctly
    if [ -z "$PREFIX" ] || [ "$PREFIX" != "/data/data/com.termux/files/usr" ]; then
      log_message "WARNING" "PREFIX environment variable is not set correctly or unset."
      if dialog --yesno "PREFIX is not set correctly. Do you want to set it in $profile_file?" 0 0; then
        if [[ -n "$profile_file" ]]; then
          if ! termux-chroot grep -q '^export PREFIX=' "$profile_file"; then
            termux-chroot <<-EOF
              echo 'export PREFIX=/data/data/com.termux/files/usr' >> "$profile_file"
            EOF
            log_message "INFO" "Added PREFIX to $profile_file"
          else
            termux-chroot sed -i 's|^export PREFIX=.*|export PREFIX=/data/data/com.termux/files/usr|' "$profile_file"
            log_message "INFO" "Updated PREFIX in $profile_file"
          fi
          # shellcheck disable=SC1090
          source "$profile_file"
        else
          log_message "WARNING" "Could not determine profile file. PREFIX not set."
        fi
      fi
    fi

    # Check if $PATH contains essential directories
    required_paths=("/data/data/com.termux/files/usr/bin" "/data/data/com.termux/files/usr/bin/applets")
    for path in "${required_paths[@]}"; do
      if ! echo "$PATH" | grep -q "$path"; then
        log_message "WARNING" "PATH environment variable is missing essential directory: $path"
        if dialog --yesno "PATH is missing essential directories. Do you want to add them to $profile_file?" 0 0; then
          if [[ -n "$profile_file" ]]; then
            if ! termux-chroot grep -q "^export PATH=$path" "$profile_file"; then
              termux-chroot sed -i "s|export PATH=|export PATH=$path:|" "$profile_file"
              log_message "INFO" "Added $path to PATH in $profile_file"
            else
              log_message "INFO" "$path already exists in PATH in $profile_file"
            fi
            # shellcheck disable=SC1090
            source "$profile_file"
          else
            log_message "WARNING" "Could not determine profile file. PATH not modified."
          fi
        fi
      fi
    done

    # Check for updates
    if ! termux-chroot apt update; then
      log_message "WARNING" "Failed to update package list."
    else
      if ! termux-chroot apt list --upgradable; then
        log_message "WARNING" "Failed to list upgradable packages."
      else
        upgradable_count=$(termux-chroot apt list --upgradable 2>/dev/null | wc -l)
        if [[ "$upgradable_count

-gt 1 ]]; then  # Subtract 1 to account for the header line
          log_message "INFO" "$upgradable_count packages can be upgraded."
          if dialog --yesno "There are $upgradable_count packages that can be upgraded. Do you want to upgrade them now?" 0 0; then
            if ! termux-chroot apt upgrade -y; then
              log_message "ERROR" "Failed to upgrade packages."
            else
              log_message "INFO" "Packages upgraded successfully."
            fi
          fi
        else
          log_message "INFO" "No packages need to be upgraded."
        fi
      fi
    fi
  } &>/dev/null &
  progress_spinner 7 $! &
  spinner_pid=$!
  wait
  kill "$spinner_pid"
  wait "$spinner_pid"
  echo -e "\rEnvironment verification... Done"
}

# --- Main Script ---

# Check if running as root (not recommended)
if [[ $(id -u) -eq 0 ]]; then
  error_handler "Error: Do not run this script as root. It should be run as a regular user."
fi

# Welcome message
echo -e "
███████╗██╗   ██╗███████╗██████╗ ██╗ ██████╗ ███╗   ██╗███████╗    ██████╗  █████╗
██╔════╝██║   ██║██╔════╝██╔══██╗██║██╔════╝ ████╗  ██║██╔════╝    ██╔══██╗██╔══██╗
█████╗  ██║   ██║█████╗  ██████╔╝██║██║  ███╗██╔██╗ ██║█████╗      ██████╔╝███████║
██╔══╝  ██║   ██║██╔══╝  ██╔══██╗██║██║   ██║██║╚██╗██║██╔══╝      ██╔══██╗██╔══██║
██║     ╚██████╔╝███████╗██║  ██║██║╚██████╔╝██║ ╚████║███████╗    ██║  ██║██║  ██║
╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═╝

Welcome to the Termux Maintenance Script (v$script_version)!
This script will help you set up and maintain your Termux environment.
"

# Log script start
log_message "INFO" "Starting $script_name (v$script_version)..."
log_message "INFO" "User: $(whoami)"
log_message "INFO" "Device: $(uname -a)"

# Reset Termux environment
if dialog --yesno "Do you want to reset your Termux environment (soft reset)? This will clear your home directory, delete apt-repository but preserve storage data. Proceed?" 0 0; then
  echo -e "\n"
  {
    printf "Resetting Termux environment...\n"
    # List of directories and files to be removed
    items_to_remove=(
      "$HOME/.*"
      "!$HOME/.bash_history"  # Exclude .bash_history
      "!$HOME/storage"  # Exclude storage directory
      "$PREFIX/var/lib/apt/lists/*" #apt cache
      "$PREFIX/tmp/*"
      "$PREFIX/var/tmp/*"
    )

    # Loop through the items and remove them
    for item in "${items_to_remove[@]}"; do
      if [[ "$item" == "$HOME/.*" ]]; then
        # Remove all dot files/directories in $HOME except for .bash_history and storage
        find "$HOME" -mindepth 1 -maxdepth 1 -name '.*' -not -name '.bash_history' -not -name 'storage' -exec rm -rf {} +
      elif [[ "$item" == "!$HOME/.bash_history" ]] || [[ "$item" == "!$HOME/storage" ]]; then
        # Skip excluded items
        continue
      else
        # Remove other specified items
        rm -rf "$item"
      fi
    done
    printf "Termux environment reset.\n"
  } &>/dev/null &
  progress_spinner 0 $! &
  spinner_pid=$!
  wait
  kill "$spinner_pid"
  wait "$spinner_pid"
  echo -e "\rTermux environment reset... Done"
fi

# Find the fastest mirror
fastest_mirror=""
fastest_time="999"

echo -e "\n"
{
  printf "Finding the fastest mirror...\n"
  # Test mirrors concurrently, 4 at a time
  for i in $(seq 0 4 $((${#mirrors[@]} - 1))); do
      for j in $(seq 0 3); do
          index=$((i + j))
          if [[ $index -lt ${#mirrors[@]} ]]; then
              (
                  time=$(test_mirror "${mirrors[$index]}")
                  if [[ -n "$time" ]] && (( $(echo "$time < $fastest_time" | bc -l) )); then
                      fastest_time="$time"
                      fastest_mirror="${mirrors[$index]}"
                  fi
              ) &
          fi
      done
      wait
  done
  
  if [[ -z "$fastest_mirror" ]]; then
    log_message "ERROR" "Could not find a suitable mirror."
    fastest_mirror="https://packages.termux.org/apt/termux-main" # Default
  else
    log_message "INFO" "Fastest mirror found: $fastest_mirror (time: $fastest_time)"
  fi
  printf "Fastest mirror: %s\n" "$fastest_mirror"
} &>/dev/null &
progress_spinner 2 $! &
spinner_pid=$!
wait
kill "$spinner_pid"
wait "$spinner_pid"
echo -e "\rFinding the fastest mirror... Done"

# Set the fastest mirror
echo -e "\n"
{
  printf "Setting the fastest mirror as default...\n"
  # Remove existing sources.list entries
  if ! sed -i '/termux-main/d' "$PREFIX/etc/apt/sources.list"; then
      log_message "ERROR" "Failed to remove existing sources.list entries."
  fi
  # Add the fastest mirror to sources.list
  echo "deb $fastest_mirror stable main" > "$PREFIX/etc/apt/sources.list"

  # Verify that the sources.list has been updated
  if ! grep -q "$fastest_mirror" "$PREFIX/etc/apt/sources.list"; then
      log_message "ERROR" "Failed to update sources.list with the fastest mirror."
  else
      log_message "INFO" "Successfully set the fastest mirror in sources.list"
  fi

} &>/dev/null &
progress_spinner 3 $! &
spinner_pid=$!
wait
kill "$spinner_pid"
wait "$spinner_pid"
echo -e "\rSetting the fastest mirror as default... Done"

# Install packages
install_packages

# Clean up
clean_termux

# Verify environment and update
verify_environment

log_message "INFO" "$script_name completed successfully."
echo -e "\n✅ $script_name completed successfully!\n"

# Offer to open the log file
if command -v termux-open &> /dev/null; then
  if dialog --yesno "Do you want to open the log file ($log_file)?" 0 0; then
    termux-open "$log_file"
  fi
fi

