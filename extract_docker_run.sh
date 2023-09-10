#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <container_name>"
  exit 1
fi

CONTAINER_NAME=$1

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
