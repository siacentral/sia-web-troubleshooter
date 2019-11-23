docker build -t siacentral/web/troubleshooter .
docker tag siacentral/web/troubleshooter:latest 921261815063.dkr.ecr.us-east-2.amazonaws.com/siacentral/web/troubleshooter:latest
docker push 921261815063.dkr.ecr.us-east-2.amazonaws.com/siacentral/web/troubleshooter:latest