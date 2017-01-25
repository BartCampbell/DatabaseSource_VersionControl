SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:  	
Author:		Leon Dowling
Copyright:	© 2013
Date:		2013.01.01
Purpose:	
Parameters:	
Depends On:	
Calls:		
Called By:	
Returns:	
Notes:		
Process:	
Test Script:	exec ExtrCntrl.PrepExtrCntrl
ToDo:		
*************************************************************************************/

CREATE PROC [ExtrCntrl].[PrepExtrCntrl] AS

DECLARE @bResetAll BIT = 1

DECLARE @vcCmd VARCHAR(MAX)


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ExtrCntrl' )
BEGIN
	SET @vcCmd = 'CREATE SCHEMA ExtrCntrl'
	EXEC (@vcCMD)
END

IF OBJECT_ID('ExtrCntrl.ExtractMaster') is NULL
	OR @bResetAll = 1
BEGIN

	IF OBJECT_ID('ExtrCntrl.ExtractMaster') is NOT NULL
		DROP TABLE ExtrCntrl.ExtractMaster
		
	CREATE TABLE ExtrCntrl.ExtractMaster
		(ExtractMasterID INT IDENTITY(1,1),
		ExtractControlID VARCHAR(20),
		ExtractName VARCHAR(100),
		ExtractCategory VARCHAR(20),
		ExtractRequestingDept VARCHAR(50),
		ExtractRequestingUser VARCHAr(50),
		ExtractDesc VARCHAR(2000),
		InitialCreateDate Datetime,
		InitialCreateUser varchar(20),
		ExtractOutputCode INT,
		CurrentVersion Numeric(5,2),
		InProductionFlag BIT,
		OutputPath varchar(100),
		ProdStoredProcDB VARCHAR(100),
		ProdStoredProcSchema VARCHAR(100),
		ProdStoredProcName VARCHAR(100),
		Parameter1 VARCHAR(100),
		Parameter2 VARCHAR(100),
		Parameter3 VARCHAR(100)
		 )

	ALTER TABLE ExtrCntrl.ExtractMaster ADD CONSTRAINT pk_ExtractMaster PRIMARY KEY (ExtractMasterID)

	INSERT INTO ExtrCntrl.ExtractMaster
	        (ExtractControlID,
	         ExtractName,
	         ExtractCategory,
	         ExtractRequestingDept,
	         ExtractRequestingUser,
	         ExtractDesc,
	         InitialCreateDate,
	         InitialCreateUser,
	         ExtractOutputCode,
	         CurrentVersion,
	         InProductionFlag,
	         OutputPath,
	         ProdStoredProcDB,
	         ProdStoredProcSchema,
	         ProdStoredProcName,
	         Parameter1,
	         Parameter2,
	         Parameter3
	        )
	    VALUES
	        ('DH33', -- ExtractControlID - varchar(20)
	         'Clarity ID Cards', -- ExtractName - varchar(100)
	         'ProdExtract', -- ExtractCategory - varchar(20)
	         '', -- ExtractRequestingDept - varchar(50)
	         '', -- ExtractRequestingUser - varchar(50)
	         '', -- ExtractDesc - varchar(2000)
	         '2014-01-01', -- InitialCreateDate - datetime
	         'Leon Dowling', -- InitialCreateUser - varchar(20)
	         1, -- ExtractOutputCode - int
	         1.3, -- CurrentVersion - numeric
	         1, -- InProductionFlag - bit
	         '\\imifs02\IMI.FTP.Storage\IMI.External.Clients\DHMP.Filestore.FTP\DH33_IDcards\', -- OutputPath - varchar(100)
	         'DHMP_IMIStaging_PROD', -- ProdStoredProcDB - varchar(100)
	         'FileExtr', -- ProdStoredProcSchema - varchar(100)
	         'sp_DH33_Extract_ID_Cards', -- ProdStoredProcName - varchar(100)
	         NULL, -- Parameter1 - varchar(100)
	         NULL, -- Parameter2 - varchar(100)
	         NULL  -- Parameter3 - varchar(100)
	        )

END


IF OBJECT_ID('ExtrCntrl.ExtractType') IS NULL 
	OR @bResetAll = 1
BEGIN

	IF OBJECT_ID('ExtrCntrl.ExtractType') IS NOT NULL 
		DROP TABLE ExtrCntrl.ExtractType

	CREATE TABLE ExtrCntrl.ExtractType
		(ExtractTypeID INT IDENTITY(1,1),
		ExtractTypeName varchar(50),
		ExtractTypeDesc varchar(50))

	ALTER TABLE ExtrCntrl.ExtractType ADD CONSTRAINT pk_ExtractType PRIMARY KEY (ExtractTypeID)
	
	INSERT INTO ExtrCntrl.ExtractType
		SELECT 'PipeDelimited', 'Pipe Delimited text file (|)' UNION ALL
		SELECT 'FixedWidth','Text file with fixed file' UNION ALL
		SELECT 'Excel','Excell output'

	--SELECT * FROM ExtrCntrl.ExtractType
END


IF OBJECT_ID('ExtrCntrl.ExtractSchedule') IS NULL 
	OR @bResetAll = 1
BEGIN

	IF OBJECT_ID('ExtrCntrl.ExtractSchedule') IS NOT NULL 
		DROP TABLE ExtrCntrl.ExtractSchedule

	CREATE TABLE ExtrCntrl.ExtractSchedule
		(ExtractScheduleID INt IDENTITY(1,1),
		ExtractMasterID INT,
		ExtractTiming VARCHAR(20),
		ExtractExecutionTime VARCHAR(20),
		LastRun DATETIME,
		NextRun DATETIME)

	ALTER TABLE ExtrCntrl.ExtractSchedule ADD CONSTRAINT pk_ExtractSchedule PRIMARY KEY (ExtractScheduleID)
	
	INSERT INTO ExtrCntrl.ExtractSchedule
	        (ExtractMasterID,
	         ExtractTiming,
	         ExtractExecutionTime,
	         LastRun,
	         NextRun
	        )
		SELECT ExtractMasterID,
	         ExtractTiming = 'Weekly:Monday',
	         ExtractExecutionTime = '07:00',
	         LastRun = NULL,
	         NextRun = NULL
			FROM ExtrCntrl.ExtractMaster
			WHERE ExtractControlID = 'DH33'


END

IF OBJECT_ID('ExtrCntrl.ExtractAlerts') IS NULL 
	OR @bResetAll = 1
BEGIN
	
	IF OBJECT_ID('ExtrCntrl.ExtractAlerts') IS NOT NULL 
		DROP TABLE ExtrCntrl.ExtractAlerts

	CREATE TABLE ExtrCntrl.ExtractAlerts
		(ExtractAlertID INT IDENTITY(1,1),
		ExctractMasterID INT,
		AlertType VARcHar(20),
		UserName VARCHAR(50),
		UserEmail VARChAR(100),
		UserMobilePhone VARCHAR(20))

	ALTER TABLE ExtrCntrl.ExtractAlerts ADD CONSTRAINT pk_ExtractAlerts PRIMARY KEY (ExtractALertID)

	INSERT INTO ExtrCntrl.ExtractAlerts
	        (ExctractMasterID,
	         AlertType,
	         UserName,
	         UserEmail,
	         UserMobilePhone
	        )
	SELECT ExtractMasterID,
	         AlertType = 'Update',
	         UserName = 'Leon Dowling',
	         UserEmail = 'leon.dowling@imihealth.com',
	         UserMobilePhone = '6152021006'
			FROM ExtrCntrl.ExtractMaster
			WHERE ExtractControlID = 'DH33'


END

		
GO
GRANT VIEW DEFINITION ON  [ExtrCntrl].[PrepExtrCntrl] TO [db_ViewProcedures]
GO
