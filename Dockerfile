FROM ubuntu:20.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y cron docker.io && \
    apt-get install curl -y && \
    apt-get install jq -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
&& chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
RUN /usr/local/bin/docker-compose --version    

# Copy the update agent script
COPY update-agent.sh /usr/local/bin/update-agent.sh

# Give execution rights on the cron job
RUN chmod +x /usr/local/bin/update-agent.sh

# Create the cron job
RUN echo "*/1 * * * * root /usr/local/bin/update-agent.sh >> /var/log/update-agent.log 2>&1" > /etc/cron.d/update-agent

# Apply cron job
RUN crontab /etc/cron.d/update-agent

# Create the log file to be able to run tail
RUN touch /var/log/update-agent.log

# Run the command on container startup
CMD cron && tail -f /var/log/update-agent.log
