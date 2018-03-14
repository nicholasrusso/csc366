USE sr05;

DROP TABLE IF EXISTS DWAccountRegistrationReport;

SET profiling = 1;

CREATE TABLE  DWAccountRegistrationReport (
	state VARCHAR(40),
	year INTEGER,
	month INTEGER,
	permission INTEGER,
	customerIDCount INTEGER,

	PRIMARY KEY (state, year, month, permission)
);

INSERT INTO DWAccountRegistrationReport
SELECT  state,
        YEAR(accountRegistrationDate) as year,
        MONTH(accountRegistrationDate) as month,
        permission,
        COUNT(DISTINCT customerId) as customerIDCount
FROM AccountRegistration
        JOIN
     CustomerState
USING (accountRegistrationId)
GROUP BY    state,
            YEAR(accountRegistrationDate),
            MONTH(accountRegistrationDate),
            permission;

SELECT * FROM DWAccountRegistrationReport;

SHOW profiles;
