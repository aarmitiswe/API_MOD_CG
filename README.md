# Bloovo API Documentation

Bloovo API is a Scalable, Cloud based, RESTFul API.

# Technology Stack

    - Ruby v2.1+
    - Ruby on Rails v4.2.6
    - Postgresql v9.4.1
    - NodeJs

# Installation

- [Install Ruby Link](https://www.ruby-lang.org/en/documentation/installation/)

apt for Debian or Ubuntu
```sh
$  sudo apt-get install ruby-full
```
yum for CentOS, Fedora, or RHEL
```sh
$ sudo yum install ruby
```
Homebrew OS X

```sh
$ brew install ruby
```

- [Install Postgresql link](https://wiki.postgresql.org/wiki/Detailed_installation_guides)
- [Install NodeJs link](https://nodejs.org/en/download/package-manager/)

- Install related gems
```sh
$ cd bloovo/api/local/dir
$ bundle install
```
# Create Local Database
- [Start Postgresql Server Link](https://www.postgresql.org/docs/9.1/static/server-start.html)
- Create database config file
```sh
$ cp config/database.yml.example config/database.yml
```
- Edit config/database.yml based on your local machine configuration
```ruby
default: &default
  adapter: postgresql
  encoding: unicode
  username: postgres # change username
  password: root # change passoword
  database: bloovo_dev
  pool: 5
  timeout: 5000
```
- Create and Migrate development database
```sh
$ RAILS_ENV=development rake db:create
$ RAILS_ENV=development rake db:migrate
```

# Start Local Rails Server
```sh
$ rails s -b 127.0.0.1 -p 3000
```
You can change 127.0.0.1 to your IP address if you want to access your server from different machine.

# Staging Deployment
- Log to staging EC2 instace using your key
```sh
$ ssh -i ./MainInstanceKey.pem ec2-user@ec2-54-167-141-93.compute-1.amazonaws.com
```
- Pull the lastes development branch latest changes
```sh
$ cd /var/www/bloovo/bloovo_api
$ git pull origin development
```
- Restart Nginx server
```sh
$ sudo service nginx restart
```
- Restart Delayed::Job
```sh
$ RAILS_ENV=production bin/delayed_job stop
$ RAILS_ENV=production bin/delayed_job start
```
OR
```sh
$ RAILS_ENV=production bin/delayed_job restart
```
# Install To Production Server
- Install ffmpeg on server

Ref: https://forums.aws.amazon.com/thread.jspa?messageID=524523 +
http://ffmpeg.gusari.org/static/64bit/

Ref 2: https://linuxize.com/post/how-to-install-ffmpeg-on-ubuntu-18-04/
```sh
sudo su -
cd /usr/local/bin
mkdir ffmpeg_dir
cd ffmpeg_dir
wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-64bit-static.tar.xz
cd ffmpeg_dir
tar xf ffmpeg-git-64bit-static.tar.xz
cd ../
cp -r ffmpeg_dir/ffmpeg ./
cp -r ffmpeg_dir/ffprobe ./
cp -r ffmpeg_dir/ffserver ./
cp -r ffmpeg_dir/ffmpeg-10bit ./
cp -r ffmpeg_dir/qt-faststart ./
```

- Install ImageMagick

Ref: http://www.imagemagick.org/script/install-source.php
```sh
wget https://www.imagemagick.org/download/ImageMagick.tar.gz
tar xvzf ImageMagick.tar.gz
cd ImageMagick-7.0.3
./configure
make
sudo make install
```
Or `sudo apt-get install imagemagick`
