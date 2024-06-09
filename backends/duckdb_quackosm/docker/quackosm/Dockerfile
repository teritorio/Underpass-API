FROM python:3.12-slim

RUN apt update -y && apt install -y \
    build-essential

RUN pip install quackosm[cli]

CMD /bin/bash
