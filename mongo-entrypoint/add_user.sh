#!/bin/bash
# Don't stop the script if there is an error (Disable bash error throwing)
set +e

# Try the admin password to see if there is an existing admin db
is_exists=`mongo admin --host localhost -u "${db_root_user}" -p "${db_root_passwd}" --eval "db.system.users.find({user:'${db_root_user}'}).count()"`

# Re-enable error throwing
set -e 

 # If auth fails, then presumably this is a new mongo db
if [[ $is_exists == *"Error: Authentication failed"* ]]; then     
    echo "Authentication failed. We presume that this user does not yet exist...";     
    echo "Creating mongo root user...";     
    mongo admin --eval "db.createUser({user: '${db_root_user}', pwd: '${db_root_passwd}', \
        roles: [{role: 'root', db: 'admin'}]});";     
        echo "Mongo user ${db_root_user} created."; 
else
    echo "There appears to be an existing mongo db in the datastore. Skipping user creation..."; 
fi