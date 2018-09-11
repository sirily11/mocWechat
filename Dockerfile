FROM python:3
WORKDIR /messager
COPY . .
RUN pip3 install -r requirements.txt
CMD [ "python3", "run.py" ]
