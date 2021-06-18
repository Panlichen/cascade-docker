#!/bin/bash

set -eu
WORKPATH="${HOME}/workspace/scripts"
cd ${WORKPATH}

# This is private, git clone it in Dockerfile is kind of annoying
# git clone https://github.com/Derecho-Project/scripts.git
python -m pip install -r requirements.txt
# python regtests/regtests.py -h

mkdir /run/sshd

cat > /root/.ssh/id_rsa << EOF
-----BEGIN OPENSSH PRIVATE KEY-----
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
cXIBAg==
-----END OPENSSH PRIVATE KEY-----
EOF

chmod 0600 /root/.ssh/id_rsa

# append
cat >> /root/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNqAzBza3I7EtuAVc/p5p31f2TaTrH95mlIKgsr2/A9sdmrezEFoC+UvRzryr/JgYNMKKaJxXc0nn92uKMSjlONiARANmKlfw088hvDAAe8uYFboZ3mwb/VWYN2YuhIPXjgxsS4vNhZu7HBJzSBwvcX2w0M2J2maIJGaIo4JUUb0Uy2zXQxcX7gxXtAy4vSY8ka0mkEoLRr/pup3ofQ+pR42fkDytDiJsiW2hXG7kVEKQylqBr3784Azelgpyy9/mFepElJC87LFpZzqokQl2CuUqwTyaT6CRhml/k+Pmfe/HcsVnhQPWWDPkyQA2krGMaw7e35nERqXUehOjhe1eP0grR3OLDmZxnEDy3upOdOWTn+mkr2uAFkAZ9jN3a+MbnGrwyNfbKoPcnidZ7zyKZqFhkTe5I8mJAEJcaBKYWQio4tpJLNgqxpxFX0zqBxK8FHsBFdxlh8Po6J/dRh1JCSrg9CuyYkFiZJmohCR30KfaiBbHbL1dLjsRvtcqJGBM= root@cascade-gpu-deploy-69df7c779b-qsfqr
EOF