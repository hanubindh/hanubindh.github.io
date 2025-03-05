# Setting up SelPy with Docker (Single-Line Command)

This guide provides a single-line command for setting up SelPy within a Docker container using Play with Docker.

1.  **Open Play with Docker:**
    [Play with Docker](https://labs.play-with-docker.com/)

2.  **Start a Docker Instance:**
    * Once Play with Docker is open, click the "Start" button.
    * Then, click "+ ADD NEW INSTANCE". This will create a new Docker instance.

3.  **Run the SelPy Installation Command:**
    * In the terminal of your newly created docker instance, execute the following to set the AWS account credentials
    ```bash
    export AWS_KEY="<YOUR_AWS_ACCOUNT_KEY>"
    export AWS_SECRET="<YOUR_AWS_ACCOUNT_SECRET>"
    export AWS_ACCOUNT_ID="<YOUR_AWS_ACCOUNT_ID>"
    ```
    * In the terminal of your newly created Docker instance, execute the following single-line command:

    ```bash
    source <(curl -s https://raw.githubusercontent.com/hanubindh/hanubindh.github.io/refs/heads/master/projects/Lambdas/SelPy/run.sh)
    ```

    * **Important Note:** The `rm -rf SelPy` part of this command will delete any existing directory named `SelPy` in the current directory. Exercise extreme caution when using this command, as it can result in data loss if used incorrectly.

    * **Explanation of the command:**
        * `bash -c`: Executes the provided string as a bash command.
        * `set -euo pipefail`: Enables strict error handling.
        * `rm -rf SelPy`: Removes the SelPy directory if it exists.
        * `mkdir SelPy`: Creates a directory named "SelPy".
        * `cd SelPy`: Navigates into the "SelPy" directory.
        * `curl -s "https://hanubindh.github.io/projects/Lambdas/SelPy/pack.tgz.b64"`: Downloads the base64 encoded archive.
        * `openssl base64 -d`: Decodes the base64 data.
        * `tar -zxv`: Extracts the contents of the archive.
        * `chmod +x deploy.sh`: Makes the `deploy.sh` script executable.
        * `./deploy.sh`: Executes the `deploy.sh` script to complete the SelPy setup.
