# feedback-app/Dockerfile
FROM perl:5.36-slim

# Install system deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install cpanminus and dependencies
RUN cpanm --notest App::cpanminus

WORKDIR /app

# Copy dependency list and install Perl modules
COPY cpanfile .
RUN cpanm --installdeps .

# Copy app code
COPY bin ./bin
COPY lib ./lib
COPY views ./views
COPY conf ./conf

# Initialize empty SQLite DB
RUN touch feedback.db

# Expose port and define entrypoint
EXPOSE 3000
CMD ["plackup", "bin/start_app.pl", "-p", "3000", "-E", "production"]
