### Dockerize

Dockerize is a command-line bash utility for managing Docker containers.
This is the sort of Docker workflow that it's meant to automate:

* let's take a Ruby example app, [hi_sinatra][hi_sinatra-docker]. It
  has its own Github repository and we have a simple, non-git Jenkins
job for it.

* every commit pushed to Github, regardless of the branch, triggers a
  Jenkins build (via Amazon SQS). All Jenkins builds will result in a
Docker image. A successful build will produce a running Docker
container. A failed build will produce a stopped container which can be
investigated by either looking at the logs or starting it with a tty
attached.

* if Docker doesn't have a **hi_sinatra:master** pre-built image,
  a new one will be created from the master branch. This master image
gets re-built every time there's a commit against the master branch.
Having a master image speeds up image builds considerably (eg.
installing Ruby gems, installing node modules, C extensions etc). The
resulting image won't use any caching and all intermediary images will
be removed. Just to clarify, this image will not be shipped into
production.

* if a Docker image with that app's name, branch name and git commit sha
  doesn't exist, we want Docker to build it for us. At this point, we're
interested to have the eg. **hi_sinatra:second-blog-post.a8e8e83**
Docker image available.

* before a new container can be started from the image that we've just
  built, all services that the app requires must be running in their own
independent containers. Our **hi_sinatra** example app requires a
running Redis server.

* when all dependent services are running in their own containers, we
  start a container from the newly built app image (in our example,
**hi_sinatra:second-blog-post.a8e8e83**). All dependent containers will
have their IPs exposed via env options, eg. `docker run -e
REDIS_HOST=172.17.0.8 -d ...`

* before our **hi_sinatra** app starts in its new Docker container, all
  tests must pass - both unit, integration and acceptance. Full stack
tests (also known as acceptance tests) use sandbox services, but they
are setup via the same Docker containers that will be made available in
production. Code portability is Docker's strongest point, we're making
full use of it.

* if everything worked as expected, including interactions with all
  external services, this Docker image will be tagged as
production. The service responsible for bringing up new Docker
containers from the latest production images will take it from here.

Related blog post: [Continuous Delivery with Docker and Jenkins - part
II][blog_post]

[hi_sinatra-docker]: https://github.com/cambridge-healthcare/hi_sinatra-docker/tree/v0.2.0
[blog_post]: http://blog.howareyou.com/post/65048170054/continuous-delivery-with-docker-and-jenkins-part-ii
