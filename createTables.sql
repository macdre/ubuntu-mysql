CREATE TABLE Jena_Climate(the_date DATETIME, p FLOAT, t FLOAT, t_pot FLOAT, t_dew FLOAT,
    rh FLOAT, vp_max FLOAT, vp_act FLOAT, vp_def FLOAT, sh FLOAT, h2oc FLOAT,
    rho FLOAT, wv FLOAT, max_wv FLOAT, wd FLOAT);

LOAD DATA LOCAL INFILE '/root/jena_climate_2009_2016.csv' 
    INTO TABLE Jena_Climate FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' 
    IGNORE 1 ROWS (@the_date, p, t, t_pot, t_dew, rh, vp_max,
    vp_act, vp_def, sh, h2oc, rho, wv, max_wv, wd)
    SET the_date = STR_TO_DATE(@the_date, '%d.%m.%Y %H:%i:%s');