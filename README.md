# The beginning...

1. Start your container.

      - docker run -it -d --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name phantosd --hostname phantosd -p "80:80" -p "443:443" centos/systemd

2. Enter your container and run the commands. (docker exec -it phantosd /bin/bash)


      - yum update -y
      - rpm -Uvh https://repo.phantom.us/phantom/4.5/base/7/x86_64/phantom_repo-4.5.15922-1.x86_64.rpm
      - /opt/phantom/bin/phantom_setup.sh install --no-prompt
      
 3. ???
 
 4. PROFIT!
 
# Build the container locally
```
git clone https://github.com/benzies/phantom-docker.git && \
docker build -t phantom . && \
docker run -it -d --privileged --name phantosd --hostname phantosd -p "443:443" phantom
```


 
 Note: You NEED a phantom login, so you can download and install the software. This is a pretty crappy way to make it, it's unoffical, and I will eventually improve it. You can start and stop the container as normal and everything fires back up just fine.  


"The begining..." is still the most effective method to getting Phantom in a container.  The latest method is still not recommended, it builds but I can't seem to authenticate to phatom... and now I'm tired. Eventually I would like to see the dependent services seperated into seperate containers. But hey... it took a year to get here, maybe next year?

#TODO
Authentication to Phantom seems to fail...