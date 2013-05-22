PACKS = Text::CSV::Slurp YAML HTML::TableExtract LWP::Simple JSON List::Compare Text::Trim DBI
SQL_USER = root
SQL_PASS = 12321

all: DB_import.plx GTFS_schema.sql GTFS_type.yml feeds.log
	time -p ./DB_import.plx $(SQL_USER) $(SQL_PASS)

depend: 
	$(foreach PACK, $(PACKS), cpanm $(PACK);)
	

feeds.log: crawler.plx
	time -p ./crawler.plx
	touch feeds.log

clean:
	rm -rf data/*
	rm -rf .tmp
	rm -f feeds.log
	mysql -u$(SQL_USER) -p$(SQL_PASS) -e'DROP DATABASE IF EXISTS GTFS' 
