USE sr05;

DROP TABLE IF EXISTS DWDeviceRegistrationReport;

SET profiling = 1;

CREATE TABLE DWDeviceRegistrationReport (
    carrier VARCHAR(20),
    year INTEGER,
    month INTEGER,
    deviceModel VARCHAR(64),
    customerIDCount INTEGER,

    PRIMARY KEY (carrier, year, month, deviceModel),
    FOREIGN KEY (deviceModel) REFERENCES Device (model)
);

INSERT INTO DWDeviceRegistrationReport
SELECT  COALESCE(device.carrier, "UNKNOWN"),
        YEAR(regDate) as year,
        MONTH(regDate) as month,
        device.model,
        COUNT(*) as numDevices
FROM DeviceRegistration deviceReg
        JOIN
     Device device
ON deviceReg.deviceModel = device.model
GROUP BY    device.carrier,
            YEAR(regDate),
            MONTH(regDate),
            device.model;

SELECT * FROM DWDeviceRegistrationReport;

SHOW profiles;
