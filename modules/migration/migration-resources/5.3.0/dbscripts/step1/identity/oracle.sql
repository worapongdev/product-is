ALTER TABLE IDN_OAUTH_CONSUMER_APPS ADD APP_STATE VARCHAR(25) DEFAULT 'ACTIVE'
/
CREATE INDEX IDX_AT ON IDN_OAUTH2_ACCESS_TOKEN(ACCESS_TOKEN)
/
ALTER TABLE SP_APP ADD ENABLE_AUTHORIZATION CHAR(1) DEFAULT '0'
/
ALTER TABLE SP_INBOUND_AUTH ADD INBOUND_CONFIG_TYPE VARCHAR(255) DEFAULT NULL
/
ALTER TABLE SP_CLAIM_MAPPING ADD IS_MANDATORY VARCHAR(128) DEFAULT '0'
/
ALTER TABLE SP_PROVISIONING_CONNECTOR ADD RULE_ENABLED CHAR(1) DEFAULT '0' NOT NULL
/
ALTER TABLE IDP_PROVISIONING_CONFIG ADD IS_RULES_ENABLED CHAR(1) DEFAULT '0' NOT NULL
/
CREATE TABLE IDN_RECOVERY_DATA (
  USER_NAME      VARCHAR2(255)                       NOT NULL,
  USER_DOMAIN    VARCHAR2(127)                       NOT NULL,
  TENANT_ID      INTEGER        DEFAULT -1,
  CODE           VARCHAR2(255)                       NOT NULL,
  SCENARIO       VARCHAR2(255)                       NOT NULL,
  STEP           VARCHAR2(127)                       NOT NULL,
  TIME_CREATED   TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  REMAINING_SETS VARCHAR2(2500) DEFAULT NULL,
  PRIMARY KEY (USER_NAME, USER_DOMAIN, TENANT_ID, SCENARIO, STEP),
  UNIQUE (CODE)
)
/
CREATE TABLE IDN_PASSWORD_HISTORY_DATA (
  ID           INTEGER,
  USER_NAME    VARCHAR2(255)                       NOT NULL,
  USER_DOMAIN  VARCHAR2(127)                       NOT NULL,
  TENANT_ID    INTEGER DEFAULT -1,
  SALT_VALUE   VARCHAR2(255),
  HASH         VARCHAR2(255)                       NOT NULL,
  TIME_CREATED TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (ID),
  UNIQUE (USER_NAME, USER_DOMAIN, TENANT_ID, SALT_VALUE, HASH)
)
/

CREATE SEQUENCE IDN_PASSWORD_HISTORY_DATA_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/

CREATE OR REPLACE TRIGGER IDN_PASSWORD_HISTORY_DATA_TRIG
BEFORE INSERT
ON IDN_PASSWORD_HISTORY_DATA
REFERENCING NEW AS NEW
FOR EACH ROW
  BEGIN
    SELECT IDN_PASSWORD_HISTORY_DATA_SEQ.nextval
    INTO :NEW.ID
    FROM dual;
  END;
/

CREATE TABLE IDN_CLAIM_DIALECT (
  ID          INTEGER,
  DIALECT_URI VARCHAR(255) NOT NULL,
  TENANT_ID   INTEGER      NOT NULL,
  PRIMARY KEY (ID),
  CONSTRAINT DIALECT_URI_CONSTRAINT UNIQUE (DIALECT_URI, TENANT_ID)
)
/
CREATE SEQUENCE IDN_CLAIM_DIALECT_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER IDN_CLAIM_DIALECT_TRIG
BEFORE INSERT
ON IDN_CLAIM_DIALECT
REFERENCING NEW AS NEW
FOR EACH ROW
  BEGIN
    SELECT IDN_CLAIM_DIALECT_SEQ.nextval
    INTO :NEW.ID
    FROM dual;
  END;
/

CREATE TABLE IDN_CLAIM (
  ID         INTEGER,
  DIALECT_ID INTEGER,
  CLAIM_URI  VARCHAR(255) NOT NULL,
  TENANT_ID  INTEGER      NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (DIALECT_ID) REFERENCES IDN_CLAIM_DIALECT (ID) ON DELETE CASCADE,
  CONSTRAINT CLAIM_URI_CONSTRAINT UNIQUE (DIALECT_ID, CLAIM_URI, TENANT_ID)
)
/
CREATE SEQUENCE IDN_CLAIM_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER IDN_CLAIM_TRIG
BEFORE INSERT
ON IDN_CLAIM
REFERENCING NEW AS NEW
FOR EACH ROW
  BEGIN
    SELECT IDN_CLAIM_SEQ.nextval
    INTO :NEW.ID
    FROM dual;
  END;
/

CREATE TABLE IDN_CLAIM_MAPPED_ATTRIBUTE (
  ID                     INTEGER,
  LOCAL_CLAIM_ID         INTEGER,
  USER_STORE_DOMAIN_NAME VARCHAR(255) NOT NULL,
  ATTRIBUTE_NAME         VARCHAR(255) NOT NULL,
  TENANT_ID              INTEGER      NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM (ID) ON DELETE CASCADE,
  CONSTRAINT USER_STORE_DOMAIN_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, USER_STORE_DOMAIN_NAME, TENANT_ID)
)
/
CREATE SEQUENCE IDN_CLAIM_MAPPED_ATTRIBUTE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER IDN_CLAIM_MAPPED_ATTR_TRIG
BEFORE INSERT
ON IDN_CLAIM_MAPPED_ATTRIBUTE
REFERENCING NEW AS NEW
FOR EACH ROW
  BEGIN
    SELECT IDN_CLAIM_MAPPED_ATTRIBUTE_SEQ.nextval
    INTO :NEW.ID
    FROM dual;
  END;
/

CREATE TABLE IDN_CLAIM_PROPERTY (
  ID             INTEGER,
  LOCAL_CLAIM_ID INTEGER,
  PROPERTY_NAME  VARCHAR(255) NOT NULL,
  PROPERTY_VALUE VARCHAR(255) NOT NULL,
  TENANT_ID      INTEGER      NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM (ID) ON DELETE CASCADE,
  CONSTRAINT PROPERTY_NAME_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, PROPERTY_NAME, TENANT_ID)
)
/
CREATE SEQUENCE IDN_CLAIM_PROPERTY_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER IDN_CLAIM_PROPERTY_TRIG
BEFORE INSERT
ON IDN_CLAIM_PROPERTY
REFERENCING NEW AS NEW
FOR EACH ROW
  BEGIN
    SELECT IDN_CLAIM_PROPERTY_SEQ.nextval
    INTO :NEW.ID
    FROM dual;
  END;
/

CREATE TABLE IDN_CLAIM_MAPPING (
  ID                    INTEGER,
  EXT_CLAIM_ID          INTEGER NOT NULL,
  MAPPED_LOCAL_CLAIM_ID INTEGER NOT NULL,
  TENANT_ID             INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (EXT_CLAIM_ID) REFERENCES IDN_CLAIM (ID) ON DELETE CASCADE,
  FOREIGN KEY (MAPPED_LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM (ID) ON DELETE CASCADE,
  CONSTRAINT EXT_TO_LOC_MAPPING_CONSTRN UNIQUE (EXT_CLAIM_ID, TENANT_ID)
)
/
CREATE SEQUENCE IDN_CLAIM_MAPPING_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER IDN_CLAIM_MAPPING_TRIG
BEFORE INSERT
ON IDN_CLAIM_MAPPING
REFERENCING NEW AS NEW
FOR EACH ROW
  BEGIN
    SELECT IDN_CLAIM_MAPPING_SEQ.nextval
    INTO :NEW.ID
    FROM dual;
  END;
/

CREATE TABLE IDN_SAML2_ASSERTION_STORE (
  ID                            INTEGER,
  SAML2_ID                      VARCHAR(255),
  SAML2_ISSUER                  VARCHAR(255),
  SAML2_SUBJECT                 VARCHAR(255),
  SAML2_SESSION_INDEX           VARCHAR(255),
  SAML2_AUTHN_CONTEXT_CLASS_REF VARCHAR(255),
  SAML2_ASSERTION               VARCHAR2(4000),
  PRIMARY KEY (ID)
)
/
CREATE SEQUENCE IDN_SAML2_ASSERTION_STORE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER IDN_SAML2_ASSERTION_STORE_TRIG
BEFORE INSERT
ON IDN_SAML2_ASSERTION_STORE
REFERENCING NEW AS NEW
FOR EACH ROW
  BEGIN
    SELECT IDN_SAML2_ASSERTION_STORE_SEQ.nextval
    INTO :NEW.ID
    FROM dual;
  END;
/