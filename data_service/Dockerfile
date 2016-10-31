FROM python:3.5
ADD . /code
WORKDIR /code
ENV MONGODB mongodb://mongodb:27017
ENV FLASK_APP api.py
RUN pip install -r requirements.txt
CMD ["flask","run","--host","0.0.0.0","--port","5001"]
