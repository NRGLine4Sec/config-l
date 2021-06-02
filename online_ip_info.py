#!/usr/bin/python3

import os
import urllib.request, urllib.error, urllib.parse
import json


os.system("reset")

while True:
	ip1=input("\033[94m IP Address: ")
	url = "http://ip-api.com/json/"
	response = urllib.request.urlopen(url + ip1)
	data = response.read()
	values = json.loads(data.decode('utf-8'))
	os.system("reset")
		
	print(("\033[94m" + "\n IP: " + "\033[92m" + values['query']))
	print(("\033[94m" + " Status: " + "\033[92m" + values['status']))
	print(("\033[94m" + " Region: " + "\033[92m" + values['regionName']))
	print(("\033[94m" + " Country: " + "\033[92m" + values['country']))
	print(("\033[94m" + " City: " + "\033[92m" + values['city']))
	print(("\033[94m" + " ISP: " + "\033[92m" + values['isp']))
	print(("\033[94m" + " Lat,Long: " + "\033[92m" + str(values['lat']) + "," + str(values['lon'])))
	print(("\033[94m" + " ZIPCODE: " + "\033[92m" + values['zip']))
	print(("\033[94m" + " TimeZone: " + "\033[92m" + values['timezone']))
	print(("\033[94m" + " AS: " + "\033[92m" + values['as'] + "\033[0m" + "\n"))
	break
