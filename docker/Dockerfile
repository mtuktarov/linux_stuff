FROM python:alpine                                                                                                                                     
  
COPY flaskapp.py  /opt/flaskapp.py
COPY wsgi.py /opt/wsgi.py
WORKDIR /opt/
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
RUN chmod +x /opt/flaskapp.py
RUN rm -rf /tmp/requirements.txt

CMD ["gunicorn", "--workers", "2", "--bind", "unix:socket/flaskapp.sock", "wsgi:app"]
#CMD ["/opt/flaskapp.py"]
