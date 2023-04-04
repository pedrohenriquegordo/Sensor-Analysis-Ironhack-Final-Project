# SGH Dataset

## Description

This dataset was collected as part of the Smart Green Homes (SGH) project.
The project aimed to develop integrated product and technology solutions for 
households, raising standards of comfort, safety, and user satisfaction to a 
new level and, at the same time, respond to the problems of sustainability of 
the planet, increasing energy efficiency and reducing the emission of gaseous 
pollutants and the consumption of water. This specific dataset was collected 
from a set of volunteers. 

## Data records

The dataset is comprised of 13 Comma-Separated Values (CSV) files, each one 
containing the logs associated with each tenant. The name of each file 
contains the respective tenant identification. Each file is divided into 2 
columns: the date and the information. The first line has the purpose of 
naming each of them name and info, respectively, for processing purposes.

Each one of the remaining lines on the files corresponds to an entry, which 
always contains both a timestamp and a JSON structure with the details provided 
by one of the sensors or gateway. The only way to identify the originating 
device of the entry is to look at the fields on the message itself. There are a 
total of 7 different structures, each one from a distinct source. These can be: 


Information regarding the state of the system.
The message contains two fields: device and state. device can contain one of the
following 3: the ID of the corresponding tenant - in which case, the state will be
either "online" or "offline"; the string "feedback" - which is always accompanied
by "not home" in device; or the string "status" - in which case device will be either
"online", "offline" or "Dongle has to reset". 
The 3 possibilities described are summarised in the following representations. 
{"device": <tenant_id>, "state": "online"|"offline"} 
{"device": "feedback", "state": "not home"} 
{"device": "status", "state": "online"|"offline"|"Dongle has to reset"} 


Readings from the sensor of temperature, humidity and pressure. 
The temperature field is always filled up with real numbers ranging from 11.22 to
35.51. Similarly, the linkquality field always has a value - an integer, from 0 to 123.
Both the humidity and pressure fields can have real numbers or not be included. 
humidity ranges from 26.78 to 96.1 while pressure ranges from 922.0 to 1032.8. 
A representation of this message is as follows. 
{"temperature": <float>, "linkquality": <int>, "humidity": <float>|None, "pressure": <float>|None}


Readings from the sensors measuring the status of the doors or windows.
In this message 2 fields are always present: contact - which is either true or false;
and linkquality - which is an integer between 0 and 115. Furthermore, some have
a battery field, containing an integer between 31 and 100, and also a voltage field, 
with another integer between 2955 and 3125. 
A representation of the format for this message is as follows.
{"contact": <bool>, "linkquality": <int>, "battery": <int>|None, "voltage": <int>|None}


Readings from the motion detectors.
Similarly to the previous one, this structure has 2 fields that are always present:
illuminance, which is an integer number between 0 and 1000; linkquality, an 
integer value between 0 and 134. There can be information on occupancy, which is 
a Boolean value; on battery, which can have an integer between 42 and 100; and 
voltage, which can also have an integer between 2975 ad 3065. A representation of 
the format for this message is as follows. 
{"illuminance": <int>, "linkquality": <int>, "occupancy": <bool>|None, "battery": <int>|None, "voltage": <int>|None}


Information about meteorologic conditions.
This entry always contains a description field consisting of a string with the name of 
a place and followed by a date and hour. Even though this field is present in all entries, 
some have the word null in place of the local. Also always present are the fields 
windspeed – a real number between 0 and 52.9; humidity – an integer value comprised 
between -99 and 100; and temperature – another real number between -99 and 36.2. 
The entry might have a winddirection field, which contains a string naming one of 
the 8 cardinal and ordinal points in Portuguese. Additionally, a pressure field might 
be present, with real numbers ranging from 996.2 to 1036.7. It can also contain a field 
precipitation with real numbers between 0 and 13.8. 
A representation of the format for this message is as follows. 
{"pressure": <float>|None, "windspeed": <float>, 
"description": "<local>|null @ <time>", "precipitation": <float>|None, 
"winddirection": "<cardinal/ordinal point>|None", "humidity": <int>, 
"temperature": <float>}

Feedback from the tenant. 
In this message, the field device always has the string "feedback", while the required 
field feedback can be either "comfortable", "uncomfortable" or "not home". 
A representation of the format for this message is as follows. 
{"feedback": "comfortable"|"uncomfortable"|"not home", "device": "feedback"} 