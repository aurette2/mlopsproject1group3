# Use an official Python image as a base
FROM python:3.11-slim

# Use an official Python image as a base
# FROM python:3.12

# Set the working directory in the container
WORKDIR /app
    
# Copy the requirements file into the container
COPY /requirements.txt .

# Install the required Python packages
RUN pip install --upgrade -r requirements.txt

COPY .env /app/

# Copy the entire project directory into the container
COPY /backend/app/ /app/
COPY /frontend/ /app/
COPY /dataops/ /app/
COPY /dataops/.dvc .dvc
COPY .git .git

# Pull the DVC dataset
RUN dvc pull

# Set the environment variable for the data path
ENV DATA_FOR_DRIFT_PATH="/app/data/"

# Expose the ports for FastAPI (8000) and Streamlit (8501)
EXPOSE 8000
EXPOSE 8501

# Set environment variables
ENV STREAMLIT_SERVER_PORT=8501
ENV STREAMLIT_SERVER_ADDRESS=0.0.0.0

# Generate a SECRET_KEY and export it
RUN SECRET_KEY=$(python -c "import secrets; print(secrets.token_hex(32))") && \
    export SECRET_KEY && \
    echo "Generated SECRET_KEY: $SECRET_KEY"

ENV SECRET_KEY=$SECRET_KEY

CMD /bin/bash -c "fastapi run /app/controller.py --host 0.0.0.0 --port 8000 & sleep 5 && streamlit run /app/test.py --server.address 0.0.0.0 --server.port 8501"
