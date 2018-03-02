CREATE TABLE RegistrationSource (
    id INTEGER PRIMARY KEY,
    sourceName VARCHAR(45)
);

CREATE TABLE Device (
    model VARCHAR(64) PRIMARY KEY,
    name VARCHAR(64),
    carrier VARCHAR(20),
    type VARCHAR(20)
);

CREATE TABLE State (
    abbr VARCHAR(2),
    name VARCHAR(40) PRIMARY KEY,
    UNIQUE(abbr)
);

CREATE TABLE Campaign (
    name VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Version (
    version VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Subject (
    subject VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Audience (
    audience VARCHAR(100) PRIMARY KEY
);



CREATE TABLE CustomerAccount (
    customerId INTEGER PRIMARY KEY
);

CREATE TABLE AccountRegistration(
    accountRegistrationId INTEGER AUTO_INCREMENT PRIMARY KEY,
    customerId INTEGER,
    permission INTEGER, 
    regSource INTEGER,
    accountRegistrationDate DATE,
    FOREIGN KEY (regSource) REFERENCES RegistrationSource(id),
    FOREIGN KEY (customerId) REFERENCES CustomerAccount(customerId)
);

CREATE TABLE CustomerTier(
    accountRegistrationId INTEGER,
    customerTier VARCHAR(12),
    FOREIGN KEY (accountRegistrationId) REFERENCES AccountRegistration(accountRegistrationId),
    PRIMARY KEY (accountRegistrationId, customerTier)
);

CREATE TABLE Language (
    accountRegistrationId INTEGER PRIMARY KEY,
    language VARCHAR(20),
    FOREIGN KEY (accountRegistrationId) REFERENCES AccountRegistration (accountRegistrationId)
);

CREATE TABLE Gender (
    accountRegistrationId INTEGER PRIMARY KEY,
    gender VARCHAR(6),
    FOREIGN KEY (accountRegistrationId) REFERENCES AccountRegistration (accountRegistrationId)
);

CREATE TABLE IncomeLevel (
    accountRegistrationId INTEGER PRIMARY KEY,
    level VARCHAR(20),
    FOREIGN KEY (accountRegistrationId) REFERENCES AccountRegistration (accountRegistrationId)
);

CREATE TABLE CustomerZip (
    accountRegistrationId INTEGER PRIMARY KEY,
    zip VARCHAR(20),
    FOREIGN KEY (accountRegistrationId) REFERENCES AccountRegistration (accountRegistrationId)
);

CREATE TABLE CustomerState (
    accountRegistrationId INTEGER PRIMARY KEY,
    state VARCHAR(40),
    FOREIGN KEY (accountRegistrationId) REFERENCES AccountRegistration (accountRegistrationId)
);

CREATE TABLE DeviceRegistration (
    id INTEGER PRIMARY KEY,
    customerId INTEGER,
    regDate DATE,
    regSource INTEGER,
    numReg INTEGER,
    ecommFlag INTEGER,
    deviceModel varchar(64),
    FOREIGN KEY (customerId) REFERENCES CustomerAccount (customerId),
    FOREIGN KEY (regSource) REFERENCES RegistrationSource(id),
    FOREIGN KEY (deviceModel) REFERENCES Device(model)
);


CREATE TABLE DeviceSerialNumber (
    deviceRegistrationId INTEGER PRIMARY KEY,
    serialNum VARCHAR(64),
    FOREIGN KEY (deviceRegistrationId) REFERENCES DeviceRegistration(id)
);

CREATE TABLE Purchase (
    regId INTEGER PRIMARY KEY,
    purchaseDate DATE,
    storeName VARCHAR(64),
    storeCity VARCHAR(64),
    storeState VARCHAR(2),
    FOREIGN KEY (regId) REFERENCES DeviceRegistration(id),
    FOREIGN KEY (storeState) REFERENCES State(abbr)
); 

CREATE TABLE EmailAddress (
    emailId VARCHAR(24) PRIMARY KEY,
    domain VARCHAR(60),
    customerId INTEGER,
    FOREIGN KEY (customerId) REFERENCES CustomerAccount(customerId)
);

CREATE TABLE CampaignEmail (
    campaignEmailId INTEGER AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    FOREIGN KEY (name) REFERENCES Campaign (name)
);  

CREATE TABLE CampaignEmailVersion (
    campaignEmailId INTEGER,
    version VARCHAR(100),
    FOREIGN KEY (version) REFERENCES Version(version),
    FOREIGN KEY (campaignEmailId) REFERENCES CampaignEmail(campaignEmailId),
    PRIMARY KEY(campaignEmailId, version) 
);

CREATE TABLE CampaignEmailAudience (
    campaignEmailId INTEGER,
    audience VARCHAR(100),
    FOREIGN KEY (audience) REFERENCES Audience(audience),
    FOREIGN KEY (campaignEmailId) REFERENCES CampaignEmail(campaignEmailId),
    PRIMARY KEY(campaignEmailId, audience) 
);

CREATE TABLE CampaignEmailSubject (
    campaignEmailId INTEGER,
    subject VARCHAR(100),
    FOREIGN KEY (subject) REFERENCES Subject(subject),
    FOREIGN KEY (campaignEmailId) REFERENCES CampaignEmail(campaignEmailId),
    PRIMARY KEY(campaignEmailId, subject) 
);

CREATE TABLE Deployment (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    deploymentId INTEGER,
    fullDate DATE,
    campaignEmailId INTEGER,
    emailId VARCHAR(24),
    FOREIGN KEY (campaignEmailId) REFERENCES CampaignEmail(campaignEmailId),
    FOREIGN KEY (emailId) REFERENCES EmailAddress(emailId)
);

CREATE TABLE EventType (
    id INTEGER PRIMARY KEY,
    name varchar(50)
);

CREATE TABLE Links (
    linkId INTEGER AUTO_INCREMENT PRIMARY KEY,
    url VARCHAR(255),
    linkName VARCHAR(255),
    UNIQUE KEY (url, linkName)
);

CREATE TABLE EmailEvents (
    emailEventId INTEGER AUTO_INCREMENT PRIMARY KEY,
    eventDate DATETIME,
    eventTypeId INTEGER,
    FOREIGN KEY (eventTypeId) REFERENCES EventType(id)
);

CREATE TABLE ClickedLinks (
    linkId INTEGER,
    emailEventId INTEGER,
    PRIMARY KEY (linkId, emailEventId),
    FOREIGN KEY (linkId) REFERENCES Links(linkId),
    FOREIGN KEY(emailEventId) REFERENCES EmailEvents(emailEventId)
);

CREATE TABLE EmailEventInteractions (
    deploymentId INTEGER,
    emailEventId INTEGER,
    PRIMARY KEY(deploymentId, emailEventId),
    FOREIGN KEY (deploymentId) REFERENCES Deployment(id),
    FOREIGN KEY (emailEventId) REFERENCES EmailEvents (emailEventId)
);

