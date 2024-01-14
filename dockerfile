FROM python:3-slim

WORKDIR /app

COPY requirements.txt .
COPY connection.py .
COPY main.py .

# Install wget
RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem

#install libraries
RUN pip install -r requirements.txt

RUN pip install uvicorn

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]