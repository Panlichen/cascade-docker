sudo docker image rm poanpan/cascade:test-derecho --force
sudo docker build -f Dockerfile.upgrade-derecho -t poanpan/cascade:test-derecho .
sudo docker push poanpan/cascade:test-derecho