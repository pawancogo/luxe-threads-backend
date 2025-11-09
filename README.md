# Luxe Threads Backend

Rails 7.1 application providing the primary API, admin UI, and authentication layer for Luxe Threads.

## Requirements

- **Ruby** - Version specified in `.ruby-version` (currently: 3.3.0)
- **Bundler** - Version specified in `.bundler-version` (currently: 2.5.3)
- SQLite 3 (development)
- Optional services: Redis (`redis-server`) and Elasticsearch (`elasticsearch`) for caching/search features.

**Note:** Versions are managed via `.ruby-version` and `.bundler-version` files (similar to `.nvmrc` for Node.js). The setup script automatically reads these files.

## Initial Setup

From the backend directory:

```bash
cd luxe-threads-backend
./setup_backend.sh
```

**📖 For detailed setup instructions, see [BACKEND_PROJECT_SETUP.md](./BACKEND_PROJECT_SETUP.md)**

Or manually:

```bash
cd luxe-threads-backend
bundle _2.5.3_ install
bundle exec rails db:prepare
```

Environment variables go in `.env` (not committed). Common keys:

- `REDIS_URL=redis://localhost:6379/0`
- `ELASTICSEARCH_URL=http://localhost:9200`

## Day-to-Day Commands

### Run the app

```bash
bin/dev             # boots Rails server with js/css bundling
```

### Database maintenance

```bash
bin/rails db:migrate         # run migrations
bin/rails db:rollback STEP=1 # roll back
bin/rails db:seed            # seed data
bin/rails db:prepare         # create + migrate + seed if needed
```

### Tests & linting

```bash
bundle exec rspec
bundle exec rubocop          # via rubocop-rails-omakase
bundle exec brakeman         # security scan
```

### Kill a running server

```bash
pkill -f "bin/rails s"       # quick kill

# or find & kill manually
ps aux | egrep "[p]uma|[r]ails"
kill <PID>
kill -9 <PID>   

# onliner kill command 
ps aux | egrep "[p]uma|[r]ails" | awk '{print $2}' | xargs kill -9
             # force if necessary
```

### Background services

- Redis: `redis-server` (local cache and job queue optional)
- Elasticsearch: `elasticsearch` (optional search support)

## Troubleshooting

- Reset the database: `bin/rails db:drop db:setup`
- Clear logs/temp files: `bin/rails log:clear tmp:clear`
- Restart dev server: `bin/rails restart`

## Logs
```bash 
tail -f log/development.log # development
tail -f log/production.log # productions
```



