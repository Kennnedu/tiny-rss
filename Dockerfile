FROM ruby:3.0.4

RUN apt-get update -qq && apt-get install -y sqlite3 && apt-get install -y postgresql-client && apt-get install -y cron
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt install nodejs -y
RUN npm install -g yarn

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

COPY . .

# Add a script to be executed every time the container starts.

RUN chmod +x entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
EXPOSE 3333

# Configure the main process to run when running the image
#CMD ["bundle", "exec", "rackup", "-p", "3333", "-s", "puma"]

