FROM ubuntu:latest
RUN apt-get update -y && apt-get install -y python-pip
COPY . /remotedns-server
WORKDIR /remotedns-server
RUN pip install -r requirements.txt
CMD ["python", "server.py"]
