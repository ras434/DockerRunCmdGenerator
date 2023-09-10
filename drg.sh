#!/bin/bash

# Check if docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Please install Docker and try again."
    exit
fi

# Check if there are running containers
if [ -z "$(docker ps -q)" ]; then
    echo "No running containers found. Please start a container and try again."
    exit
fi

# If no argument is provided, list the running containers for the user to select
if [ -z "$1" ]; then
    echo "No container name provided. Please select a container from the list below:"
    select CONTAINER_NAME in "[Backup]" "[Exit]" $(docker ps --format "{{.Names}}")
    do
        case $CONTAINER_NAME in
            "[Backup]")                
                $0 --backup
                exit
                ;;
            "[Exit]")
                echo "Exiting..."
                exit
                ;;
            *)
                if [ -n "$CONTAINER_NAME" ]; then
                    break
                else
                    echo "Invalid selection. Please select a valid container or Exit."
                fi
                ;;
        esac
    done
# If the argument is "--backup", loop through running containers and backup the data to <container_name>.run file(s) in the current directory
elif [ "$1" == "--backup" ]; then
    echo "Backing up data for all running containers..."
    # Get the IP address of the host
    ip_address=$(hostname -I | awk '{print $1}')
    for CONTAINER_NAME in $(docker ps --format "{{.Names}}")
    do
        echo "     Backing up data for $CONTAINER_NAME..."
        # Use $0 $CONTAINER_NAME to pass the container name to the script
        $0 $CONTAINER_NAME > $CONTAINER_NAME.tmp
        echo "# Backup for $CONTAINER_NAME" > $CONTAINER_NAME.run
        echo "# Backup performed: $(date)" >> $CONTAINER_NAME.run
        echo "# Backup host: $(hostname) ($ip_address)" >> $CONTAINER_NAME.run
        cat $CONTAINER_NAME.tmp >> $CONTAINER_NAME.run
    done
    rm *.tmp
    # Create archive of all *.run files using the current date and time and hostname
    archive_name=$(date +%Y%m%d_%H%M%S)_$(hostname)-docker-run-backup.tar.gz
    echo "Creating archive of all .run files as $archive_name..."
    tar -czvf $archive_name *.run > /dev/null 2>&1
    rm *.run
    echo "Backup complete. Exiting..."
    exit
else
    CONTAINER_NAME=$1
fi

# Get the docker inspect output
docker inspect $CONTAINER_NAME > inspect_output.json

# Create a Dockerfile with Python installed
cat <<EOL > Dockerfile
FROM python:3.8-slim
COPY data_extraction_script.py /data_extraction_script.py
CMD ["python3", "/data_extraction_script.py"]
EOL

# Create a Python script file
cat <<'EOL' > data_extraction_script.py
import json

def extract_data(container_details):
    container_name = container_details[0]['Name'][1:]
    image_name = container_details[0]['Config']['Image']
    env_vars = container_details[0]['Config']['Env']
    env_vars_str = " \\\n".join([f'     -e "{env}"' for env in env_vars])

    ports = container_details[0]['NetworkSettings']['Ports']
    ports_str = ""
    for port, settings in ports.items():
        host_ip = settings[0]['HostIp'] if settings[0]['HostIp'] else "0.0.0.0"
        host_port = settings[0]['HostPort']
        ports_str += f"     -p {host_ip}:{host_port} \\\n"

    docker_run_command = f"docker run \\\n     --name {container_name} \\\n{env_vars_str} \\\n{ports_str}# Image Name: {image_name}"

    print(docker_run_command)

if __name__ == "__main__":
    with open('/data/inspect_output.json') as f:
        container_details = json.load(f)
    
    extract_data(container_details)
EOL

# Build a docker image
docker build -t data-extraction-image . > /dev/null 2>&1

# Run the container and remove it after it finishes executing
docker run --rm -v $(pwd)/inspect_output.json:/data/inspect_output.json data-extraction-image

# Remove the docker image
docker rmi data-extraction-image > /dev/null 2>&1

# Remove created files
rm Dockerfile data_extraction_script.py inspect_output.json

