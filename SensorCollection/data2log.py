#!/usr/bin/env python
import json
import csv

from utils.MySQLWrapper import *
from config import *

keys = ["time", "gps_lng", "gps_lat", "gps_accur", "acc_x", "acc_y", "acc_z",
	"mag_x", "mag_y", "mag_z", "mag_accur", "bat"]

mysqldb = MySQLWrapper(host=COLL_DB_HOST, user=COLL_DB_USER, passwd=COLL_DB_PWD, db=COLL_DB_NAME)
mysqldb.connect()

sql = "SELECT sbj_name, data_name FROM data WHERE bat_mean_bat>0 AND len>3000 AND gps_mean_lng<0"
cur = mysqldb.execute(sql)

row = cur.fetchone()
sbj_name = str(row[0])
dat_name = str(row[1])
path = 'data/'+sbj_name+'/'+dat_name

TRAIN_LOG = open("../Log/Train.txt", 'w')
result_str = '''{desc":"RESULT", "mid":-1, "uid":-1, "result":{"routes":[{"legs":[{"duration":{"value":100}}]}]}}'''

with open(path, 'r') as data_file:
	data = csv.reader(data_file, delimiter=',')
	linecnt = 0
	chunk = []
	for row in data:
		linecnt += 1
		chunk.append(row)
		if linecnt == FRAME_SIZE:
			json_data = {}
			json_data["desc"] = "SENSOR"
			json_data["mid"] = -1
			json_data["uid"] = -1
			json_data["sensor"] = [dict(zip(keys, frm[0:-1])) in range(12) for frm in chunk]
			json_str = json.dumps(json_data) 
			TRAIN_LOG.write(json_str)

			json_str = {"desc": "GMAP"}
			TRAIN_LOG.write(json_str)

			json_str = result_str
			TRAIN_LOG.write(json_str)

			json_str = {"desc": "ETA"}
			TRAIN_LOG.write(json_str)
			
			linecnt = 0
			chunk = []




			
		

