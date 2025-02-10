# Use an official lightweight Python image
FROM python:3.12

# Set the working directory inside the container
WORKDIR /app

# Copy project files into the container
COPY . .

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    libgconf-2-4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxtst6 \
    xdg-utils \
    fonts-liberation \
    libappindicator3-1 \
    lsb-release \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb || apt-get -fy install

# Install ChromeDriver
RUN wget -q https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the Flask API port
EXPOSE 8080

# Run the server using Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:8080", "server:app"]
