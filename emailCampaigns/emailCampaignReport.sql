USE sr05;

SET profiling = 1;

DROP TABLE IF EXISTS DWEmailCampaignPerformance;
DROP TABLE IF EXISTS DWEmails;
DROP TABLE IF EXISTS DWCampaigns;

CREATE TABLE DWCampaigns (
	campaignId INTEGER PRIMARY KEY,
	campaignName VARCHAR(100),
	audience VARCHAR(100),
	version VARCHAR(100),
	subject VARCHAR(100),

	UNIQUE KEY (campaignName, audience, version, subject)
);

INSERT INTO DWCampaigns
SELECT 	campaignEmailId as campaignId,
	name as campaignName,
	audience,
	version,
	subject
FROM CampaignEmail
	LEFT JOIN
     CampaignEmailVersion USING (campaignEmailId)
	LEFT JOIN
     CampaignEmailAudience USING (campaignEmailId)
	LEFT JOIN
     CampaignEmailSubject USING (campaignEmailId);


CREATE TABLE DWEmails (
	deploymentId INTEGER PRIMARY KEY,
	campaignId INTEGER,
	deploymentDate DATE,
	recepientEmailId VARCHAR(24),

	FOREIGN KEY (campaignId) REFERENCES CampaignEmail (campaignEmailId),
	FOREIGN KEY (recepientEmailId) REFERENCES EmailAddress (emailId),

	UNIQUE KEY (campaignId, deploymentDate, recepientEmailId)
);

INSERT INTO DWEmails
SELECT	id as deploymentId,
	campaignEmailId as campaignId,
	fullDate as deploymentDate,
	emailId as recipientEmailId
FROM Deployment
	JOIN
     CampaignEmail USING (campaignEmailId);

CREATE TABLE DWEmailCampaignPerformance (
        performanceId INTEGER PRIMARY KEY AUTO_INCREMENT,

        campaignId INTEGER,
        deploymentDate DATE,

        emailsDelivered INTEGER,
        uniqueEmailsOpened INTEGER,
        uniqueEmailsClicked INTEGER,
        openRate FLOAT, -- (opened/delivered)
        clickToOpenRate FLOAT, -- (clicked/opened)
        clickRate FLOAT, -- (clicked/delivered)
        unsubRate FLOAT, -- (unsub/opened)

        FOREIGN KEY (campaignId) REFERENCES DWCampaigns (campaignId),
	UNIQUE KEY (campaignId, deploymentDate)
);

INSERT INTO DWEmailCampaignPerformance (campaignId, deploymentDate, emailsDelivered, uniqueEmailsOpened, uniqueEmailsClicked, openRate, clickToOpenRate, clickRate, unsubRate)
SELECT 
campaignId,
deploymentDate,
SUM(delivered) as delivered,
SUM(opened) as opened,
SUM(clicked) as clicked,
COALESCE(SUM(opened) / SUM(delivered), 0) as openRate,
COALESCE(SUM(clicked) / SUM(opened), 0) as clickToOpenRate,
COALESCE(SUM(clicked) / SUM(delivered), 0) as clickRate,
COALESCE(SUM(unsubscribed) / SUM(opened), 0) as unsubscribed
FROM
EmailEventInteractions events
JOIN
(
SELECT d.deploymentId, campaignId, deploymentDate, CASE WHEN SUM(eventTypeId = 20) - SUM(eventTypeId IN (38, 39, 40, 41, 42, 43)) > 0 THEN 1 ELSE 0 END as delivered, CASE WHEN SUM(eventTypeId = 2) > 0 THEN 1 ELSE 0 END as opened, CASE WHEN SUM(eventTypeId = 0) > 0 THEN 1 ELSE 0 END as clicked, CASE WHEN SUM(eventTypeId = 37) > 0 THEN 1 ELSE 0 END as unsubscribed FROM 	EmailEventInteractions eei JOIN (SELECT 	emailEventId, id as eventTypeId FROM EmailEvents ee JOIN EventType et ON ee.eventTypeId = et.id) et USING (emailEventId) JOIN DWEmails d ON eei.deploymentId = d.deploymentId GROUP BY d.deploymentId
) emails
USING (deploymentId)
GROUP BY campaignId, deploymentDate;

SELECT
	campaignName,
	audience,
	version,
	subject,
	deploymentDate,
	emailsDelivered,
	uniqueEmailsOpened,
	uniqueEmailsClicked,
	openRate,
	clickToOpenRate,
	clickRate,
	unsubRate
FROM 	DWEmailCampaignPerformance
		JOIN
	DWCampaigns USING (campaignId);

SHOW profiles;

