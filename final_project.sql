###########################################
###########################################
###########################################
###########################################
###########################################
USE final_project_database;
###########################################
###########################################
###########################################
###########################################
###########################################
SHOW PROCESSLIST;
KILL 152;

#############################################
#############################################
#######             IMPORT            #######
#############################################
#############################################
SELECT * FROM tenant_table;
SELECT * FROM met_cond;
SELECT * FROM thp_sensors;
SELECT * FROM dw_sensors;
SELECT * FROM motion_sensors;
SELECT * FROM feedback;
###########################################
###########################################



#############################################
# dw_sensors data in aveiro
#############################################

DROP TABLE IF EXISTS contact;
CREATE TABLE contact AS
SELECT ROW_NUMBER() OVER (ORDER BY d.tenant_id, d.date, d.time) AS id,
d.tenant_id, t.tenant, d.contact, d.time, d.date
FROM dw_sensors AS d
INNER JOIN tenant_table AS t ON d.tenant_id = t.tenant_id
WHERE t.city='Aveiro'
	AND d.date >= t.start_date
	AND d.date <= t.end_date
ORDER BY d.tenant_id, d.date, d.time;

UPDATE contact
  SET date = STR_TO_DATE(date, '%d-%m-%Y'),
      time = STR_TO_DATE(time, '%H:%i:%s');

SELECT * FROM contact;

###########################################
# motion_sensors data in aveiro
###########################################

DROP TABLE IF EXISTS presence;
CREATE TABLE presence AS
SELECT ROW_NUMBER() OVER (ORDER BY ms.tenant_id, ms.date, ms.time) AS id,
ms.tenant_id, ms.illuminance ,ms.occupancy, ms.time, ms.date
FROM motion_sensors AS ms
INNER JOIN tenant_table AS t ON ms.tenant_id = t.tenant_id
WHERE t.city='Aveiro'
	AND ms.date >= t.start_date
	AND ms.date <= t.end_date
ORDER BY ms.tenant_id, ms.date, ms.time;

UPDATE presence
  SET date = STR_TO_DATE(date, '%d-%m-%Y'),
      time = STR_TO_DATE(time, '%H:%i:%s');

SELECT * FROM presence;

###########################################

###########################################


# feedback data in aveiro
DROP TABLE IF EXISTS tenant_feedback;
CREATE TABLE tenant_feedback AS
SELECT ROW_NUMBER() OVER (ORDER BY f.tenant_id, f.date, f.time) AS id,
f.tenant_id, f.feedback, f.time, f.date
FROM feedback AS f
INNER JOIN tenant_table AS t ON f.tenant_id = t.tenant_id
WHERE t.city='Aveiro'
	AND f.date >= t.start_date
	AND f.date <= t.end_date
ORDER BY f.tenant_id, f.date, f.time;

UPDATE tenant_feedback
  SET date = STR_TO_DATE(date, '%d-%m-%Y'),
      time = STR_TO_DATE(time, '%H:%i:%s');

SELECT * FROM tenant_feedback;



###########################################
# met_cond tenants in aveiro
###########################################

DROP TABLE IF EXISTS outside;
CREATE TABLE outside AS
SELECT ROW_NUMBER() OVER (ORDER BY m.tenant_id, m.date, m.time) AS id,
m.tenant_id, m.temperature AS temp, m.humidity AS hum, m.pressure AS pre, m.time, m.date
FROM met_cond AS m
INNER JOIN tenant_table AS t ON m.tenant_id = t.tenant_id
WHERE t.city='Aveiro'
	AND m.date >= t.start_date
	AND m.date <= t.end_date
ORDER BY m.tenant_id, m.date, m.time;

UPDATE outside
  SET date = STR_TO_DATE(date, '%d-%m-%Y'),
      time = STR_TO_DATE(time, '%H:%i:%s');
      
SELECT * FROM outside;

###########################################
# thp_sensors data for tenants in aveiro
###########################################

DROP TABLE IF EXISTS inside;
CREATE TABLE inside AS
SELECT ROW_NUMBER() OVER (ORDER BY thp.tenant_id, thp.date, thp.time) AS id,
thp.tenant_id, thp.temperature AS temp, thp.humidity AS hum, thp.pressure AS pre, thp.time, thp.date
FROM thp_sensors AS thp
INNER JOIN tenant_table AS t ON thp.tenant_id = t.tenant_id
WHERE t.city='Aveiro'
	AND thp.date >= t.start_date
	AND thp.date <= t.end_date
ORDER BY thp.tenant_id, thp.date, thp.time;

UPDATE inside
  SET date = STR_TO_DATE(date, '%d-%m-%Y'),
      time = STR_TO_DATE(time, '%H:%i:%s');

SELECT * FROM inside;


#####################################################################
#####################################################################
#  Filter tables for Aveiro location and by valid dates for tenants #
#####################################################################
#####################################################################

#tenants_tables=
SELECT * FROM tenant_table;
#met_cond=
SELECT * FROM outside;
#thp_sensors=
SELECT * FROM inside;
#feedback=
SELECT * FROM tenant_feedback;
#dw_sensors=
SELECT * FROM contact;
#motion_sensors=
SELECT * FROM presence;




#####################################################################
#####################################################################
#####################################################################
###           Create Views with different nulls density           ###
#####################################################################
#####################################################################
#####################################################################





#############################################
#############################################
#######      Tables from inside       #######
#############################################
#############################################


# No nulls
DROP TABLE IF EXISTS nulls_0_inside;
CREATE TABLE nulls_0_inside AS 
SELECT * FROM inside
WHERE
	(CASE WHEN temp IS NULL THEN 1 ELSE 0 END) +
	(CASE WHEN hum IS NULL THEN 1 ELSE 0 END) +
	(CASE WHEN pre IS NULL THEN 1 ELSE 0 END)
	=0;

SELECT * FROM nulls_0_inside;


# 1 null per line
DROP TABLE IF EXISTS nulls_1_inside;
CREATE TABLE nulls_1_inside AS 
SELECT * FROM inside
WHERE
	(CASE WHEN temp IS NULL THEN 1 ELSE 0 END) +
	(CASE WHEN hum IS NULL THEN 1 ELSE 0 END) +
	(CASE WHEN pre IS NULL THEN 1 ELSE 0 END)
	= 1;

SELECT * FROM nulls_1_inside;

# 2 nulls per line
DROP TABLE IF EXISTS nulls_2_inside;
CREATE TABLE nulls_2_inside AS 
SELECT * FROM inside
WHERE
	(CASE WHEN temp IS NULL THEN 1 ELSE 0 END) +
	(CASE WHEN hum IS NULL THEN 1 ELSE 0 END) +
	(CASE WHEN pre IS NULL THEN 1 ELSE 0 END)
	= 2;

SELECT * FROM nulls_2_inside;


#############################################
#############################################
#######     Tables from outside       #######
#############################################
#############################################


# No nulls
DROP TABLE IF EXISTS nulls_0_outside;
CREATE TABLE nulls_0_outside AS 
SELECT * FROM outside
WHERE
	(CASE WHEN temp IS NULL THEN 1 ELSE 0 END) +
	(CASE WHEN hum IS NULL THEN 1 ELSE 0 END) +
	(CASE WHEN pre IS NULL THEN 1 ELSE 0 END)
	=0;

SELECT * FROM nulls_0_outside;


# 1 null per line
DROP TABLE IF EXISTS nulls_1_outside;
CREATE TABLE nulls_1_outside AS 
SELECT * FROM outside
WHERE
	(CASE WHEN temp IS NULL THEN 1 ELSE 0 END) +
	(CASE WHEN hum IS NULL THEN 1 ELSE 0 END) +
	(CASE WHEN pre IS NULL THEN 1 ELSE 0 END)
	= 1;

SELECT * FROM nulls_1_outside;


#####################################################################
#####################################################################
#####################################################################
#########           Create Procedures to get means           ########
#####################################################################
#####################################################################
#####################################################################





#############################################
#######         mean for hour         #######
#############################################
DROP PROCEDURE IF EXISTS hour_mean;
DELIMITER $$
CREATE PROCEDURE hour_mean(IN table_name VARCHAR(255), IN o_table_name VARCHAR(255))
BEGIN
  SET @sql_create_table = CONCAT('
    CREATE TABLE IF NOT EXISTS ', o_table_name, ' (
      temp DECIMAL(10, 2),
      hum DECIMAL(10, 2),
      pre DECIMAL(10, 2),
      hour INT,
      day INT,
      month INT,
      year INT
    )
  ');

  SET @sql_insert = CONCAT('
    INSERT INTO ', o_table_name, ' (temp, hum, pre, hour, day, month, year)
    SELECT 
      ROUND(AVG(temp),2) AS temp,
      ROUND(AVG(hum),2) AS hum,
      ROUND(AVG(pre),2) AS pre,
      HOUR(time) AS hour,
      DAY(date) AS day,
      MONTH(date) AS month,
      YEAR(date) AS year
    FROM 
      ', table_name, '
    GROUP BY 
      HOUR(time), DAY(date), MONTH(date), YEAR(date)
    ORDER BY 
      YEAR(date), MONTH(date), DAY(date), HOUR(time)
  ');

  PREPARE stmt_create_table FROM @sql_create_table;
  EXECUTE stmt_create_table;
  DEALLOCATE PREPARE stmt_create_table;

  PREPARE stmt_insert FROM @sql_insert;
  EXECUTE stmt_insert;
  DEALLOCATE PREPARE stmt_insert;
END $$
DELIMITER ;

DROP TABLE IF EXISTS hour_mean_inside;
CALL hour_mean('inside', 'hour_mean_inside');
SELECT * FROM hour_mean_inside;

DROP TABLE IF EXISTS hour_mean_ouside;
CALL hour_mean('outside', 'hour_mean_outside');
SELECT * FROM hour_mean_outside;



#############################################
#######         mean for days         #######
#############################################
DROP PROCEDURE IF EXISTS day_mean;
DELIMITER $$
CREATE PROCEDURE day_mean(IN table_name VARCHAR(255), IN o_table_name VARCHAR(255))
BEGIN
  SET @sql_create_table = CONCAT('
    CREATE TABLE IF NOT EXISTS ', o_table_name, ' (
      temp DECIMAL(10, 2),
      hum DECIMAL(10, 2),
      pre DECIMAL(10, 2),
      day INT,
      month INT,
      year INT
    )
  ');

  SET @sql_insert = CONCAT('
    INSERT INTO ', o_table_name, ' (temp, hum, pre, day, month, year)
    SELECT 
      ROUND(AVG(temp),2) AS temp,
      ROUND(AVG(hum),2) AS hum,
      ROUND(AVG(pre),2) AS pre,
      DAY(date) AS day,
      MONTH(date) AS month,
      YEAR(date) AS year
    FROM 
      ', table_name, '
    GROUP BY 
      DAY(date), MONTH(date), YEAR(date)
    ORDER BY 
      YEAR(date), MONTH(date), DAY(date)
  ');

  PREPARE stmt_create_table FROM @sql_create_table;
  EXECUTE stmt_create_table;
  DEALLOCATE PREPARE stmt_create_table;

  PREPARE stmt_insert FROM @sql_insert;
  EXECUTE stmt_insert;
  DEALLOCATE PREPARE stmt_insert;
END $$
DELIMITER ;

DROP TABLE IF EXISTS day_mean_inside;
CALL day_mean('inside', 'day_mean_inside');
SELECT * FROM day_mean_inside;

DROP TABLE IF EXISTS day_mean_outside;
CALL day_mean('outside', 'day_mean_outside');
SELECT * FROM day_mean_outside;


#############################################
#######    mean for hour by tenant    #######
#############################################
DROP PROCEDURE IF EXISTS tenant_hour_mean;
DELIMITER $$
CREATE PROCEDURE tenant_hour_mean(IN table_name VARCHAR(255), IN o_table_name VARCHAR(255))
BEGIN
  SET @sql_create_table = CONCAT('
    CREATE TABLE IF NOT EXISTS ', o_table_name, ' (
      tenant_id INT,
      temp DECIMAL(10, 2),
      hum DECIMAL(10, 2),
      pre DECIMAL(10, 2),
      hour INT,
      day INT,
      month INT,
      year INT
    )
  ');

  SET @sql_insert = CONCAT('
    INSERT INTO ', o_table_name, ' (tenant_id, temp, hum, pre, hour, day, month, year)
    SELECT 
      tenant_id,
      ROUND(AVG(temp),2) AS temp,
      ROUND(AVG(hum),2) AS hum,
      ROUND(AVG(pre),2) AS pre,
      HOUR(time) AS hour,
      DAY(date) AS day,
      MONTH(date) AS month,
      YEAR(date) AS year
    FROM 
      ', table_name, '
    GROUP BY 
      tenant_id, HOUR(time), DAY(date), MONTH(date), YEAR(date)
    ORDER BY 
      tenant_id, YEAR(date), MONTH(date), DAY(date), HOUR(time)
  ');

  PREPARE stmt_create_table FROM @sql_create_table;
  EXECUTE stmt_create_table;
  DEALLOCATE PREPARE stmt_create_table;

  PREPARE stmt_insert FROM @sql_insert;
  EXECUTE stmt_insert;
  DEALLOCATE PREPARE stmt_insert;
END $$
DELIMITER ;

DROP TABLE IF EXISTS tenant_hour_mean_inside;
CALL tenant_hour_mean('inside', 'tenant_hour_mean_inside');
SELECT * FROM tenant_hour_mean_inside;

DROP TABLE IF EXISTS tenant_hour_mean_outside;
CALL tenant_hour_mean('outside', 'tenant_hour_mean_outside');
SELECT * FROM tenant_hour_mean_outside;



#############################################
#######    mean for days by tenant    #######
#############################################
DROP PROCEDURE IF EXISTS tenant_day_mean;
DELIMITER $$
CREATE PROCEDURE tenant_day_mean(IN table_name VARCHAR(255), IN o_table_name VARCHAR(255))
BEGIN
  SET @sql_create_table = CONCAT('
    CREATE TABLE IF NOT EXISTS ', o_table_name, ' (
      tenant_id INT,
      temp DECIMAL(10, 2),
      hum DECIMAL(10, 2),
      pre DECIMAL(10, 2),
      day INT,
      month INT,
      year INT
    )
  ');

  SET @sql_insert = CONCAT('
    INSERT INTO ', o_table_name, ' (tenant_id, temp, hum, pre, day, month, year)
    SELECT
	  tenant_id,
      ROUND(AVG(temp),2) AS temp,
      ROUND(AVG(hum),2) AS hum,
      ROUND(AVG(pre),2) AS pre,
      DAY(date) AS day,
      MONTH(date) AS month,
      YEAR(date) AS year
    FROM 
      ', table_name, '
    GROUP BY 
      tenant_id, DAY(date), MONTH(date), YEAR(date)
    ORDER BY 
      tenant_id, YEAR(date), MONTH(date), DAY(date)
  ');

  PREPARE stmt_create_table FROM @sql_create_table;
  EXECUTE stmt_create_table;
  DEALLOCATE PREPARE stmt_create_table;

  PREPARE stmt_insert FROM @sql_insert;
  EXECUTE stmt_insert;
  DEALLOCATE PREPARE stmt_insert;
END $$
DELIMITER ;

DROP TABLE IF EXISTS tenant_day_mean_inside;
CALL tenant_day_mean('inside', 'tenant_day_mean_inside');
SELECT * FROM tenant_day_mean_inside;

DROP TABLE IF EXISTS tenant_day_mean_outside;
CALL tenant_day_mean('outside', 'tenant_day_mean_outside');
SELECT * FROM tenant_day_mean_outside;

##################
##     means    ##
##################

#means for hour
SELECT * FROM hour_mean_inside;
SELECT * FROM hour_mean_outside;
#means for days
SELECT * FROM day_mean_inside;
SELECT * FROM day_mean_outside;
#means for hours for tenants
SELECT * FROM tenant_hour_mean_inside;
SELECT * FROM tenant_hour_mean_outside;
#means for days for tenants
SELECT * FROM tenant_day_mean_inside;
SELECT * FROM tenant_day_mean_outside;

##################
##     nulls    ##
##################

#no nulls
SELECT * FROM nulls_0_outside;
SELECT * FROM nulls_0_inside;
#1 null
SELECT * FROM nulls_1_inside;
SELECT * FROM nulls_1_outside;
#2nulls
SELECT * FROM nulls_2_inside;
SELECT * FROM nulls_2_outside;



#######################
########################
#########################

DROP TABLE IF EXISTS thp_data;
CREATE TABLE thp_data AS 
SELECT
    o.tenant_id,
    i.temp AS in_temp,
    o.temp AS out_temp,
    i.hum AS in_hum,
    o.hum AS out_hum,
    i.pre AS in_pre,
    o.pre AS out_pre,
    HOUR(o.time) AS hour,
	o.date AS date
FROM
    nulls_0_outside AS o
JOIN
    nulls_0_inside AS i
ON
    o.tenant_id = i.tenant_id
    AND DAY(o.date) = DAY(i.date)
    AND HOUR(o.time) = HOUR(i.time)
WHERE
    (i.temp BETWEEN 0 AND 35)
    AND (o.temp BETWEEN 0 AND 35)
    AND (i.hum BETWEEN 0 AND 100)
    AND (o.hum BETWEEN 0 AND 100)
    AND (i.pre BETWEEN 980 AND 1040)
    AND (o.pre BETWEEN 980 AND 1040)
ORDER BY o.tenant_id, o.date, HOUR(o.time);

##############################

SELECT * FROM thp_data;

#########################
########################
######################



#######################
########################
#########################

DROP TABLE IF EXISTS confort_thp;
CREATE TABLE confort_thp AS 
SELECT thp.tenant_id, tf.feedback, thp.in_temp, thp.in_hum, thp.in_pre, thp.out_temp, thp.out_hum, thp.out_pre, thp.hour, thp.date
FROM thp_data AS thp
JOIN 
tenant_feedback AS tf ON
thp.hour=HOUR(tf.time)
AND
thp.date=tf.date
ORDER BY thp.tenant_id, tf.feedback, thp.date, thp.hour;

##############################

SELECT * FROM confort_thp;

#########################
########################
######################


DROP TABLE IF EXISTS contact_thp;
CREATE TABLE contact_thp AS 
SELECT 
    thp.tenant_id,
    c.contact,
    ROUND(AVG(thp.in_temp),2) AS in_temp, 
    ROUND(AVG(thp.in_hum),2) AS in_hum, 
    ROUND(AVG(thp.in_pre),2) AS in_pre, 
    ROUND(AVG(thp.out_temp),2) AS out_temp, 
    ROUND(AVG(thp.out_hum),2) AS out_hum, 
    ROUND(AVG(thp.out_pre),2) AS out_pre,
    MINUTE(c.time) AS mins,
    thp.hour, 
    thp.date
FROM thp_data AS thp
JOIN 
    contact AS c ON
    thp.hour = HOUR(c.time)
    AND
    thp.date = c.date
GROUP BY thp.tenant_id, c.contact, thp.date, thp.hour, MINUTE(c.time)
ORDER BY thp.tenant_id, thp.date, thp.hour, MINUTE(c.time);

SELECT * FROM contact_thp;


DROP TABLE IF EXISTS presence_thp;
CREATE TABLE presence_thp AS 
SELECT 
    thp.tenant_id,
    ROUND(AVG(p.illuminance),2) AS ill,
    p.occupancy AS occ,
    ROUND(AVG(thp.in_temp),2) AS in_temp, 
    ROUND(AVG(thp.in_hum),2) AS in_hum, 
    ROUND(AVG(thp.in_pre),2) AS in_pre, 
    ROUND(AVG(thp.out_temp),2) AS out_temp, 
    ROUND(AVG(thp.out_hum),2) AS out_hum, 
    ROUND(AVG(thp.out_pre),2) AS out_pre,
    MINUTE(p.time) AS mins,
    thp.hour, 
    thp.date
FROM thp_data AS thp
JOIN 
    presence AS p ON
    thp.hour = HOUR(p.time)
    AND
    thp.date = p.date
GROUP BY thp.tenant_id, p.occupancy, thp.date, thp.hour, MINUTE(p.time)
ORDER BY thp.tenant_id, thp.date, thp.hour;

SELECT * FROM presence_thp;







#############################################
#############################################
#######             EXPORT            #######
#############################################
#############################################

# Cleaned Data for temperature, humidity and pressure, for all tenants, inside and outside.
SELECT * FROM thp_data;

# Cleaned Data of temperature, humidity and pressure, for all tenants, inside and outside. (with feedback)
SELECT * FROM confort_thp;

# Semi Cleaned Data of contact related to emperature, humidity and pressure. (set row0=0 and use .fillna(method='ffill'))
SELECT * FROM contact_thp;

# Need to check for nulls. 
SELECT * FROM presence_thp;

################################################
################################################
###################    END   ###################
################################################
################################################



