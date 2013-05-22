#!/usr/bin/perl

use strict;
use warnings;
use YAML "LoadFile";
use Text::CSV::Slurp;
use DBI;

my $sql_user = shift;
my $sql_pass = shift;

my $drh = DBI->install_driver("mysql");
if($drh->func('createdb', 'GTFS', 'localhost', $sql_user, $sql_pass, 'admin')){
	print "The database GTFS already exists! Continuing process...\n";
}
!system("mysql -u$sql_user -p$sql_pass GTFS < GTFS_schema.sql") or die $!; 

my $dbh = DBI->connect('DBI:mysql:GTFS', $sql_user, $sql_pass) or die $!;

# open 'data' directory and get the provider list
opendir DIR, "data" or die $!;
my @trs_providers = grep { !/^\.\.?/ && -d "data/$_" } readdir DIR;
closedir DIR;
print "List of Providers: \n", join("\n", @trs_providers), "\n\n";

# load YAML
my $yml = LoadFile("GTFS_type.yml");

# for each provider
for my $prov (@trs_providers){
	print "Processing '$prov'... ";
	opendir PROV_DIR, "data/$prov" or die $!;
	my @fns = grep {-f "data/$prov/$_"} readdir PROV_DIR;
	closedir PROV_DIR;
	print join(", ", @fns), "\n";

	open FIN,"data/$prov/agency.txt" or die $!;
	my $attr = <FIN>;
	my $vals = <FIN>;
	chomp $attr;
	chomp $vals;
	$attr =~ s/\r//g;
	$vals =~ s/\r//g;

	my $agency = (split /,/, $vals)[0];
	defined $agency or die $!;

	$dbh->do("START TRANSACTION");
	
#for my $fn (@fns){
		my $fn = "shapes.txt";
		print "$fn...";
		open FIN,"data/$prov/$fn" or die $!;

		my $table = (split /\./, $fn)[0];
		my $field = <FIN>;
		chomp $field;
		$field =~ s/\r//g;
		my @fields = split /,/, $field;

		while(my $line = <FIN>){
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/,$/,null/g;		
			$line =~ s/'/ /g;
			my @vals = split /,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/, $line;

=pod
			my @tmp = ();
			for my $val (@vals){
				if($val =~ /^"/){
					push @tmp, $val;
				}elsif($val =~ /"$/){
					
			}
=cut

			for (my $i=0; $i<=$#fields; $i++){
				if($yml->{$table}->{$fields[$i]} =~ /(string|date)/){
					$vals[$i] = "'$vals[$i]'";
				}
			}
			$line = join ",", @vals;
			my $sql;
			if($table eq "agency" or $table eq "routes"){
				$sql = "INSERT INTO $table ($field) VALUES ($line);";
			}else{
				$field = "agency_id, shape_id, shape_pt, shape_pt_sequence, shape_dist_traveled";
				my $line_value = "$vals[0], POINT($vals[1], $vals[2]), $vals[3], $vals[4]";
				$sql = "INSERT INTO $table ($field) VALUES ('$agency', $line_value);";
			}
			$dbh->do($sql);
		}

		close FIN;
		print "OK\n";
#}
	$dbh->do("COMMIT");
	print "\n";
}

$dbh->disconnect;
