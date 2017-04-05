SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/************************************************************************************* 
Procedure:	exec DataEvaluation.RebuildHEDISProfileDefinitionsMonthlyCount 
Author:		Michael Wu 
Copyright:	c 2016 
Date:		2017.01.03 
Purpose:	 
Parameters: 
Depends On: 
Calls:		 
Called By:	 
Returns:	None 
Notes:		None 
Update Log: 
Test Script: 
  
  
*************************************************************************************/  
  
CREATE PROC [DataEvaluation].[RebuildHEDISProfileDefinitionsMonthlyCount]  
  
AS 

TRUNCATE TABLE DataEvaluation.ProfileDefinitionsMonthlyCount 

BEGIN  
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Count of Total Members 
    -- -------------------------------------------------------------------- 

		INSERT INTO DataEvaluation.ProfileDefinitionsMonthlyCount --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, NonStandardSQL, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport, bStandardDefinition  
      ) 
    SELECT  
          ProfileName   = 'Count of Members: ', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 0,  
		  NonStandardSQL = 'DECLARE	@Min_Start_Date DATETIME = (SELECT CONVERT(VARCHAR(8), DATEADD(MONTH, DATEDIFF(MONTH, 0, MIN([<Eligibility.DateEffective>])), 0),112) FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>] WHERE CASE WHEN ISDATE([<Eligibility.DateEffective>]) = 0 THEN ''19000101'' ELSE [<Eligibility.DateEffective>] END <> ''19000101'')
								   ,@Current_Month_Start_Date DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
								   ,@Loop_Month DATETIME

							SELECT @Loop_Month = @Min_Start_Date

							CREATE TABLE #MemberCount (
								MemberCount INT
								,[Date] DATETIME
							)

							WHILE @Loop_Month <= @Current_Month_Start_Date
							BEGIN

								INSERT INTO #MemberCount (MemberCount, [Date])
								SELECT DISTINCT COUNT([<Eligibility.CustomerMemberID>]), @Loop_Month FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]	WHERE CASE WHEN ISDATE([<Eligibility.DateEffective>]) = 0 THEN ''19000101'' ELSE [<Eligibility.DateEffective>] END < @Loop_Month and [<Eligibility.DateTerminated>] >= @Loop_Month

								SELECT @Loop_Month = DATEADD(MONTH, 1, @Loop_Month)
							END
							',
          SelectSQL     = 'MemberCount, [Date]', 
          FROMSQL       = 'FROM #MemberCount', 
          WHERESQL      = 'WHERE 1 = 1',
          bActive       = 1, 
          bDetailReport = 0,
		  bStandardDefinition = 0 


	-- -------------------------------------------------------------------- 
    -- ProfileName: Claim - Count of Medical Claims
    -- -------------------------------------------------------------------- 
  
		INSERT INTO DataEvaluation.ProfileDefinitionsMonthlyCount --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, NonStandardSQL, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport, bStandardDefinition  
      )
    SELECT  
          ProfileName   = 'Count of Medical Claims: ', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 1, 
		  NonStandardSQL = NULL,
          SelectSQL     = 'COUNT(*), dd.FirstDayOfMonth AS [Date]', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>] c INNER JOIN CHSStaging.dbo.DateDimension dd ON convert(varchar(8),convert(datetime, c.[<Claim.DateServiceBegin>]), 112) = dd.DateKey', 
          WHERESQL      = 'WHERE 1 = 1 GROUP BY dd.FirstDayOfMonth', 
          bActive       = 1,      
          bDetailReport = 0,
		  bStandardDefinition = 1 


	-- -------------------------------------------------------------------- 
    -- ProfileName: PharmacyClaim - Count of Pharmacy Claims
    -- -------------------------------------------------------------------- 

		INSERT INTO DataEvaluation.ProfileDefinitionsMonthlyCount --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, NonStandardSQL, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport, bStandardDefinition  
      )
    SELECT  
          ProfileName   = 'Count of Pharmacy Claims: ', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 1, 
          ReportId      = 11, 
          Order_No      = 1, 
		  NonStandardSQL = NULL,
          SelectSQL     = 'COUNT(*), dd.FirstDayOfMonth AS [Date]', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>] c INNER JOIN CHSStaging.dbo.DateDimension dd ON convert(varchar(8),convert(datetime, c.[<PharmacyClaim.DateDispensed>]), 112) = dd.DateKey', 
          WHERESQL      = 'WHERE 1 = 1 GROUP BY dd.FirstDayOfMonth', 
          bActive       = 1, 
          bDetailReport = 0,
		  bStandardDefinition = 1  


	-- -------------------------------------------------------------------- 
    -- ProfileName: LabResult - Count of Lab Results
    -- -------------------------------------------------------------------- 

		INSERT INTO DataEvaluation.ProfileDefinitionsMonthlyCount --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, NonStandardSQL, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport, bStandardDefinition  
      )
    SELECT  
          ProfileName   = 'Count of Lab Results: ', 
          TargetStagingTable = 'LabResult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 0, 
		  NonStandardSQL = NULL,
          SelectSQL     = 'COUNT(*), dd.FirstDayOfMonth AS [Date]', 
          FROMSQL       = 'FROM [<LabResult.RDSMDB>].[<LabResult.RDSMSchema>].[<LabResult.RDSMTab>] c INNER JOIN CHSStaging.dbo.DateDimension dd ON convert(varchar(8),convert(datetime, c.[<LabResult.DateOfService>]), 112) = dd.DateKey', 
          WHERESQL      = 'WHERE 1 = 1 GROUP BY dd.FirstDayOfMonth', 
          bActive       = 1, 
          bDetailReport = 0,
		  bStandardDefinition = 1  

END

 
GO
