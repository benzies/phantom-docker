FROM centos/systemd:latest
MAINTAINER Ben Menzies (benzies@gmail.com)

ADD phantom_repo-4.5.15922-1.x86_64.rpm  /var/tmp
ADD phantom_local-4.5.15922-1.centos7.x86_64.rpm /var/tmp
ADD phantom-python-devel-2.7.14-2.x86_64.rpm /var/tmp
ADD phantom-python-2.7.14-2.x86_64.rpm /var/tmp
ADD phantom_dependencies-4.5.15922-1.x86_64.rpm /var/tmp
ADD phantom_cluster-4.5.15922-1.x86_64.rpm /var/tmp
ADD phantom_cacerts-4.5.15922-1.x86_64.rpm /var/tmp
ADD phantom_pylib-4.5.15922-1.x86_64.rpm /var/tmp
ADD phantom-4.5.15922-1.x86_64.rpm /var/tmp


RUN rpm -Uvh /var/tmp/phantom_repo-4.5.15922-1.x86_64.rpm && \
    yum update -y && \
    yum deplist git | awk '/provider:/ {print $2}' | sort -u | xargs yum -y install && \
    yum deplist postgresql94-server | awk '/provider:/ {print $2}' | sort -u | xargs yum -y install && \
    yum install -y /var/tmp/phantom-python-2.7.14-2.x86_64.rpm && \
    yum install -y /var/tmp/phantom-python-devel-2.7.14-2.x86_64.rpm && \
    yum install -y /var/tmp/phantom_dependencies-4.5.15922-1.x86_64.rpm && \
    yum install -y /var/tmp/phantom_pylib-4.5.15922-1.x86_64.rpm && \
    yum install -y /var/tmp/phantom_cacerts-4.5.15922-1.x86_64.rpm && \
    yum install -y /var/tmp/phantom_cluster-4.5.15922-1.x86_64.rpm && \
    yum install -y /var/tmp/phantom-4.5.15922-1.x86_64.rpm && \
    yum install -y /var/tmp/phantom_local-4.5.15922-1.centos7.x86_64.rpm

ENTRYPOINT ["/usr/sbin/init"]
CMD ["/bin/bash", "/opt/phantom/bin/start_phantom.sh"]

EXPOSE 443/TCP
