# whatwedo - Docker Base Images

We at [whatwedo](https://whatwedo.ch/) are building and deploying all applications using Docker containers. For this reason we build and maintain some base docker images for our common needs. Even though our containers can be found on Docker Hub ([at the moment](https://news.ycombinator.com/item?id=35154025)), we recommend pulling them from our own Container Registry. 

#### whatwedo Registry
```
registry.whatwedo.ch/whatwedo/docker-base-images/[container_name]:[version]

# for example:
registry.whatwedo.ch/whatwedo/docker-base-images/php:v2.8
```

#### Docker Hub
```
whatwedo/[container_name]:[version]

# for example:
whatwedo/php:v2.8
```

## Versions

| Tag | State | OS | PHP Version | Node | Arch |
|---|---|---|---|---|---|
| [`v2.8`](https://github.com/whatwedo/docker-base-images/tree/v2.8) | **Stable** | Alpine 3.19 | 8.3 | 20.15 | `x86_64`, `aarch64` |
| [`v2.9`](https://github.com/whatwedo/docker-base-images/tree/v2.9) | **Stable** | Alpine 3.21 | 8.4 | 22.15 | `x86_64`, `aarch64` |
| [`v2.10`](https://github.com/whatwedo/docker-base-images/tree/v2.10) | Testing | Alpine 3.22 | 8.4 | 22.16 | `x86_64`, `aarch64` |


### Deprecated
| Tag | State | OS | PHP Version | Node | Arch |
|---|---|---|---|---|---|
| `v1.x` | Deprecated | Ubuntu 20.04 | 5.6-7.x | 14.x | `x86_64` |
| [`v2.2`](https://github.com/whatwedo/docker-base-images/tree/v2.2) | Deprecated | Alpine 3.12 | 7.4 | 12.22 | `x86_64` |
| [`v2.3`](https://github.com/whatwedo/docker-base-images/tree/v2.3) | Deprecated | Alpine 3.12 | 8.0 | 12.22 | `x86_64` |
| `v2.4` | Not released | Alpine 3.15 | 7.4 | 16.14 | `x86_64` |
| [`v2.5`](https://github.com/whatwedo/docker-base-images/tree/v2.5) | Deprecated | Alpine 3.16 | 8.1 | 16.15 | `x86_64` |
| [`v2.6`](https://github.com/whatwedo/docker-base-images/tree/v2.6) | Deprecated | Alpine 3.17 | 8.1 | 18.12 | `x86_64`, `aarch64` |
| [`v2.7`](https://github.com/whatwedo/docker-base-images/tree/v2.7) | Deprecated | Alpine 3.18 | 8.2 | 18.16 | `x86_64`, `aarch64` |

## Docs

for a list of all images and documentation please take a look at the README in the specific version branch:

https://github.com/whatwedo/docker-base-images/branches/all?query=v


## Bugs and Issues

If you have any problems with this image, feel free to open a new issue in our issue tracker https://github.com/whatwedo/docker-base-images/issues.


## License

This image is licensed under the MIT License. The full license text is available under https://github.com/whatwedo/docker-base-images/blob/v2.5/LICENSE.


## Further information

There are a number of images we are using at [whatwedo](https://whatwedo.ch/). Feel free to use them. More information about the other images are available in [our Github repo](https://github.com/whatwedo/docker-base-images).
co