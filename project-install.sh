#!/bin/bash
zypper install \
    --no-confirm \
    --auto-agree-with-licenses \
    --force-resolution \
    --no-recommends \
    git python3-virtualenv python3-setuptools python3-pip python3-wheel \
    $(cat /tmp/list-distropkg.txt) \
    ${RPM_EXTRA_PACKAGES}

groupadd -g ${GID} ${PROJECT}
useradd -u ${UID} -g ${PROJECT} -M -d \
    /var/lib/${PROJECT} -s /usr/sbin/nologin -c "${PROJECT} user" \
    ${PROJECT}
mkdir -p /etc/${PROJECT} \
         /var/log/${PROJECT} \
         /var/lib/${PROJECT} \
         /var/cache/${PROJECT}
chown ${PROJECT}:${PROJECT} /etc/${PROJECT} \
                            /var/log/${PROJECT} \
                            /var/lib/${PROJECT} \
                            /var/cache/${PROJECT}

git clone ${PROJECT_REPO} /opt/${PROJECT}; cd /opt/${PROJECT}; \
git fetch ${PROJECT_REPO} ${PROJECT_REF}; git checkout FETCH_HEAD; cd -

python3 -m venv /var/lib/openstack
/var/lib/openstack/bin/pip install \
  -c /wheels/upper-constraints.txt --find-links /wheels \
  ${PIP_ARGS} \
  /opt/${PROJECT} ${PIP_EXTRA_PACKAGES} -r /tmp/${PROJECT}/list-pypkg.txt

zypper remove -y --clean-deps git; \
zypper clean -a ; \
rm -rf /tmp/* /root/.cache /etc/machine-id /wheels /opt/${PROJECT} /var/lib/openstack/lib/python*/no-global-site-packages.txt; \
find /usr/ /var/ \( -name "*.pyc" -o -name "__pycache__" \) -delete ; \
find /var/log -type f -exec truncate -s 0 {} \;
