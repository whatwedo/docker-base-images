# whatwedo base image - Kibana
In this image are is the Kibana data exploration UI installed.

## Usage

```
docker run -p 5601:5601 -e ELASTICSEARCH_URL=http://elasticsearch:9200 whatwedo/kibana
```

## Environment Variables

* `ELASTICSEARCH_URL` - URL to your [Elasticsearch](https://registry.hub.docker.com/u/whatwedo/elasticsearch/) installation.

## Volumes

* /etc/firstboot

## Exposed Ports

* 5601

## Built

Because we are using several base images with recurring tasks in the Dockerfile, we are using a script to include commands. This script is available under [https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh](https://github.com/whatwedo/docker-base-images/blob/master/docker-builder.sh)

## Bugs and Issues

If you have any problems with this image, feel free to open a new issue in our issue tracker [https://github.com/whatwedo/docker-base-images/issues](https://github.com/whatwedo/docker-base-images/issues)

## License

This image is licensed under the MIT License. The full license text is available under [https://github.com/whatwedo/docker-base-images/blob/master/LICENSE](https://github.com/whatwedo/docker-base-images/blob/master/LICENSE).

## Further information

There are a number of images we are using at [https://whatwedo.ch/](whatwedo). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).