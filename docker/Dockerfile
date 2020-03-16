FROM python:alpine

COPY flask-app.py  /opt/flask-app.py
WORKDIR /opt/
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
RUN chmod +x /opt/flask-app.py
RUN rm -rf /tmp/requirements.txt

CMD ["/opt/flask-app.py"]
