# BACKUP Documentation

This documentation to describe how to take backup. 

How you can take the backup from server A to Server B. 

# Backup DB:

- In Server B: Go to API folder, and change line `database: data_a_1` to `database: data_b_1`. 
 You can just use vi command as the following: 
 
 ```
 vi config/database.yml
 ```
 
 then click `i` to insert, then go to line `database: data_a_1` and change it to `database: data_b_1`.
 then click `ESC`, then write `:wq!` to save your changes. 

- Create the empty database in the server by running the following command: 

```
RAILS_ENV=production rake db:create
```

- Copy last backup SQL file from server A to server B. 

For example: in backup folder in server A has sql files, last file is `30-05-2021.sql` file, so let's copy it to server B in API folder.

- In case you don't have sql file in server A, you can create one by the following command: 

```
pg_dump --no-acl --no-owner -h localhost -U USERNAME -d DATABASE > ./localdb.sql
```

Replace USERNAME & DATABASE with real values from config/database.yml file inside API. Just run `cat config/database.yml` inside API folder. 
And the command will ask for password, copy it from the file. 

- After you copy the file inside server B, then you can load the old data to the new data `data_b_1` as the following: 

```
psql -h localhost -d data_b_1 -U USERNAME -p 5432 -W < ./30-05-2021.sql.sql
```

You need to run this command in the same folder you copied the SQL file, also replace the USERNAME with real value from `config/database.yml`. 
You can open the file using cat command: `cat config/database.yml`, also the data password will be required after running this command. 

- After the new database is loaded in server B, then you can run deploy command in API in server B. 

```
bash -e prod.deploy.sh
```

- **NOTE:** SQL files are saved on the same server, which is something risky. 
the best practice, SQL files should be saved in another server. 
I recommend to the admin, he should take copy last file created in backup folder from production server, and put it in another server as a backup. 


# Backup Files:

- All files is saved in `public/system` folder inside API folder. 

- Rename folder system inside server B to be `system_old_1`, then copy system folder from server A to server B. 

- **NOTE:** system folder is very important folder, and no backup for this folder. 
I recommend to build Another server with any Operating System has good disk space. 
And each day, copy system folder from production server to this server. to make files in safe place as a backup. 

the admin can keep only last 10 versions, for example: `system_01, system_02 ... system_10`
when copy `system_11`, he can delete system_1 from the backup server to save space. 

