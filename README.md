# ros-snap

This is a docker image that enables you to nicely cross-compile and pack your ROS project using snapcraft.
It might come in handy when you're setting up your CI/CD environment for your amazing ROS project!

# Using this Image

This is a trivial usage example and might not be a good development practice:

1. `cd` into your ROS project directory.
2. Run `snapcraft init` to generate the `snap/snapcraft.yml`.
3. Make necessary edits to your `snapcraft.yaml`. [This might be a good guide](http://wiki.ros.org/ROS/Tutorials/Packaging%20your%20ROS%20project%20as%20a%20snap) to follow on how to do that.
4. Now it's just a matter of:
```
# Emulate another CPU architecture on docker containers when necessary
docker run --rm --privileged multiarch/qemu-user-static --reset --credential yes --persistent yes

# Snap it!
docker run -v "$PWD":/build -w /build chiffathefox/ros-snap:melodic-ros-base-bionic-arm64v8 snapcraft
```

# License

The code is licensed under MIT unless stated otherwise in a file.

