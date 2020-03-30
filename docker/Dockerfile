FROM python:alpine                                                                                                                                     
COPY uwsgi/ /opt
WORKDIR /opt/
RUN apk add --no-cache --virtual .build-deps gcc libc-dev libffi-dev \
    && pip install -r /opt/requirements.txt \
    && chmod +x /opt/flaskapp.py \
    && rm -rf /opt/requirements.txt \
    && chown -R 100:101 /opt/
#CMD ["gunicorn", "--workers", "2", "-u", "100", "--bind", "unix:////opt/socket/gunicorn.sock", "wsgi:application"]
CMD ["uwsgi", "--ini", "/opt/uwsgi.ini"]
