DROP TABLE IF EXISTS agency;
CREATE TABLE agency (
	agency_id char(255) NOT NULL,
	agency_name char(255) NOT NULL,
	agency_url char(255) NOT NULL,
	agency_timezone char(255) NOT NULL,
	agency_lang char(255) DEFAULT NULL,
	agency_phone char(255) DEFAULT NULL,
	agency_fare_url char(255) DEFAULT NULL,
	PRIMARY KEY (agency_id)
);
LOCK TABLES agency WRITE;
UNLOCK TABLES;


DROP TABLE IF EXISTS calendar;
CREATE TABLE calendar (
	agency_id char(255) NOT NULL,
	service_id char(255) NOT NULL,
	monday int(11) NOT NULL,
	tuesday int(11) NOT NULL,
	wednesday int(11) NOT NULL,
	thursday int(11) NOT NULL,
	friday int(11) NOT NULL,
	saturday int(11) NOT NULL,
	sunday int(11) NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL,
	PRIMARY KEY (agency_id,service_id)
);
LOCK TABLES calendar WRITE;
UNLOCK TABLES;


DROP TABLE IF EXISTS routes;
CREATE TABLE routes (
	agency_id char(255) NOT NULL,
	route_id char(255) NOT NULL,
	route_short_name char(255) NOT NULL,
	route_long_name char(255) NOT NULL,
	route_desc char(255) DEFAULT NULL,
	route_type int(11) NOT NULL,
	route_url char(255) DEFAULT NULL,
	route_color char(255) DEFAULT NULL,
	route_text_color char(255) DEFAULT NULL,
	PRIMARY KEY (agency_id,route_id)
);
LOCK TABLES routes WRITE;
UNLOCK TABLES;


DROP TABLE IF EXISTS shapes;
CREATE TABLE shapes (
	agency_id char(255) NOT NULL,
	shape_id char(255) NOT NULL,
	shape_pt POINT NOT NULL,
	SPATIAL INDEX(shape_pt),
	shape_pt_sequence int(11) NOT NULL,
	shape_dist_traveled double DEFAULT NULL,
	PRIMARY KEY (agency_id,shape_id,shape_pt_sequence)
) ENGINE=MyISAM;
LOCK TABLES shapes WRITE;
UNLOCK TABLES;


DROP TABLE IF EXISTS stop_times;
CREATE TABLE stop_times (
	agency_id char(255) NOT NULL,
	trip_id char(255) NOT NULL,
	arrival_time char(255) NOT NULL,
	departure_time char(255) NOT NULL,
	stop_id char(255) NOT NULL,
	stop_sequence int(11) NOT NULL,
	stop_headsign char(255) DEFAULT NULL,
	pickup_type int(11) DEFAULT NULL,
	drop_off_type int(11) DEFAULT NULL,
	shape_dist_traveled double DEFAULT NULL,
	PRIMARY KEY (agency_id,trip_id,stop_id)
);
LOCK TABLES stop_times WRITE;
UNLOCK TABLES;


DROP TABLE IF EXISTS stops;
CREATE TABLE stops (
	agency_id char(255) NOT NULL,
	stop_id char(255) NOT NULL,
	stop_code char(255) DEFAULT NULL,
	stop_name char(255) NOT NULL,
	stop_desc char(255) DEFAULT NULL,
	stop_lat double NOT NULL,
	stop_lon double NOT NULL,
	zone_id char(255) DEFAULT NULL,
	stop_url char(255) DEFAULT NULL,
	location_type int(11) DEFAULT NULL,
	parent_station char(255) DEFAULT NULL,
	stop_timezone char(255) DEFAULT NULL,
	wheelchair_boarding int(11) DEFAULT NULL,
	PRIMARY KEY (agency_id,stop_id)
);
LOCK TABLES stops WRITE;
UNLOCK TABLES;


DROP TABLE IF EXISTS transfers;
CREATE TABLE transfers (
	agency_id char(255) NOT NULL,
	from_stop_id char(255) NOT NULL,
	to_stop_id char(255) NOT NULL,
	transfer_type int(11) NOT NULL,
	min_transfer_time int(11) DEFAULT NULL,
	PRIMARY KEY (agency_id,from_stop_id,to_stop_id)
);
LOCK TABLES transfers WRITE;
UNLOCK TABLES;


DROP TABLE IF EXISTS trips;
CREATE TABLE trips (
	agency_id char(255) NOT NULL,
	route_id char(255) NOT NULL,
	service_id char(255) NOT NULL,
	trip_id char(255) NOT NULL,
	trip_headsign char(255) DEFAULT NULL,
	trip_short_name char(255) DEFAULT NULL,
	direction_id int(11) DEFAULT NULL,
	block_id char(255) DEFAULT NULL,
	shape_id char(255) DEFAULT NULL,
	wheelchair_accessible int(11) DEFAULT NULL,
	PRIMARY KEY (agency_id,trip_id)
);
LOCK TABLES trips WRITE;
UNLOCK TABLES;

