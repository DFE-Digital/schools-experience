call gem install bundler -v 1.17.3 
call bundle install 
set CUC_DB_HOST=%DATABASEHOST% 
set CUC_DB_DATABASE=%DATABASENAME% 
set CUC_DB_USERNAME=%DATABASEUSER% 
set CUC_DB_PASSWORD=%PSWD% 
set BROWSER=chrome 
set SKIP_REDIS=true 
set DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL=true
set RAILS_ENV=test 
call cucumber
