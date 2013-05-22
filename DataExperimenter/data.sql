CREATE DATABASE IF NOT EXISTS dnd_ml_bts;
use dnd_ml_bts;
CREATE TABLE data
(
	sbj_name CHAR(60) NOT NULL,
	dat_name CHAR(60) NOT NULL,
	len INTEGER NOT NULL,
	time_start DOUBLE NOT NULL,
	gps_mean_lat DOUBLE NOT NULL,
	gps_mean_lng DOUBLE NOT NULL,
	gps_drop_rate DOUBLE NOT NULL,
	acc_mean_acc DOUBLE NOT NULL,
	mag_mean_mag DOUBLE NOT NULL,
	bat_mean_bat DOUBLE NOT NULL, 
	trs_maj_trs INTEGER NOT NULL,
	acc_reliable Boolean,
	gps_reliable Boolean,
	PRIMARY KEY (sbj_name, dat_name)
);
