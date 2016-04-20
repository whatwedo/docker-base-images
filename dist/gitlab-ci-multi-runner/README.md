# whatwedo base image - GitLab Runner

## Usage

```
docker run whatwedo/gitlab-ci-multi-runner
```

## Register runner

### Checking Application Status

```
docker exec -i -t ID bash -c "gitlab-ci-multi-runner register"

```

## Volumes

* /etc/firstboot
* /etc/gitlab-runner

## License

This image is licensed under the MIT License. The full license text is available under [https://github.com/whatwedo/docker-base-images/blob/master/LICENSE](https://github.com/whatwedo/docker-base-images/blob/master/LICENSE).

## Further information

There are a number of images we are using at [https://whatwedo.ch/](whatwedo). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).
