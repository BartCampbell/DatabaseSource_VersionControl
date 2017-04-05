SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*

EXEC prCreateNewClient

Test After:
	DECLARE @iLoadInstanceID INT
	EXECUTE IMIAdmin..prInitializeInstance 'BCBSA', 'Staging Load', 0, NULL, NULL, @iLoadInstanceID OUTPUT 
	SELECT @iLoadInstanceID

SELECT * -- DELETE 
	FROM dbo.ClientProcessInstance WHERE ClientProcessID = (SELECT ClientProcessID FROM dbo.ClientProcess WHERE ClientID = (SELECT ClientID FROM IMIAdmin..Client WHERE ClientName = 'BCBSA'))
SELECT * -- DELETE 
	FROM dbo.ClientProcess WHERE ClientID = (SELECT ClientID FROM IMIAdmin..Client WHERE ClientName = 'BCBSA')
SELECT * -- DELETE 
	FROM IMIAdmin..Client WHERE ClientName = 'BCBSA'
SELECT * -- DELETE 
	FROM IMIAdmin..Customer WHERE CustomerName = 'BCBSA'

*/

CREATE PROC [dbo].[prCreateNewClient]   AS

DECLARE @vcCustomer VARCHAR(100),
	@vcDatabaseDW01 VARCHAR(100),
	@vcDatabaseDW01PROD VARCHAR(100),
	@vcDatabaseIMIDataStore VARCHAR(100),
	@vcDatabaseRDSM VARCHAR(100),
	@vcClientName VARCHAR(100),
	@vcJobDesc VARCHAR(100),
	@vcJobCategory VARCHAR(100),
	@vcJobName VARCHAR(100),
	@vcJobOwner VARCHAR(100),
	@vcSubjectArea VARCHAR(100)
		
SELECT @vcCustomer ='BCBSA',
	@vcDatabaseDW01 ='BCBSA_DW01',
	@vcDatabaseDW01PROD ='BCBSA_DW01_PROD',
	@vcDatabaseIMIDataStore ='BCBSA_CGF_Staging',
	@vcDatabaseRDSM ='BCBSA_RDSM',
	@vcClientName ='BCBSA',
	@vcJobDesc ='Staging Load',
	@vcJobCategory ='CGF',
	@vcJobName ='StagingLoad',
	@vcJobOwner ='QMEAdmin',
	@vcSubjectArea = 'All'
	
				
DECLARE @gCustomerID UNIQUEIDENTIFIER

IF NOT EXISTS (SELECT *
				FROM dbo.Customer
				WHERE CustomerName  = @vcCustomer
			)
	INSERT INTO dbo.Customer
			( 
			  CustomerName ,
			  DatabaseDW01 ,
			  DatabaseDW01Prod ,
			  DatabaseIMIDataStore ,
			  DatabaseRDSM
			)
	SELECT    CustomerName  = @vcCustomer,
			  DatabaseDW01 = @vcDatabaseDW01,
			  DatabaseDW01Prod = @vcDatabaseDW01PROD,
			  DatabaseIMIDataStore = @vcDatabaseIMIDataStore,
			  DatabaseRDSM = @vcDatabaseRDSM


SELECT @gCustomerID = CustomerID	
	FROM dbo.Customer
	WHERE CustomerName  = @vcCustomer
	AND DatabaseDW01 = @vcDatabaseDW01
	AND DatabaseDW01Prod = @vcDatabaseDW01PROD
	AND DatabaseIMIDataStore = @vcDatabaseIMIDataStore
	AND DatabaseRDSM = @vcDatabaseRDSM

IF NOT EXISTS (SELECT *
				FROM dbo.Client
				WHERE ClientName = @vcClientName
				AND CustomerID = @gCustomerID
				AND SystemID IS NULL
				)
	INSERT INTO dbo.Client
			( 
			  ClientName ,
			  CustomerID ,
			  SystemID
			)
	SELECT 
			  @vcClientNAme , -- ClientName - varchar(255)
			  @gCustomerID , -- CustomerID - uniqueidentifier
			  NULL  -- SystemID - uniqueidentifier
       
DECLARE @gClientID UNIQUEIDENTIFIER

SELECT @gClientiD = ClientID
	FROM dbo.Client
	WHERE ClientName = @vcClientName
	AND CustomerID = @gCustomerID
	AND SystemID IS NULL

				
DECLARE @gProcessType UNIQUEIDENTIFIER

SELECT  top 1 @gProcessType = ProcessTypeID
	FROM imiadmin.dbo.ProcessType 
	WHERE Description = 'Full'
	
	
IF NOT EXISTS (SELECT *
				FROM IMIAdmin.dbo.SubjectArea
				WHERE Description = @vcSubjectArea)
	INSERT INTO IMIAdmin.dbo.SubjectArea (Description)
	SELECT @vcSubjectArea

DECLARE @gSubjectAreaID UNIQUEIDENTIFIER

SELECT TOP 1 @gSubjectAreaID = SubjectAreaID
	FROM imiadmin..SubjectArea
	WHERE Description = @vcSubjectArea
	
		
IF NOT EXISTS (SELECT *
					FROM IMIAdmin.dbo.Process
					WHERE Description = @vcJobDesc
					  AND JobCategoryName = @vcJobCategory
					  AND JobName = @vcJobName
					  AND JobOwnerLoginName = @vcJobOwner
					  AND ProcessTypeID = @gProcessType
					  AND SubjectAreaID = ISNULL(@gSubjectAreaID,SubjectAreaID)
					  )
			
	INSERT INTO dbo.Process
			( 
			  Description ,
			  JobCategoryName ,
			  JobName ,
			  JobOwnerLoginName ,
			  ProcessTypeID ,
			  ScheduledStartTime ,
			  SubjectAreaID ,
			  TimeBegin
			)
	SELECT @vcJobDesc , -- Description - varchar(255)
		   @vcJobCategory , -- JobCategoryName - nvarchar(128)
		   @vcJobName , -- JobName - nvarchar(128)
		   @vcJobOwner , -- JobOwnerLoginName - nvarchar(128)
		   @gProcessType, -- ProcessTypeID - uniqueidentifier
		   GETDATE(), -- ScheduledStartTime - datetime
		   @gSubjectAreaID, -- SubjectAreaID - uniqueidentifier
		   GETDATE()-- TimeBegin - datetime
			
DECLARE @gPRocessID UNIQUEIDENTIFIER

SELECT TOP 1 @gProcessID = ProcessID
	FROM IMIAdmin.dbo.Process
	WHERE Description = @vcJobDesc
	  AND JobCategoryName = @vcJobCategory
	  AND JobName = @vcJobName
	  AND JobOwnerLoginName = @vcJobOwner
	  AND ProcessTypeID = @gProcessType
	  AND SubjectAreaID = ISNULL(@gSubjectAreaID,SubjectAreaID)

IF NOT EXISTS (SELECT *
				FROM imiadmin..ClientProcess
				WHERE ClientID = @gClientID
					AND ProcessID = @gPRocessID
				)
	INSERT INTO dbo.ClientProcess
			( 
			  ClientID ,
			  HoursBetweenRuns ,
			  IsStatusingAtRuleStepLevel ,
			  ProcessID ,
			  SuspectThreshold
			)
	SELECT ClientID =@gClientID,
			HoursBetweenRuns =24,
			IsStatusingAtRuleStepLevel =0,
			ProcessID =@gPRocessID,
			SuspectThreshold = 0

DECLARE @gClientProcessID UNIQUEIDENTIFIER

SELECT @gClientProcessID = ClientProcessID
	FROM imiadmin..ClientProcess
	WHERE ClientID = @gClientID
		AND ProcessID = @gPRocessID

SELECT @gClientProcessID, @gPRocessID

IF NOT EXISTS (SELECT * FROM IMIAdmin.dbo.ClientProcessInstance
				WHERE ClientProcessID = @gClientProcessID)

	--INSERT INTO dbo.ClientProcessInstance
	--		( 
	--		  ClientProcessID ,
	--		  DateBeginLoadDataStore ,
	--		  DateEndLoadDataStore ,
	--		  DateBeginLoadRDSM ,
	--		  DateEndLoadRDSM ,
	--		  DateBeginLoadWarehouse ,
	--		  DateEndLoadWarehouse ,
	--		  DateBeginProcessDataStore ,
	--		  DateEndProcessDataStore ,
	--		  InstanceBegin ,
	--		  InstanceEnd ,
	--		  JobID ,
	--		  LastStatus
	--		)
	SELECT   ClientProcessID   = @gClientProcessID,
			  DateBeginLoadDataStore = GETDATE(),
			  DateEndLoadDataStore = GETDATE(),
			  DateBeginLoadRDSM = GETDATE(),
			  DateEndLoadRDSM = GETDATE(),
			  DateBeginLoadWarehouse = GETDATE(),
			  DateEndLoadWarehouse = GETDATE(),
			  DateBeginProcessDataStore = GETDATE(),
			  DateEndProcessDataStore = GETDATE(),
			  InstanceBegin = GETDATE(),
			  InstanceEnd = GETDATE(),
			  JobID = NULL,
			  LastStatus = NULL
	

GO
