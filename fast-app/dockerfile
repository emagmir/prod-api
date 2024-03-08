#Base image
FROM python:latest

WORKDIR /app

COPY requirements.txt .
COPY connection.py .
COPY main.py .

#install libraries
RUN pip install -r requirements.txt

RUN pip install uvicorn

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]