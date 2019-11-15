docker build -t siacentral/troubleshoot .
docker tag siacentral/troubleshoot:latest 921261815063.dkr.ecr.us-east-2.amazonaws.com/siacentral/troubleshoot:latest
docker push 921261815063.dkr.ecr.us-east-2.amazonaws.com/siacentral/troubleshoot:latest