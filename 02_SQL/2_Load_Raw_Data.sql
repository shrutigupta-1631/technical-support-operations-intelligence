-- Disable safety check (prevent accidental UPDATE or DELETE without a WHERE clause)
SET
    SQL_SAFE_UPDATES = 0;

-- Convert all the blanks to NULL
UPDATE
    csv_data_import
SET
    `Resolution DateTime` = NULLIF(`Resolution DateTime`, ''),
    `First Response DateTime` = NULLIF(`First Response DateTime`, ''),
    `Interaction Count` = NULLIF(`Interaction Count`, ''),
    `CSAT Score` = NULLIF(`CSAT Score`, ''),
    `Resolution Hours` = NULLIF(`Resolution Hours`, ''),
    `First Response Minutes` = NULLIF(`First Response Minutes`, ''),
    `Single Touch Flag` = NULLIF(`Single Touch Flag`, ''),
    `Res SLA Breach` = NULLIF(`Res SLA Breach`, ''),
    `FR SLA Breach` = NULLIF(`FR SLA Breach`, '');

-- Correct all datatypes of the imported fields
ALTER TABLE
    csv_data_import
MODIFY
    `Created DateTime` DATETIME,
MODIFY
    `SLA Resolve Due` DATETIME,
MODIFY
    `SLA First Response Due` DATETIME,
MODIFY
    `Resolution DateTime` DATETIME NULL,
MODIFY
    `First Response DateTime` DATETIME NULL,
MODIFY
    `Interaction Count` INT NULL,
MODIFY
    `CSAT Score` INT NULL,
MODIFY
    `Resolution Hours` DOUBLE NULL,
MODIFY
    `First Response Minutes` INT NULL,
MODIFY
    `Single Touch Flag` BOOLEAN NULL,
MODIFY
    `Res SLA Breach` BOOLEAN NULL,
MODIFY
    `FR SLA Breach` BOOLEAN NULL,
MODIFY
    `Agent Joining Date` DATE;

-- Change column name

ALTER TABLE
    csv_data_import RENAME COLUMN `ï»¿Status` TO `Status`;

-- Enable safety check which was disabled earlier
SET
    SQL_SAFE_UPDATES = 1;