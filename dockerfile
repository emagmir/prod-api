#Base image
FROM python:3-slim

WORKDIR /app

COPY requirements.txt .
COPY connection.py .
COPY main.py .

#install libraries
RUN pip install -r requirements.txt

RUN pip install uvicorn

HEALTHCHECK --interval=60s \
            --timeout=5s \
            CMD curl -f http://127.0.0.1:8000/health || exit 1

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]