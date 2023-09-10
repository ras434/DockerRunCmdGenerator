
# Docker Run Command Generator

## Description
This script allows you to generate `docker run` commands from running Docker containers. It can either generate a command for a specific container or for all running containers, saving the commands to separate files.

## Requirements
- Docker
- Bash shell

## Installation
You can directly download the script from the GitHub repository and give it executable permissions using the following commands:

```sh
curl -O https://raw.githubusercontent.com/ras434/DockerRunCmdGenerator/main/drg.sh
chmod +x drg.sh
```

## Usage
To generate a `docker run` command for a specific container, run the script with the container name as an argument:

```sh
./drg.sh <container_name>
```

To generate `docker run` commands for all running containers and save them to separate files, run the script with the `--backup` option:

```sh
./drg.sh --backup
```

If no argument is provided, the script will list all running containers and prompt you to select one.

## Credits
This project was developed with the assistance of OpenAI's ChatGPT. 

## Version Details
- Version: 1.0.0
- Release Date: 2023-09-10

## License
This project is licensed under the MIT License.
