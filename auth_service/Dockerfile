FROM python:3.5
ADD . /code
WORKDIR /code
ENV MONGODB mongodb://mongodb:27017
RUN pip install -r requirements.txt
CMD [ "python", "api.py" ]
