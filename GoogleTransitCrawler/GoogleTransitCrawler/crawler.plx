#!/usr/bin/perl

use strict;
use warnings;

use HTML::TableExtract;
use LWP::Simple;
use YAML "LoadFile";
use List::Compare;
use Text::CSV::Slurp;
use Text::Trim;
use Getopt::Std;


## Get the options
my %opts;
getopts('rvc', \%opts);

## Refresh option
if($opts{r}){

## Check the public feed list
	my $GTFS_feed_url = "http://code.google.com/p/googletransitdatafeed/wiki/PublicFeeds";
	my $te = HTML::TableExtract->new;
	my $html = get($GTFS_feed_url);
	print "  [O] Public feed list document downloaded successfully\n";


## Parse the feed list
	$te->parse($html);
	my $table = $te->table(1,0); # depth and count
	my @tables = $table->rows;
	shift @tables;
	print "  [*] Public feed table parsing test...\n";
	my $row_cnt = 0;
	foreach my $row (@tables){
		print ++$row_cnt, ": ", trim($$row[0]), "\$\n";
	}
	my $num_feeds = @tables;
	print "  [O] Total $num_feeds sources\n\n";


	
	print "  [*] Refreshing the downloaded folders\n";

	my $cnt = 0;
	my $skip = 0;
	my $path;
	foreach my $row (@tables){
		$cnt++;
		$path = "data/p$cnt";

		my $url = trim($$row[2]);
		print "  [*] <$$row[0]($cnt/$num_feeds)>: Checking URL $url\n";
		my ($type) = head($url);
		unless(defined $type or $type =~ /application/){
			print "  [!] Skipping.. It is not a direct zip URL but $type\n\n\n";
			$skip++;
			next;
		}
		!system("mkdir -p $path") or die $!;
		getstore($$row[2], "$path/tmp.zip");

		print "  [*] Unzipping...";
		!system("unzip $path/tmp.zip -d $path") or die $!;
		!system("rm $path/tmp.zip") or die $!;
		print "  [O] Successfully Unzipped\n\n\n";
	}
}

## Validation option
if($opts{v}){
	print "  [*] Validating data with feedvalidator.py\n";

	opendir DIR, "data" or die $!;
	my @trs_providers = grep { !/^\.\.?/ && -d "data/$_" } readdir DIR;
	@trs_providers = grep { !/ERROR_/ } @trs_providers;
	closedir DIR;
	foreach my $prov (@trs_providers){
		print "$prov: \n";
		!system("feedvalidator.py data/$prov -n --output=data/$prov.html") or print "ERROR\n";
		print "\n--------------------------------------\n";
	}
}

## Cleaning option
if($opts{c}){
	print "  [*] Cleaning irrelevant files\n";

	my $yml = LoadFile("GTFS_type.yml");
	my @in_schema = keys %$yml;

	opendir DIR, "data" or die $!;
	my @trs_providers = grep { !/^\.\.?/ && -d "data/$_" } readdir DIR;
	closedir DIR;


	foreach my $prov (@trs_providers){
		print "$prov: \n";
			
		my $path = "data/$prov";
		opendir DIR, $path or die $!;
		my @files = grep {!/^\.\.?/ && -f "$path/$_"} readdir DIR;
		closedir DIR;

		@files = map {(split(/\./, $_))[0]} @files;
		print " files: ", join(",", sort(@files)), "\n";
		print "scheme: ", join(",", sort(@in_schema)), "\n";

		my $lc = List::Compare->new(\@files, \@in_schema);
		unless($lc->is_RsubsetL){
			print "  [!] Skipping.. Folder structure error or not enough files\n\n\n";
#$skip++;
			!system("mv $path data/ERROR_$prov") or die $!;
			next;
		}
		print "  [*] Deleting file...\n";
		foreach my $file ($lc->get_unique){
			print "$file.txt, ";
			!system("rm $path/$file.txt") or die $!;
		}print "\n  [O] Successfully Deleted";

		print "  [*] Retrieving agency name... ";
		my $info = Text::CSV::Slurp->load(file => "$path/agency.txt");
		my $agency = $info->[0]->{agency_name};
		$agency = trim($agency);
		print "\n  DEBUG: \^$agency\n\$";
		$agency =~ s/[^A-Za-z0-9\-\.]/_/g;
		print $agency, "\n";

		print "\n\n\n";
	}
}

#print "From $num_feeds sources, Skipped $skip zip files\n";
