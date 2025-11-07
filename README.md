# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

./bin/bundle3 exec rails server 
./bin/bundle3 install
./bin/bundle3 update
./bin/bundle3 exec rake db:migrate



## Kill rails s 
pkill -f "rails s"

OR 

# Find the process
ps aux | grep rails
# Kill it by PID
kill <PID>
# Or force kill if needed
kill -9 <PID>



* ...
