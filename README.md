# Termux-scripts
# Termux Maintenance Script

## Description

This script automates the maintenance of a Termux environment on Android devices. It performs the following tasks:

*   **Soft Reset (Optional):** Clears the Termux home directory (except `.bash_history` and `storage`), and the `apt` cache, effectively resetting the Termux environment to a cleaner state while preserving important data.
*   **Finds and Sets the Fastest Mirror:** Tests a list of Termux mirrors and automatically configures Termux to use the fastest one, improving package download speeds.
*   **Installs Essential Packages:** Installs a curated list of useful packages for development, system administration, and general Termux usage.
*   **Cleans Up:** Removes orphaned packages and clears the `apt` cache to free up storage space.
*   **Verifies Environment:** Checks that the `PREFIX` and `PATH` environment variables are set correctly and offers to fix them if necessary.
*   **Updates Packages:** Updates the `apt` package list and offers to upgrade installed packages.
*   **Self-Repair (Optional):** If configured, the script can download and reinstall itself from a specified URL, ensuring you have the latest version and verifying its integrity using a SHA256 hash.

## Packages Installed

This script installs the following packages:

*   `neovim`: A powerful and extensible text editor.
*   `python`: The Python 3 programming language.
*   `python-pip`: The package installer for Python.
*   `rust`: The Rust programming language and Cargo package manager.
*   `clang`: A C/C++/Objective-C compiler (useful for compiling many tools).
*   `curl`: A tool for transferring data with URLs.
*   `wget`: A tool for non-interactive download of files from the web.
*   `git`: The distributed version control system.
*   `openssh`: Secure Shell for remote access.
*   `htop`: An interactive process viewer.
*   `proot`: A tool for running Linux distributions in a Termux chroot.
*   `tar`: An archiving utility.
*   `gzip`: A file compression utility.
*   `bzip2`: Another file compression utility.
*   `dialog`: A tool for creating interactive dialogs in scripts.
*   `fd`: A fast and user-friendly alternative to `find`.
*   `ripgrep`: A fast and user-friendly alternative to `grep`.
*   `libsqlite`: The SQLite library.
*   `libxml2`: An XML processing library.
*   `libxslt`: An XSLT processing library.
*   `nmap`: A network scanning and discovery tool.
*   `tcpdump`: A network traffic analyzer.
*   `tree`: A command to display directory structures as a tree.
*   `ncdu`: An ncurses-based disk usage analyzer.
*   `rsync`: A fast file copying tool (local and remote).
*   `unzip`: A tool for extracting zip archives.
*   `zip`: A tool for creating zip archives.
*   `ffmpeg`: A multimedia framework for handling audio and video.

You can customize the `packages_to_install` array in the script to modify this list.

## Usage

1.  **Download the Script:**
    ```bash
    wget -O termux_maintenance.sh <URL_TO_YOUR_SCRIPT>
    ```
    (Replace `<URL_TO_YOUR_SCRIPT>` with the actual URL, e.g., the raw GitHub URL if you are hosting it there).

2.  **Make it Executable:**
    ```bash
    chmod +x termux_maintenance.sh
    ```

3.  **Run the Script:**
    ```bash
    ./termux_maintenance.sh
    ```

4.  **Follow the Prompts:** The script will ask you if you want to perform a soft reset and if you want to upgrade packages.

## Configuration

### `script_url` (for Self-Repair)

To enable self-repair, you need to host the script online (e.g., on GitHub, GitLab, or your own server).

1.  **Host the Script:** Upload the script to your chosen host.
2.  **Get the Raw URL:** Obtain the raw URL of the script file.
3.  **Create a Hash File:** Create a file named `termux_maintenance.sh.sha256` (or `<your_script_name>.sh.sha256`) in the same location as your script. This file should contain only the SHA256 hash of your script. You can generate the hash using the `sha256sum termux_maintenance.sh` command in Termux.
4.  **Update `script_url`:** In your `termux_maintenance.sh` script, set the `script_url` variable to the raw URL of the hosted script.

### `script_hash`

The `script_hash` variable is used to verify the integrity of the script downloaded during self-repair.

1.  **Calculate the SHA256 Hash:** After making changes to your script, calculate its SHA256 hash using:
    ```bash
    sha256sum termux_maintenance.sh
    ```

2.  **Update `script_hash`:** Copy the hash output (the long hexadecimal string) and paste it into the `script_hash` variable in your script, replacing the existing value.

## Important Notes

*   **Do not run this script as root.** It should be run as a regular Termux user.
*   The soft reset option will delete files and directories in your Termux home directory, except for `.bash_history` and the `storage` directory. **Back up any important data before proceeding.**
*   Review the `packages_to_install` array and modify it to fit your needs.
*   Keep the `script_hash` up-to-date if you modify the script and are using the self-repair feature.

## Version History

*   **2.9:** (Current) Added a curated list of essential packages. Improved soft reset functionality. Enhanced error handling and logging. Added concurrent mirror testing.
*   **2.8:**  Added `termux-chroot` usage for commands needing elevated privileges within the Termux environment.
*   **2.7:**  Reduced mirror test timeout to 5 seconds. Implemented concurrent mirror testing (4 at a time).
*   **2.6:**  Introduced the soft reset option to clear the home directory while preserving `.bash_history` and `storage`.
*   **2.5 - 1.0:** (Previous versions with incremental improvements)

## Author

**Michael David Norris**

## Credits

This script was developed by Michael David Norris with contributions, suggestions, and inspiration from the following:

*   **The Termux Community:** For providing a powerful and versatile platform for Android terminal emulation and for the development of numerous useful packages.
*   **The Developers of the Packages:** This script relies on the excellent work of the developers who created and maintain the packages listed in the `packages_to_install` array.
*   **ChatGPT:**  Assisted in refining and optimizing various parts of the code, particularly in implementing the concurrent mirror testing and improving error handling. Also for providing valuable input on code structure and clarity, as well as assistance in writing and polishing this README.

## License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details. (You can choose a different license if you prefer)
