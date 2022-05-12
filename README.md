# docker-compose for mongo db

## Quickstart
1. Create a directory for the persistent database datastore 
```
mkdir -p /opt/local/var/lib/mongodb
```
2. Get a local user to own the /opt/local/var/lib/mongodb directory and files. In my case, I used a local user called `mongodb` and found the uid and gid for that user.

3. Create a file called .env and edit the variables (copy env.sample)

4. `docker-compose up`

## Summary
I wanted to created a docker-compose file that would:
1. Create a mongo container
2. Use a host machine filesystem store for data persistence
3. Be able to redeploy the container without the need to delete the persistent database

## Challenges
- Using the built in init script by defining the variables `MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD` works fine if there is no existing admin database. However, if one were to attempt to redeploy a mongo container by running `docker-compose down` and then `docker-compose up`, the init script unconditionally attempts to recreate the user `MONGO_INITDB_ROOT_USERNAME`. This fails because the user already exists in the persistent database and the container fails to start.

- I wanted to the persistent database files to only be accessible by the host user `mongodb`

## Solutions
- I opted to not use the builtin init script by not defining `MONGO_INITDB_ROOT_USERNAME` and instead, I wrote the bash file `add_user.sh` 

    - ### New container and new database 
    The init script first attempts to use the admin credentials to do an admin read operation. If this fails with an authentication failure, the assumption is that the user does not exist, and that this is a new database system and container. The script will then attempt to create the admin user using the values in .env exposed via the docker-file environment variables `db_root_user` and `db_root_passwd`. 
    
    - ### New container but existing database
    Like above, The init script first attempts to use the admin credentials to do an admin read operation. If there is an existing db system that was created from a previous container, this read should succeed. If that is the case, we will skip attempting to add the admin user, as it must already exist.
    
    - ### Access the volumes as the host system user mongodb
    In the .env file, I make the UID and the GID of the host system user 'mongodb' avaialbe to docker-compose. I found the UID and GID of the user mongodb (UID:114 and GID:119) on the host system by using bash grep.
    ```
    $ id -u mongodb
    114
    
    $ id -g mongodb
    119
    ```
    In the docker-compose file I added the option:
    `user: "${UID}:${GID}"`