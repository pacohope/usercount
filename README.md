Diaspora User and Post Count Bot
=======================

A script to generate user and post graphs. Produces a graphic. I stick this on the main page at [A Grumpy World](https://a.grumpy.world/).

### Dependencies

-   **Python 3**
-   [gnuplot](http://www.gnuplot.info/) version 5 or greater
-   `argparse`
-   `PyYAML`
-   [psycopg](http://initd.org/psycopg/)
-   Most of it is listed in `requirements.txt`

### Installation
```shell
sudo pip3 install -r requirements.txt
```

### Usage:

1. Install all the required modules on your system. For example `sudo apt-get install gnuplot-nox`

2. Check out this repository. `git@github.com:pacohope/usercount.git`

3. Use your favourite scheduling method to set `./diasporacount.py` to run regularly. You will probably want to script it a bit like this:
```shell

cd /home/diaspora
/usr/local/bin/python3 /home/diaspora/usercount/diaspora.py \
  --database /home/diaspora/diaspora/config/database.yml \
  --csv /home/diaspora/diasporastats.csv
mv /home/diaspora/graph.png /home/diaspora/diaspora/public/assets
```

**Note**: The script will fail to output a graph until you've collected enough data points to make a decent graph!
