# Build Images
To function properly, `build.sh` needs a few things from your machine. It uses the buildx feature of docker, therefore you need to install `docker`.
Buildx uses a container on your machine to build the images. Please create said container using the following command from inside the project root: 
```bash
docker buildx create --name whatwedo-builder --config buildkit.toml --use
```
This will automatically load the configuration from the buildkit.toml in this project.
For an example on how to configure buildkit take a look at this [GitHub Repo](https://github.com/docker/buildx/blob/master/docs/guides/custom-registry-config.md).
