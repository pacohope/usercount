Diaspora User and Post Count Bot
=======================

This script generates user and post graphs in a graphic format. I use it to generate the graph that appears at the bottom of the main page at [A Grumpy World](https://a.grumpy.world/).

The script reads your `database.yml` file and looks for the `production` database name. It uses whatever `postgresql` configuration parameters it finds there. It does not (yet) work with MySQL databases.

This is based off the fine work by [Josef](https://mastodon.social/@jk) on the [User Count Bot](https://mastodon.social/@usercount) that runs on [Mastodon.social](https://mastodon.social/).

### Dependencies

-   **Python 3**
-   [gnuplot](http://www.gnuplot.info/) version 5 or greater
-   `PyYAML` YAML parser
-   [psycopg](http://initd.org/psycopg/) python to postgresql library

### Installation

1. Install python3 and pip3 if you don't already have them.

2. Use pip to install all the requirements. (If you're clever enough to use a virtual python environment, ignore this `sudo` here and just do it in your virtual environment.)
```shell
sudo pip3 install -r requirements.txt
```
3. I recommend running it for the first time manually. E.g., `bash usercount-cron.sh`. Check the output in the `cron.log` file.

4. To get it on the main page of my pod, I hand-edited `diaspora/app/views/home/podmin.haml` (You're not supposed to do it this way.). I added these lines at the bottom of the file. Watch the indentation in HAML. It matters.
```haml
  .row
    .col-md-12
      %h4.text-center
        This pod's statistics
      %p.text-center
        %img{:src => "/assets/graph.png", :width => "800"}
```

### Usage:

1. Install all the required modules on your system. For example `sudo apt-get install gnuplot5-nox`

2. Check out this repository. I checked it out into `/home/diaspora`. Like this:
```shell
cd /home/diaspora
git clone git@github.com:pacohope/usercount.git
```

3. Edit `usercount-cron.sh` to update the variables. They should point to the right locations for your files, your config file, and where you want the graph to go.

4. Schedule `usercount-cron.sh` to run once per hour. I run it a few minutes after the hour with an entry in my crontab like this:
```
4 * * * * /home/diaspora/usercount/usercount-cron.sh
```

5. If you're ever wondering how it's doing, take a look at the `cron.log` file.

### WARNINGS

You won't get a graph.png graph file the first time you run it. It can't graph a single point!

You will eventually get a graph after it has run a few times. So just let it run, once an hour, for a few days and then see what your graph looks like.

The `generate.gnuplot` is ripe for fixing. The python script assumes it is in the current working directory when it executes. Because it executes a really naïve `call( gnuplot )` in the code. This isn't very clever and should get refactored.