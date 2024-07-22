# Use the official Python image from the Docker Hub
FROM python:3.9-alpine3.13

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create a directory for the application code
WORKDIR /app

# Copy the requirements file to the /app directory
COPY requirements.txt /app/

# Copy the entire project to the /app directory
COPY sample_django_app/ /app/

# Expose the port the app runs on
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache redis && \
    apk add --update --no-cache netcat-openbsd && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
    /py/bin/pip install -r requirements.txt && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol

# Ensure SQLite database file exists and set correct permissions
RUN touch /app/db.sqlite3 && \
    chown django-user:django-user /app/db.sqlite3 && \
    chmod 664 /app/db.sqlite3

ENV PATH="/py/bin:$PATH"

USER django-user

# Command to run the application
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
