# Docker Run Command Extractor

This script allows users to easily extract the `docker run` command from a running container. It generates a command that includes all the parameters such as environment variables and port mappings used when the container was initiated.

## Usage

```bash
./extract_docker_run.sh <container_name>
```

## Output

The script outputs a `docker run` command with all the parameters formatted properly. Here is an example output:

```bash
docker run \
     --name nodeodm \
     -e "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
     -e "DEBIAN_FRONTEND=noninteractive" \
     -e "PYTHONPATH=:/code/SuperBuild/install/lib/python3.9/dist-packages:/code/SuperBuild/install/lib/python3.8/dist-packages:/code/SuperBuild/install/bin/opensfm" \
     -e "LD_LIBRARY_PATH=:/code/SuperBuild/install/lib" \
     -e "PDAL_DRIVER_PATH=/code/SuperBuild/install/bin" \
     -p 0.0.0.0:3002 \
# Image Name: opendronemap/nodeodm
```

## Version

1.0.0

## Credits

This script was developed with the assistance of OpenAI's GPT-3, specifically the ChatGPT model. The project facilitated the creation of a script that makes it easier to extract `docker run` commands from running containers, thereby aiding in the replication and sharing of docker container configurations.

## License

[MIT License](LICENSE)
