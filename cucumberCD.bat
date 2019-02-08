call gem install bundler -v 1.17.3 
call bundle install 
call set CUC_DB_HOST=%DATABASEHOST% 
call set CUC_DB_DATABASE=%DATABASENAME% 
call set CUC_DB_USERNAME=%DATABASEUSER% 
call set CUC_DB_PASSWORD=%PSWD% 
call set BROWSER=chrome 
call set SKIP_REDIS=true 
call set DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL=true
call set RAILS_ENV=test 
call cucumber
