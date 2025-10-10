# Docker and Docker Compose Installer

This script automates the installation of Docker and Docker Compose on Debian and Ubuntu systems. It is designed with security and robustness in mind.

## Key Features

- **Automated Installation**: Installs Docker and Docker Compose with a single command.
- **OS Detection**: Automatically detects if the OS is Debian or Ubuntu.
- **Checksum Verification**: Verifies the integrity of the downloaded `docker-compose` binary to protect against tampering.
- **Security-Conscious**: Provides clear warnings about the security implications of adding a user to the `docker` group.

## Installation

We strongly advise against using the `curl | sudo bash` method, as it can expose you to security risks. Instead, we recommend the following secure installation process:

1.  **Download the script:**
    ```bash
    curl -o docker-installer.sh -fsSL https://raw.githubusercontent.com/AstralElite-open-source/docker/main/docker.sh
    ```

2.  **Review the script:**
    Before running it, carefully inspect the script's contents to ensure it is safe.
    ```bash
    less docker-installer.sh
    ```

3.  **Make the script executable:**
    ```bash
    chmod +x docker-installer.sh
    ```

4.  **Run the installer:**
    ```bash
    ./docker-installer.sh
    ```

This method ensures that you are running a script you have personally verified.

## How It Works

The script performs the following actions:
- Detects the OS (Debian or Ubuntu).
- Updates the package index.
- Installs necessary dependencies.
- Adds Docker's official GPG key.
- Sets up the appropriate Docker repository.
- Installs Docker Engine.
- Downloads the latest version of Docker Compose and verifies its checksum.
- Asks for confirmation before adding the current user to the `docker` group, explaining the security risks.
- Starts and enables the Docker service.

---

*This project is intended to provide a secure and reliable way to install Docker. Always practice caution when running scripts with elevated privileges.*