SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/************************************************************************************* 
Procedure:	exec DataEvaluation.RebuildHEDISProfileDefinitions 
Author:		Leon Dowling 
Copyright:	c 2016 
Date:		2016.01.16 
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
  
CREATE PROC [DataEvaluation].[RebuildHEDISProfileDefinitions]  
  
AS 
  
DECLARE @i INT, @vcCMD VARCHAR(2000) 
  
SET @vcCmd = 'SELECT * INTO DataEvaluation.ProfileDefinitions_' + CONVERT(VARCHAR(8),GETDATE(),112)  
                   + '_'+CONVERT(VARCHAR(2),DATEPART(HOUR,GETDATE()))+'_'+CONVERT(VARCHAR(2),DATEPART(MINUTE,GETDATE())) 
					+ ' FROM DataEvaluation.ProfileDefinitions' 
PRINT @vcCMD  
EXEC (@vcCMD)  

TRUNCATE TABLE DataEvaluation.ProfileDefinitions 
  
DBCC CHECKIDENT ('DataEvaluation.ProfileDefinitions', RESEED, 1000) 
  
  
/* -------------------------------------------------------------------- 
   Member 
*/ -------------------------------------------------------------------- 
  
BEGIN  
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Count of Total Member records 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Total Member records', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 0, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Count of Used Member records 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Used Member records', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 0, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Count of Unused Member records 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Unused Member records', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 0, 
          SelectSQL     = 'a.RecordCount - B.RecordCount ', 
          FROMSQL       = 'FROM (SELECT RecordCount = COUNT(*) FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] 
								  WHERE 1 = 1) a,  		
								(SELECT RecordCount = COUNT(*) FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] 
								  WHERE 1 = 1) b', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Duplicate Member_IDs 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Duplicate Member_IDs', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 1, 
          SelectSQL     = 'COUNT(*) - COUNT(DISTINCT [<Member.CustomerMemberID>]) ', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Multiple IDs per member (name, gender, dob) 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Multiple IDs per member (name, gender, dob)', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 2, 
          SelectSQL     = 'COUNT(*) - COUNT(DISTINCT [<member.NameLast>] + ''|'' 
												+ [<member.namefirst>]  + ''|'' 
												+ [<member.Gender>]  + ''|'' 
												+ [<member.dateofbirth>]) ', 
          FROMSQL       = 'FROM [<member.RDSMDB>].[<member.RDSMSchema>].[<Member.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 
 
 IF 1 = 1
 BEGIN 
    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with no enrollment segments 
    -- -------------------------------------------------------------------- 
	
	
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with no enrollment segments', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 3, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] m
								LEFT JOIN [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>] e
									ON m.[<Member.CustomerMemberID>] = e.[<Eligibility.CustomerMemberID>]',
          WHERESQL      = 'WHERE e.[<eligibility.CustomerMemberID>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Invalid Gender (must be M or F) 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Invalid Gender (must be M or F)', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 4, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE [<member.gender>] NOT IN (''M'',''F'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - DOB NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'DOB NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 5, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.DateOfBirth>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - DOB - Members over 100 yrs old 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'DOB - Members over 100 yrs old', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 6, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.DateOfBirth>],'''') <> '''' AND ISDATE([<member.DateOfBirth>]) = 1  AND dbo.GetAgeAsOF([<member.DateOfBirth>],''##ENDOFYEARDATE##'') > 99', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - DOB - Members with DOB > measurement year 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'DOB - Members with DOB > measurement year', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 7, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE CONVERT(VARCHAR(8),CONVERT(DATETIME,REPLACE(LEFT([<member.DateOfBirth>],10),''-'','''')),112) > ##ENDOFYEARDATE##', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - First Name NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'First Name NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 8, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<Member.NameFirst>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Last Name NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Last Name NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 9, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.NameLast>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 
 
    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Address1 NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Address1 NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 10, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<Member.Address1>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - City NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'City NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 11, 
          SelectSQL     = 'COUNT(distinct [<member.CustomerMemberID>])', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>]  m', 
          WHERESQL      = 'WHERE [<member.City>] IS NULL OR [<member.city>] = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - State NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'State NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 12, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.State>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - State Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'State Invalid', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 12, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.state>],'''') <> '''' AND [<member.state>] = ''RM''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Zip NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Zip NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 13, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.zipcode>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Zip Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Zip Invalid', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 14, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE LEN([<member.zipcode>]) NOT IN (0,5,9)', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Phone NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Phone NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 13, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Phone>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Phone Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Phone Invalid', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 15, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE (ISNUMERIC([<member.phone>]) = 0  			
								OR LEN([<member.Phone>]) <> 10 			
								OR [<member.phone>] in (''9999999999'',''1111111111'',''0000000000'')) 			
								AND ISNULL([<member.phone>],'''') <> ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Guardian Last Name Blank or NULL
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Guardian Last Name Blank or NULL', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 16, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<Member.GuardianLastName>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - HIC Number - NULL 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'HIC Number - NULL', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 17, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE [<member.MedicareID>] IS NULL ', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - HIC Number - duplicates per member 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'HIC Number - duplicates per member', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 17, 
          SelectSQL     = 'COUNT(DISTINCT [<member.MedicareID>])- COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.MedicareID>],'''') <>''''', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Race NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Race NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 17, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.race>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Race Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Race Invalid', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 18, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.race>],'''')  NOT IN (''01'',''02'',''03'',''04'',''05'',''06'',''07'',''09'')  
								AND LTRIM(ISNULL([<member.race>],''''))  NOT IN (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''9'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Ethnicity NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Ethnicity NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 19, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Ethnicity>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Ethnicity Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Ethnicity Invalid', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 20, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Ethnicity>],'''') NOT IN (''11'',''12'',''18'',''19'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Interpreter Flag Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Interpreter Flag Blank or Invalid', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 21, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.InterpreterFlag>],'''') NOT IN ('''',''9'',''09'')', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Language NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Language NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 22, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.MemberLanguage>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - SpokenLanguageSource NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'SpokenLanguageSource NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 23, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.SpokenLanguageSource>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - RaceEthnicitySource  NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'RaceEthnicitySource  NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 24, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.RaceEthnicitySource>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - SpokenLanguage NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'SpokenLanguage NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 25, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.SpokenLanguage>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - WrittenLanguage NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'WrittenLanguage NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 27, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<Member.WrittenLanguage>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - WrittenLanguageSource NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'WrittenLanguageSource NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 28, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.WrittenLanguageSource>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - OtherLanguage NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'OtherLanguage NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 29, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.otherlanguage>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - OtherLanguageSource NULL or Blank 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'OtherLanguageSource NULL or Blank', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 30, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<Member.OtherLanguageSource>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - DOB Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'DOB Invalid', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 31, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE (ISNULL([<member.DateOfBirth>],'''') = '''' OR ISDATE([<member.DateOfBirth>]) = 0)  			', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with no Medical Claims 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with no Medical Claims', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 32, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM (SELECT DISTINCT [<Member.CustomerMemberID>] FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>]) m
							LEFT JOIN (SELECT DISTINCT [<claim.CustomerMemberID>] FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]) c
								ON m.[<member.CustomerMemberID>] = c.[<claim.CustomerMemberID>]', 
       --   FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] m
							--LEFT JOIN (SELECT DISTINCT [<claim.CustomerMemberID>] FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]) c
							--	ON m.[<member.CustomerMemberID>] = c.[<claim.CustomerMemberID>]', 
          WHERESQL      = 'WHERE c.[<claim.CustomerMemberId>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

	-- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with 2016 Eligibility and no Medical Claims 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with 2016 Eligibility and no Medical Claims', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 32, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM (SELECT DISTINCT a.[<Member.CustomerMemberID>]  FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] a
													INNER JOIN [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>] b
														ON a.[CustomerMemberID] = b.[CustomerMemberID]
													WHERE CASE WHEN ISDATE([<Eligibility.DateEffective>]) = 0 THEN ''29991231'' ELSE CONVERT(VARCHAR(8), CONVERT(DATETIME, [<Eligibility.DateEffective>]), 112) END < ''20161231''
													AND (CASE WHEN ISDATE([<Eligibility.DateTerminated>]) = 0 THEN ''19000101'' ELSE CONVERT(VARCHAR(8), CONVERT(DATETIME, [<Eligibility.DateTerminated>]), 112) END > ''20160101'' OR [<Eligibility.DateTerminated>] IS NULL) ) m
							LEFT JOIN (SELECT DISTINCT [<claim.CustomerMemberID>] FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]) c
								ON m.[<member.CustomerMemberID>] = c.[<claim.CustomerMemberID>]', 
          WHERESQL      = 'WHERE c.[<claim.CustomerMemberId>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with no Pharmacy Claims 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with no Pharmacy Claims', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 33, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>]  m
							LEFT JOIN (SELECT DISTINCT [<pharmacyclaim.CustomerMemberId>] from [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]) p
								ON m.[<member.CustomerMemberID>] = p.[<pharmacyclaim.CustomerMemberID>]', 
          WHERESQL      = 'WHERE p.[<PharmacyClaim.CustomerMemberId>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with 2016 Eligibility and no Pharmacy Claims 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with 2016 Eligibility and no Pharmacy Claims', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 33, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM (SELECT DISTINCT a.[<Member.CustomerMemberID>]  FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] a
													INNER JOIN [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>] b
														ON a.[CustomerMemberID] = b.[CustomerMemberID]
													WHERE CASE WHEN ISDATE([<Eligibility.DateEffective>]) = 0 THEN ''29991231'' ELSE CONVERT(VARCHAR(8), CONVERT(DATETIME, [<Eligibility.DateEffective>]), 112) END < ''20161231''
													AND (CASE WHEN ISDATE([<Eligibility.DateTerminated>]) = 0 THEN ''19000101'' ELSE CONVERT(VARCHAR(8), CONVERT(DATETIME, [<Eligibility.DateTerminated>]), 112) END > ''20160101'' OR [<Eligibility.DateTerminated>] IS NULL) ) m
							LEFT JOIN (SELECT DISTINCT [<pharmacyclaim.CustomerMemberId>] from [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]) p
								ON m.[<member.CustomerMemberID>] = p.[<pharmacyclaim.CustomerMemberID>]', 
          WHERESQL      = 'WHERE p.[<PharmacyClaim.CustomerMemberId>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with no lab claims 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with no lab claims', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 35, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>]  m
							LEFT JOIN (SELECT DISTINCT [<LabResult.CustomerMemberID>] FROM [<LabResult.RDSMDB>].[<LabResult.RDSMSchema>].[<LabResult.RDSMTab>] ) l
							  ON m.[<member.CustomerMemberID>] = l.[<LabResult.CustomerMemberID>] ', 
          WHERESQL      = 'WHERE l.[<LabResult.CustomerMemberid>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members wit 2016 Eligibility and no lab claims 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members wit 2016 Eligibility and no lab claims', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 35, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM (SELECT DISTINCT a.[<Member.CustomerMemberID>]  FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] a
													INNER JOIN [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>] b
														ON a.[CustomerMemberID] = b.[CustomerMemberID]
													WHERE CASE WHEN ISDATE([<Eligibility.DateEffective>]) = 0 THEN ''29991231'' ELSE CONVERT(VARCHAR(8), CONVERT(DATETIME, [<Eligibility.DateEffective>]), 112) END < ''20161231''
													AND (CASE WHEN ISDATE([<Eligibility.DateTerminated>]) = 0 THEN ''19000101'' ELSE CONVERT(VARCHAR(8), CONVERT(DATETIME, [<Eligibility.DateTerminated>]), 112) END > ''20160101'' OR [<Eligibility.DateTerminated>] IS NULL) ) m
							LEFT JOIN (SELECT DISTINCT [<LabResult.CustomerMemberID>] FROM [<LabResult.RDSMDB>].[<LabResult.RDSMSchema>].[<LabResult.RDSMTab>] ) l
							  ON m.[<member.CustomerMemberID>] = l.[<LabResult.CustomerMemberID>] ', 
          WHERESQL      = 'WHERE l.[<LabResult.CustomerMemberid>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with White Race 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with White Race', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 37, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Race>],'''') IN (''1'',''01'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with African American Race 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with African American Race', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 38, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Race>],'''') IN(''2'',''02'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with American Indian/Alaskan Native Race 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with American Indian/Alaskan Native Race', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 39, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.race>],'''') IN (''3'',''03'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Asian Race 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Asian Race', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 40, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Race>],'''') IN (''4'',''04'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Native Hawaiian Race 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Native Hawaiian Race', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 41, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.race>],'''') in (''5'',''05'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Some Other Race 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Some Other Race', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 42, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Race>],'''') IN (''6'',''06'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with two or more Race 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with two or more Race', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 43, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Race>],'''') IN (''7'',''07'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Unknown Race 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Unknown Race', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 44, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Race>],'''') IN (''9'',''09'','''')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with declined to provide Race 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with declined to provide Race', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 45, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.race>],'''') = ''10''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Hispanic Ethnicity 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Hispanic Ethnicity', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 46, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Race>],'''') = ''11''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Non Hispanic Ethnicity 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Non Hispanic Ethnicity', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 47, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Race>],'''') NOT IN (''9'',''09'',''11'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members who declined to provide Ethnicity data 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members who declined to provide Ethnicity data', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 48, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.Ethnicity>],'''') =  ''18''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with English spoken language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with English spoken language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 50, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.SpokenLanguage>],'''') = ''31''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Non-English spoken language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Non-English spoken language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 51, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.SpokenLanguage>],'''') = ''32''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Declined spoken language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members who declined to provide spoken language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 52, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.spokenlanguage>],'''') = ''38''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Unknown spoken language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Unknown spoken language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 53, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.SpokenLanguage>],'''') IN ('''',''39'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with English written language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with English written language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 54, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<Member.WrittenLanguage>],'''') = ''51''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Non-English written language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Non-English written language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 55, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.WrittenLanguage>],'''') = ''52''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Declined written language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Declined written language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 56, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<member.WrittenLanguage>],'''') = ''58''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with unknown written language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with unknown written language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 57, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<Member.WrittenLanguage>],'''') IN ('''',''59'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with English other language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with English other language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 58, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE CONVERT(int,[<member.OtherLanguage>]) = ''71''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Non-English other language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Non-English other language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 59, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE CONVERT(int,[<member.OtherLanguage>]) = ''72''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with Declined other language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with Declined other language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 60, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE CONVERT(int,[<member.OtherLanguage>]) = ''78''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with unknown other language 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with unknown other language', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 61, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] ', 
          WHERESQL      = 'WHERE ISNULL([<Member.OtherLanguage>],'''') IN ('''',''79'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

 
 -- -------------------------------------------------------------------- 
    -- ProfileName: Member - Members with no Medical Claims 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Members with more than one eligibility record for product+date', 
          TargetStagingTable = 'Member', 
          LevelID       = 1, 
          ReportId      = 1, 
          Order_No      = 32, 
          SelectSQL     = 'COUNT(DISTINCT a.[<eligibility.CustomerMemberID>])', 
          FROMSQL       = '	FROM (SELECT e.[<Eligibility.CustomerMemberID>], e.[<Eligibility.ProductType>], dt.Date, COUNT(*) CNT 
FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]  e 
INNER JOIN master.dbo.fnDateTable(''20130101'',''20161231'',''month'') dt 
ON CONVERT(VARCHAR(8),dt.date,112) 
BETWEEN CONVERT(VARCHAR(8),CONVERT(DATETIME,e.[<eligibility.DateEffective>]),112) 
AND ISNULL(CONVERT(VARCHAR(8),CONVERT(DATETIME,e.[<eligibility.DateTerminated>]),112),''29981231'') ',
			--SELECT DISTINCT [PlaceHolder1] FROM [RDSMDB].[RDSMSchema].[PlaceHolder2] 
			--) m', 
          WHERESQL      = 'GROUP BY e.[<eligibility.CustomerMemberID>], 
				e.[<Eligibility.ProductType>], 
				dt.Date 
			HAVING COUNT(*) > 1 
			) a', 
          bActive       = 1, 
          
          bDetailReport = 1 

	END
END --   Member 
  
  
/* -------------------------------------------------------------------- 
   Eligibility  
*/ -------------------------------------------------------------------- 
  
BEGIN  
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Count of Total Member records 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Total Eligibility records', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 0, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Count of Used Member records 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Used Eligibility records', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 0, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Unused Eligibility Records 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Unused Eligibility Records', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 0, 
          SelectSQL     = 'a.RecordCount - B.RecordCount ',
		   
          FROMSQL       = 'FROM (SELECT RecordCount = COUNT(*) FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]) a,
					  		(SELECT RecordCount = COUNT(*) FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]) b', 
          WHERESQL      = '', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Count of members on 12/31/2016 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of members on 12/31/2016', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 1, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ''20161231''  
			BETWEEN CASE WHEN ISDATE([<eligibility.DateEffective>]) = 0 THEN ''19000101'' ELSE CONVERT(VARCHAR(8),CONVERT(DATETIME,[<eligibility.DateEffective>]),112) END
			AND ISNULL(CONVERT(VARCHAR(8),CONVERT(DATETIME,[<eligibility.DateTerminated>]),112),''29981231'') 
			', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Member_ID Not In Member Table 
    -- -------------------------------------------------------------------- 
  
      INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Member_ID Not In Member Table', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 2, 
          SelectSQL     = 'COUNT(DISTINCT e.[<Eligibility.CustomerMemberID>])', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>] e
							LEFT JOIN [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] m
								ON e.[<eligibility.CustomerMemberID>] = m.[<member.customerMemberId>] ', 
          WHERESQL      = 'WHERE m.[<member.CustomerMemberID>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Earliest Effective Date 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Earliest Effective Date', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 3, 
          SelectSQL     = 'CONVERT(VARCHAR(10), MIN(CONVERT(DATETIME,[<Eligibility.DateEffective>])), 101) ', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Latest effective date 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Latest effective date', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 3, 
          SelectSQL     = 'CONVERT(VARCHAR(10), MAX(CONVERT(datetime,[<Eligibility.DateEffective>])),101)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISDATE([<Eligibility.DateEffective>]) = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Latest Term Date 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Latest Term Date', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 4, 
          SelectSQL     = 'CONVERT(varchar(10),MAX([<Eligibility.DateTerminated>]),110)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Earliest term date 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Earliest term date', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 4, 
          SelectSQL     = 'CONVERT(varchar(10),MIN([<Eligibility.DateTerminated>]),110)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Term Date Earlier Than Effective Date 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Term Date Earlier Than Effective Date', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 5, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE CONVERT(DATETIME,[<Eligibility.DateTerminated>]) < CONVERT(DATETIME,[<Eligibility.DateEffective>]) 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - Product Blank or Invalid 
    -- -------------------------------------------------------------------- 
  IF 1 = 1-- IF 1 = 2
 BEGIN
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Product Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 6, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<eligibility.producttype>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - HealthPlanEmployeeFlag Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'HealthPlanEmployeeFlag Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 7, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Eligibility.HealthPlanEmployeeFlag>],'''') = '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - CoverageDentalFlag Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CoverageDentalFlag Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 8, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Eligibility.CoverageDentalFlag>],'''') = '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - CoveragePharmacyFlag Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CoveragePharmacyFlag Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 9, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Eligibility.CoveragePharmacyFlag>],'''') = '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - CoverageMHInpatientFlag Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CoverageMHInpatientFlag Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 10, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Eligibility.CoverageMHInpatientFlag>],'''') = '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - CoverageMHDayNightFlag Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CoverageMHDayNightFlag Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 11, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Eligibility.CoverageMHDayNightFlag>],'''') = '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - CoverageMHAmbulatoryFlag Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CoverageMHAmbulatoryFlag Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 12, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Eligibility.CoverageMHAmbulatoryFlag>],'''') = '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - CoverageCDInpatientFlag Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CoverageCDInpatientFlag Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 13, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Eligibility.CoverageCDInpatientFlag>],'''') = '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - CoverageCDDayNightFlag Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CoverageCDDayNightFlag Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 14, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Eligibility.CoverageCDDayNightFlag>],'''') = '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - CoverageCDAmbulatoryFlag Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CoverageCDAmbulatoryFlag Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 15, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Eligibility.CoverageCDAmbulatoryFlag>],'''') = '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Eligibility  - CoverageHospice Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CoverageHospice Blank or Invalid', 
          TargetStagingTable = 'Eligibility', 
          LevelID       = 1, 
          ReportId      = 3, 
          Order_No      = 16, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Eligibility.CoverageHospiceFlag>],'''') = '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
  END
END --   Eligibility  
  
  
/* -------------------------------------------------------------------- 
   Provider  
*/ -------------------------------------------------------------------- 
  
BEGIN  
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - Provider Source Table Record Count 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Provider Source Table Record Count', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 1, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    SET @i = IDENT_CURRENT('DataEvaluation.ProfileDefinitions') 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - Duplicate ProviderIDs 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Duplicate ProviderIDs', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 3, 
          SelectSQL     = 'COUNT(*) - COUNT(DISTINCT [<Provider.CustomerProviderID>])', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - Providers Not in Claims Table 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Providers Not in Claims Table', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 4, 
       --   SelectSQL     = 'COUNT(DISTINCT p.[<Provider.CustomerProviderID>])', 
       --   FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>] p   		 
							--LEFT JOIN [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>] c			
							--	ON p.[<Provider.CustomerProviderID>] = c.[<Claim.CustomerServicingProvID>]', 
       --   WHERESQL      = 'WHERE c.[<Claim.CustomerServicingProvID>] IS NULL', 

		  SelectSQL     = 'COUNT(DISTINCT c.[<Claim.CustomerServicingProvID>])', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>] c   		 
							LEFT JOIN [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>] p			
								ON p.[<Provider.CustomerProviderID>] = c.[<Claim.CustomerServicingProvID>]', 
          WHERESQL      = 'WHERE p.[<Provider.CustomerProviderID>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

 IF 1 = 1 --IF 1 = 2
 BEGIN 
    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - ProviderFullName Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'ProviderFullName Blank or Invalid', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 5, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.ProviderFullName>],'''') = '''' ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - Address Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Address Blank or Invalid', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 6, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.Address>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - City Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'City Blank or Invalid', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 7, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.City>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - State Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'State Blank or Invalid', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 8, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.State>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - Zip Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Zip Blank or Invalid', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 9, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.Zip>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - Phone Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Phone Blank or Invalid', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 10, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.Phone>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - Fax Blank or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Fax Blank or Invalid', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 11, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.Fax>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - Provider Records Not Used 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Provider Records Not Used', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 12, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]  p  		 LEFT JOIN ( 			SELECT [<Claim.CustomerServicingProvID>] FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]  			UNION 			SELECT [<PharmacyClaim.CustomerProviderID>] FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]) dt 				ON p.[<Provider.CustomerProviderID>] = dt.[<Claim.CustomerServicingProvID>]', 
          --FROMSQL       = 'FROM [RDSMDB].[RDSMSchema].[PlaceHolder1]  p  		 LEFT JOIN ( 			SELECT [PlaceHolder4] FROM [RDSMDB].[RDSMSchema].[PlaceHolder3]  			UNION 			SELECT [PlaceHolder6] FROM [RDSMDB].[RDSMSchema].[PlaceHolder5]) dt 				ON p.[PlaceHolder2] = dt.[PlaceHolder4]', 
		  WHERESQL      = 'WHERE dt.[<Claim.CustomerServicingProvID>] IS NULL 		 AND ISNULL(p.[<Provider.CustomerProviderID>],'''') <> ''''', 
		  --WHERESQL      = 'WHERE dt.[PlaceHolder4] IS NULL 		 AND ISNULL(p.[PlaceHolder2],'''') <> ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - AmbulanceFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'AmbulanceFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 13, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.AmbulanceFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 
		    
    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - CDProviderFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CDProviderFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 14, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.CDProviderFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - ClinicalPharmacistFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'ClinicalPharmacistFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 15, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.ClinicalPharmacistFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - DentistFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'DentistFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 16, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.DentistFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - DMEFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'DMEFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 17, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.DurableMedEquipmentFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - EyeCareFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'EyeCareFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 18, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.EyeCareFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - HospitalFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'HospitalFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 19, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.HospitalFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - MentalHealthFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'MentalHealthFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 20, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.MentalHealthFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - NephrologistFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'NephrologistFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 21, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.NephrologistFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - NursePractFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'NursePractFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 22, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.NursePractFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - OBGynFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'OBGynFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 23, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.OBGynFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - PCPFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'PCPFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 24, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.PCPFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - PhysicianAsstFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'PhysicianAsstFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 25, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.PhysicianAsstFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - ProviderPrescribingPrivFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'ProviderPrescribingPrivFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 26, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.ProviderPrescribingPrivFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - RegisteredNurseFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'RegisteredNurseFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 27, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.RegisteredNurseFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - SNFFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'SNFFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 28, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.SNFFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Provider  - SurgeonFlag 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'SurgeonFlag', 
          TargetStagingTable = 'Provider', 
          LevelID       = 1, 
          ReportId      = 5, 
          Order_No      = 29, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Provider.SurgeonFlag>],'''') IN (''True'',''Y'')', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
  END
END --   Provider  
  
  
/* -------------------------------------------------------------------- 
   Claim  
*/ -------------------------------------------------------------------- 
  
BEGIN  
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of claims records from source file 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of claims records from source file', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 0, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of claims not used 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of claims not used', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 0, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 0', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claims with Members Not in Member Table 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claims with Members Not in Member Table', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 1, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>] mc  
		 LEFT JOIN [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] e  
			 ON SUBSTRING(mc.[<Claim.CustomerMemberID>],0, 100) = SUBSTRING(e.[<Member.CustomerMemberID>],0, 100)', 
          WHERESQL      = 'WHERE e.[<member.CustomerMemberID>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Records Missing Claim Number 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records Missing Claim Number', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 2, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE [<Claim.PayerClaimId>] IS NULL  
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

 IF 1 = 1 --IF 1 = 2
 BEGIN 
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Records Missing ServiceDate 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records Missing ServiceDate', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 3, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.DateServiceBegin>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Records Missing ClaimStatus 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records Missing ClaimStatus', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 4, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.ClaimStatus>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claims with Provider Not in Provider Table 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claims with Provider Not in Provider Table', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 5, 
   --       SelectSQL     = 'COUNT(DISTINCT c.[PlaceHolder4])', 
   --       FROMSQL       = 'FROM [RDSMDB].[RDSMSchema].[PlaceHolder1] c 
		 --LEFT JOIN [RDSMDB].[RDSMSchema].[PlaceHolder2] p 
			--ON c.[PlaceHolder4] = p.[PlaceHolder3]', 
   --       WHERESQL      = 'WHERE p.[PlaceHolder3] IS NULL ', 
 
 
		  SelectSQL     = 'COUNT(DISTINCT [<Claim.PayerClaimID>])', 
		  --SelectSQL     = 'DISTINCT COUNT(DISTINCT [PlaceHolder5])', 
		  FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>] c LEFT JOIN [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>] p ON p.[<Provider.CustomerProviderID>] = c.[<Claim.CustomerServicingProvID>] ', 
		  --FROMSQL       = 'FROM [RDSMDB].[RDSMSchema].[PlaceHolder1] c LEFT JOIN [RDSMDB].[RDSMSchema].[PlaceHolder2] p ON p.[PlaceHolder3] = c.[PlaceHolder4] ', 
		  WHERESQL      = 'WHERE p.[<Provider.CustomerProviderID>] IS NULL', 
		  --WHERESQL      = 'WHERE p.[PlaceHolder3] IS NULL', 
 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claim Records in 2016 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2016', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 6, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<Claim.DateServiceBegin>]) = 2016', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claim Records in 2015 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2015', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 6, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<Claim.DateServiceBegin>]) = 2015', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claim Records in 2014 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2014', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 7, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<Claim.DateServiceBegin>]) = 2014 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claim Records in 2013 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2013', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 8, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<Claim.DateServiceBegin>]) = 2013 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claim Records in 2012 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2012', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 9, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<Claim.DateServiceBegin>]) = 2012 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claim Records in 2011 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2011', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 10, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<Claim.DateServiceBegin>]) = 2011 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claim Records in 2010 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2010', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 11, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<Claim.DateServiceBegin>]) = 2010 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claim Records in 2009 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2009', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 12, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<Claim.DateServiceBegin>]) = 2009 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claim with Claim Status Unpaid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claim with Claim Status Unpaid', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 13, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE [<Claim.ClaimStatus>] = ''2'' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - IP Stays longer than 180 days 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim count for IP Stays longer than 180 days', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 14, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.PayerClaimID>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE DATEDIFF(DAY, CONVERT(datetime, [<Claim.DateAdmitted>]), CONVERT(datetime, [<Claim.DateDischarged>])) > 180 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - IP Stays longer than 90 days 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim count for IP Stays longer than 90 days', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 15, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.PayerClaimID>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE DATEDIFF(DAY, CONVERT(datetime, [<Claim.DateAdmitted>]), CONVERT(datetime, [<Claim.DateDischarged>])) > 90  
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claim Count with DischargeDate Earlier Than Admit Date 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Count with DischargeDate Earlier Than Admit Date', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 16, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISDATE([<Claim.DateAdmitted>]) = 1  
		 AND ISDATE([<Claim.DateDischarged>]) = 1) 
		 AND ([<Claim.DateAdmitted>] < ''01/01/2020''  
		 AND [<Claim.DateDischarged>] < ''01/01/2020'') 
		 AND (DATEDIFF(DAY, LTRIM(RTRIM([<Claim.DateAdmitted>])), LTRIM(RTRIM([<Claim.DateDischarged>]))) > 0) 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Claim Count with DischargeDate but without Admit Date 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Count with DischargeDate but without Admit Date', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 17, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE [<Claim.DateDischarged>] IS NOT NULL AND [<Claim.DateAdmitted>] IS NULL 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct ICD-9 Diagnosis 1 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct ICD-9 Diagnosis 1 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 26, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.DiagnosisCode1>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.DiagnosisCode1>],'''') <> '''' AND ISNULL([<Claim.ICDCodeType>],'''') = ''9''', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct ICD-9 Diagnosis 2 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct ICD-9 Diagnosis 2 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 27, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.DiagnosisCode2>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.DiagnosisCode2>],'''') <> '''' AND ISNULL([<Claim.ICDCodeType>],'''') = ''9''', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct ICD-9 Diagnosis 3 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct ICD-9 Diagnosis 3 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 28, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.DiagnosisCode3>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.DiagnosisCode3>],'''') <> '''' AND ISNULL([<Claim.ICDCodeType>],'''') = ''9''', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct ICD-9 Proc 1 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct ICD-9 Proc 1 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 29, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.SurgicalProcedure1>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.SurgicalProcedure1>],'''') <> '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct ICD-9 Proc 2 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct ICD-9 Proc 2 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 30, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.SurgicalProcedure2>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.SurgicalProcedure2>],'''') <> '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct ICD-9 Proc 3 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct ICD-9 Proc 3 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 31, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.SurgicalProcedure3>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.SurgicalProcedure3>],'''') <> '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct DRG_Codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct DRG_Codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 32, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.DiagnosisRelatedGroup>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.DiagnosisRelatedGroup>],'''') <> '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims with Discharge Status 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims with Discharge Status', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 34, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.PayerClaimID>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.DischargeStatus>],'''') <> '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct Bill_Type 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct Bill_Type', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 35, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.BillType>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.BillType>],'''') <> '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct POS 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct POS', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 36, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.PlaceOfService>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.PlaceOfService>],'''') <> '''' 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ ICD-9 Diagnosis 1 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ ICD-9 Diagnosis 1 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 40, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.DiagnosisCode1>],'''') <> '''' AND LTRIM(RTRIM([<Claim.DiagnosisCode1>])) <> ''NULL'') AND ISNULL([<Claim.ICDCodeType>],'''') = ''9''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ ICD-9 Diagnosis 2 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ ICD-9 Diagnosis 2 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 41, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.DiagnosisCode2>],'''') <> '''' AND LTRIM(RTRIM([<Claim.DiagnosisCode2>])) <> ''NULL'') AND ISNULL([<Claim.ICDCodeType>],'''') = ''9''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ ICD-9 Diagnosis 3 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ ICD-9 Diagnosis 3 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 42, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.DiagnosisCode3>],'''') <> '''') AND ISNULL([<Claim.ICDCodeType>],'''') = ''9''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ ICD-9 Proc 1 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ ICD-9 Proc 1 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 43, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.SurgicalProcedure1>],'''') <> '''')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ ICD-9 Proc 2 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ ICD-9 Proc 2 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 44, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.SurgicalProcedure2>],'''') <> '''')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ ICD-9 Proc 3 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ ICD-9 Proc 3 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 45, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.SurgicalProcedure3>],'''') <> '''')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ DRG_Codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ DRG_Codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 45, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.DiagnosisRelatedGroup>],'''') <> '''') 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct Discharge Status 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct Discharge Status', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 47, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.DischargeStatus>],'''') <> '''' AND LTRIM(RTRIM([<Claim.DischargeStatus>])) <> ''NULL'') 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ Bill_Type 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ Bill_Type', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 48, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.BillType>],'''') <> ''''  
								AND LTRIM(RTRIM([<Claim.BillType>])) <> ''NULL''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ POS 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ POS', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 49, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.PlaceOfService>],'''') <> '''' AND LTRIM(RTRIM([<Claim.PlaceOfService>])) <> ''NULL'') 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - BillType Invalid Length/Format 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'BillType Invalid Length/Format', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 99, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE 0 = CASE WHEN ISNULL([<Claim.BillType>],'''') = '''' THEN 1 
			WHEN [<Claim.BillType>] LIKE ''[0][0-9][0-9][0-9]'' THEN 1 
			WHEN [<Claim.BillType>] LIKE ''[0-9][0-9][0-9]'' THEN 1 
			ELSE 0 
			END 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - DRG Invalid Length/Format 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'DRG Invalid Length/Format', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 99, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE 0 = CASE WHEN ISNULL([<Claim.DiagnosisRelatedGroup>],'''') = '''' THEN 1 
			WHEN [<Claim.DiagnosisRelatedGroup>] LIKE ''[0-9][0-9][0-9]'' THEN 1 
			ELSE 0 
			END 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Disch Status Invalid Length/Format 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Disch Status Invalid Length/Format', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 99, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE 0 = CASE WHEN ISNULL([<Claim.DischargeStatus>],'''') = '''' THEN 1 
			WHEN [<Claim.DischargeStatus>] LIKE ''[0-9][0-9]'' THEN 1 
			ELSE 0 
			END 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - POS Invalid Length/Format 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'POS Invalid Length/Format', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 99, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE 0 = CASE WHEN ISNULL([<Claim.PlaceOfService>],'''') = '''' THEN 1 
			WHEN [<Claim.PlaceOfService>] LIKE ''[0-9][0-9]'' THEN 1 
			ELSE 0 
			END 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Records with null or invalid ICD Type 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records with null or invalid ICD Type', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 99, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.ICDCodeType>],'''') NOT IN (''9'',''10'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Records with admit date and no discharge date 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim count with admit date and no discharge date', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 99, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE [<Claim.DateAdmitted>] is NOT NULL 
						   AND [<Claim.DateDischarged>] IS NULL 
						   AND [<Claim.ClaimType>] <> ''P''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ ICD-10 Diagnosis 1 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ ICD-10 Diagnosis 1 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 40, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.DiagnosisCode1>],'''') <> '''' AND LTRIM(RTRIM([<Claim.DiagnosisCode1>])) <> ''NULL'') AND ISNULL([<Claim.ICDCodeType>],'''') = ''10''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ ICD-10 Diagnosis 2 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ ICD-10 Diagnosis 2 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 41, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.DiagnosisCode2>],'''') <> '''' AND LTRIM(RTRIM([<Claim.DiagnosisCode2>])) <> ''NULL'') AND ISNULL([<Claim.ICDCodeType>],'''') = ''10''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Claims w/ ICD-10 Diagnosis 3 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ ICD-10 Diagnosis 3 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 42, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE (ISNULL([<Claim.DiagnosisCode3>],'''') <> '''') AND ISNULL([<Claim.ICDCodeType>],'''') = ''10''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct ICD-10 Diagnosis 1 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct ICD-10 Diagnosis 1 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 26, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.DiagnosisCode1>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.DiagnosisCode1>],'''') <> '''' AND ISNULL([<Claim.ICDCodeType>],'''') = ''10''', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct ICD-9 Diagnosis 2 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct ICD-10 Diagnosis 2 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 27, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.DiagnosisCode2>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.DiagnosisCode2>],'''') <> '''' AND ISNULL([<Claim.ICDCodeType>],'''') = ''10''', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim  - Count of Distinct ICD-10 Diagnosis 3 codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct ICD-10 Diagnosis 3 codes', 
          TargetStagingTable = 'Claim', 
          LevelID       = 1, 
          ReportId      = 7, 
          Order_No      = 28, 
          SelectSQL     = 'COUNT(DISTINCT [<Claim.DiagnosisCode3>]) ', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<Claim.DiagnosisCode3>],'''') <> '''' AND ISNULL([<Claim.ICDCodeType>],'''') = ''10''', 
          bActive       = 1, 
          
          bDetailReport = 0 



  END
END --   Claim  
  
  
/* -------------------------------------------------------------------- 
   Claim Detail  
*/ -------------------------------------------------------------------- 
  
BEGIN  
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Records Claim Number Not in Header Table 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records Claim Number Not in Header Table', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 2, 
          SelectSQL     = 'COUNT(*) ', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>] cli
							LEFT JOIN [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>] C 
								ON cli.[<ClaimLineItem.PayerClaimId>] = c.[<Claim.PayerClaimID>]', 
          WHERESQL      = ' WHERE c.[<claim.PayerClaimId>] IS NULL', 
          bActive       = 1, 
         
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Records null or invalid ServiceDate 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records null or invalid ServiceDate', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 2, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<ClaimLineItem.DateServiceBegin>],'''') = '''' 
								OR ISDATE([<ClaimLineItem.DateServiceBegin>]) = 0', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Records Missing ClaimStatus 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records Missing ClaimStatus', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 4, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE [<ClaimLineItem.ClaimStatus>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

  IF 1 = 1 --IF 1 = 2
  BEgIN
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Records with null or invalid ClaimStatus 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records with null or invalid ClaimStatus', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 4, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<ClaimLineItem.ClaimStatus>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - CPT Code Invalid Length/Format 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CPT Code Invalid Length/Format', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 6, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<ClaimLineItem.CPTProcedureCode>],'''') <> '''' 
        AND [<ClaimLineItem.CPTProcedureCode>] NOT LIKE ''[0-9][0-9][0-9][0-9][0-9]''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - CPTII Invalid Length/Format 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CPTII Invalid Length/Format', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 7, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 =  
			CASE  
				WHEN [<ClaimLineItem.CPT_II>] NOT LIKE ''[0-9][0-9][0-9][0-9][A-Z]'' THEN 1 
				ELSE 0 
				END  
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - HCPCS Invalid Length/Format 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'HCPCS Invalid Length/Format', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 8, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE [<ClaimLineItem.HCPCSProcedureCode>] IS NOT NULL 
        AND [<ClaimLineItem.HCPCSProcedureCode>] <> '''' 
        AND [<ClaimLineItem.HCPCSProcedureCode>] NOT LIKE ''[A-Z][0-9][0-9][0-9][0-9]''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - CPTModifer1 without CPT/HCPCS/CPTII Code 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'CPTModifer1 without CPT/HCPCS/CPTII Code', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 9, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE ( 
		 (ISNULL([<ClaimLineItem.CPTProcedureCodeModifier1>],'''') <> '''') AND  
		 ((ISNULL([<ClaimLineItem.CPTProcedureCode>],'''') = '''') AND (ISNULL([<ClaimLineItem.HCPCSProcedureCode>],'''') = '''') AND (ISNULL([<ClaimLineItem.CPT_II>],'''') = '''')) 
		 )', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Rev Invalid Length/Format 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Rev Invalid Length/Format', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 10, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE 0 = CASE WHEN ISNULL([<ClaimLineItem.RevenueCode>],'''') = '''' THEN 1 
			WHEN [<ClaimLineItem.RevenueCode>] LIKE ''[0][0-9][0-9][0-9]'' THEN 1 
			ELSE 0 
			END 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - POS Invalid Length/Format 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'POS Invalid Length/Format', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 11, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE 0 = CASE WHEN ISNULL([<ClaimLineItem.PlaceOfService>],'''') = '''' THEN 1 
			WHEN [<ClaimLineItem.PlaceOfService>] LIKE ''[0-9][0-9]'' THEN 1 
			ELSE 0 
			END 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Count of Distinct CPT Codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct CPT Codes', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 14, 
          SelectSQL     = 'COUNT(DISTINCT [<ClaimLineItem.CPTProcedureCode>]) ', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Count of Distinct CPTII Codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct CPTII Codes', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 15, 
          SelectSQL     = 'COUNT(DISTINCT [<ClaimLineItem.CPT_II>])  ', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<ClaimLineItem.CPT_II>],'''') <> '''' AND RIGHT(RTRIM([<ClaimLineItem.CPT_II>]),1) = ''F''', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Count of Distinct HCPCS Codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct HCPCS Codes', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 16, 
          SelectSQL     = 'COUNT(DISTINCT [<ClaimLineItem.HCPCSProcedureCode>])  ', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Count of Distinct RevCodes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Distinct RevCodes', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 17, 
          SelectSQL     = 'COUNT(DISTINCT [<ClaimLineItem.RevenueCode>]) ', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<ClaimLineItem.RevenueCode>],'''') <> ''''', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Count of Claim w/ CPT Codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claim w/ CPT Codes', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 18, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 =  
			CASE  
				WHEN [<ClaimLineItem.CPTProcedureCode>] LIKE ''[0-9][0-9][0-9][0-9][0-9]'' THEN 1 
				ELSE 0 
				END  
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Count of Claims w/ CPTII Codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ CPTII Codes', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 19, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 =  
			CASE  
				WHEN [<ClaimLineItem.CPT_II>] LIKE ''[0-9][0-9][0-9][0-9][A-Z]'' THEN 1 
				WHEN [<ClaimLineItem.CPT_II>] LIKE ''[A-Z][A-Z][A-Z][A-Z][A-Z]'' THEN 1 
				ELSE 0 
				END  
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Count of Claims w/ HCPCS Codes 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ HCPCS Codes', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 20, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 =  
			CASE  
				WHEN [<ClaimLineItem.HCPCSProcedureCode>] LIKE ''[0-9][0-9][0-9][0-9][A-Z]'' THEN 1 
				WHEN [<ClaimLineItem.HCPCSProcedureCode>] LIKE ''[A-Z][0-9][0-9][0-9][0-9]'' THEN 1 
				ELSE 0 
				END 
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Count of Claims w/ Revnue Code 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ Revnue Code', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 21, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<ClaimLineItem.RevenueCode>],'''') <> ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Claim Detail  - Records Missing ClaimSequenceNumber 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records Missing ClaimSequenceNumber', 
          TargetStagingTable = 'ClaimLineItem', 
          LevelID       = 1, 
          ReportId      = 9, 
          Order_No      = 24, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<ClaimLineItem.RDSMDB>].[<ClaimLineItem.RDSMSchema>].[<ClaimLineItem.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<ClaimLineItem.PayClaimLineID>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

  END
END --   Claim Detail  
  
  
/* -------------------------------------------------------------------- 
   Pharmacy Claim  
*/ -------------------------------------------------------------------- 
  
BEGIN  
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Pharmacy Claim records counts from source file 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Pharmacy Claim records counts from source file', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 1, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Pharmacy Claim records loaded into Staging 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Pharmacy Claim records loaded into Staging', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 2, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Claims with Members Not in Member Table 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claims with Members Not in Member Table', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 4, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>] c  		 
							LEFT JOIN [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] M  			
								ON M.[<Member.CustomerMemberID>] = C.[<PharmacyClaim.CustomerMemberID>]', 
          WHERESQL      = 'WHERE M.[<Member.CustomerMemberID>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Service Date Missing or Invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Service Date Missing or Invalid', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 5, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<PharmacyClaim.DateDispensed>],'''') = '''' 		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - NDC Code Missing 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'NDC Code Missing', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 6, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<PharmacyClaim.NDC>],'''')  = '''' 		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
 IF 1 = 1 --IF 1 = 2
 BEGIN 
    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Days Supply Missing 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Days Supply Missing', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 7, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<PharmacyClaim.DaysSupply>],'''') = '''' 		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Count of Claims w/ Paid Status 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of Claims w/ Paid Status', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 8, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE [<PharmacyClaim.ClaimStatus>] = ''1''  		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Claim Records in 2015 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2015', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 9, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<PharmacyClaim.DateDispensed>]) = 2015 		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Claim Records in 2014 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2014', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 10, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<PharmacyClaim.DateDispensed>]) = 2014 		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Claim Records in 2013 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2013', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 11, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<PharmacyClaim.DateDispensed>]) = 2013 		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Claim Records in 2012 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2012', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 12, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<PharmacyClaim.DateDispensed>]) = 2012 		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Claim Records in 2011 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Claim Records in 2011', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 13, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE YEAR([<PharmacyClaim.DateDispensed>]) = 2011 		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Records with Denied Claim Status 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records with Denied Claim Status', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 114, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE  [<PharmacyClaim.ClaimStatus>] = ''2''
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Quantity is null or invalid 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Quantity is null or invalid', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 114, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE [<PharmacyClaim.QuantityDispensed>] IS NULL OR ISNUMERIC([<PharmacyClaim.QuantityDispensed>]) = 0', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Duplicate Pharmacy Records 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Duplicate Pharmacy Records', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 2, 
          ReportId      = 11, 
          Order_No      = 114, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM
		(
			SELECT 
				COUNT(*) AS Dup, [<PharmacyClaim.CustomerMemberID>], [<PharmacyClaim.DateDispensed>], [<PharmacyClaim.ClaimNumber>] 
			FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]
			WHERE 1 = 1
			GROUP BY [<PharmacyClaim.CustomerMemberID>], [<PharmacyClaim.DateDispensed>], [<PharmacyClaim.ClaimNumber>]
		) X', 
          WHERESQL      = 'WHERE [X].[Dup] > ''1''', 
          bActive       = 1, 
          
          bDetailReport = 1  

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Count of records with CVX
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of records with CVX', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 1, 
          ReportId      = 11, 
          Order_No      = 150, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE [<PharmacyClaim.ServiceCode>] IS NOT NULL', 
          bActive       = 1, 
          
          bDetailReport = 1  

    -- -------------------------------------------------------------------- 
    -- ProfileName: Pharmacy Claim  - Count of records with invalid CVX formatting
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Count of records with invalid CVX formatting', 
          TargetStagingTable = 'PharmacyClaim', 
          LevelID       = 1, 
          ReportId      = 11, 
          Order_No      = 151, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE LEN([<PharmacyClaim.ServiceCode>]) NOT IN (2, 3) OR ISNUMERIC([<PharmacyClaim.ServiceCode>]) = 0', 
          bActive       = 1, 
          
          bDetailReport = 1 

  END
END --   Pharmacy Claim  
  
  
/* -------------------------------------------------------------------- 
   Lab  
*/ -------------------------------------------------------------------- 
  
BEGIN  
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Lab  - Records in source file 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records in source file', 
          TargetStagingTable = 'Labresult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 0, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

/**TESTING ONLY? -MWU**/
/*
    -- -------------------------------------------------------------------- 
    -- ProfileName: Lab  - Records in source file 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records in source file', 
          TargetStagingTable = 'Labresult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 0, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 0 ', 
          bActive       = 1, 
          
          bDetailReport = 1 
*/
    -- -------------------------------------------------------------------- 
    -- ProfileName: Lab  - Member ID not in Member file 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Member ID not in Member file', 
          TargetStagingTable = 'Labresult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 1, 
          SelectSQL     = 'COUNT(DISTINCT l.[<Labresult.CustomerMemberid>])', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>] l
								LEFT JOIN [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] m
									ON l.[<LabResult.CustomerMemberID>] = m.[<Member.CustomerMemberID>]', 
          WHERESQL      = 'WHERE m.[<Member.CustomerMemberID>] IS NULL', 
          bActive       = 1, 
          
          bDetailReport = 1 

  IF 1 = 1 --IF 1 = 2
  BEGIN 
    -- -------------------------------------------------------------------- 
    -- ProfileName: Lab  - Duplicate lab records 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Duplicate lab records', 
          TargetStagingTable = 'Labresult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 2, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM
		(
			SELECT 
				COUNT(*) AS Dup, [<LabResult.CustomerMemberID>], [<LabResult.OrderNumber>], [<LabResult.ClaimNumber>], [<LabResult.DateofService>], [<LabResult.LOINCCode>]
			FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>]
			WHERE 1 = 1
			GROUP BY [<LabResult.CustomerMemberID>], [<LabResult.OrderNumber>], [<LabResult.ClaimNumber>], [<LabResult.DateofService>], [<LabResult.LOINCCode>]
		) X', 
          WHERESQL      = 'WHERE [X].[Dup] > ''1''', 
          bActive       = 1, 
          
          bDetailReport = 1 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: Lab  - Records with Null LOINC and CPT code 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records with Null LOINC and CPT code', 
          TargetStagingTable = 'Labresult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 3, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>] lr
		 INNER JOIN [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>] m
			ON lr.[<LabResult.CustomerMemberId>] = m.[<Member.CustomerMemberId>]', 
          WHERESQL      = 'WHERE ([<LabResult.LOINCCode>] IS NULL and [<LabResult.LOINCCode>] <> '''')
		 ', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Lab  - Records with invalid LOINC Code 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records with invalid LOINC Code', 
          TargetStagingTable = 'Labresult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 4, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>] ', 
          WHERESQL      = 'WHERE ([<LabResult.LOINCCode>] NOT LIKE ''[0-9][0-9][0-9]-[0-9]'' 
							AND [<LabResult.LOINCCode>] NOT LIKE ''[0-9][0-9][0-9][0-9]-[0-9]''
							AND [<LabResult.LOINCCode>] NOT LIKE ''[0-9][0-9][0-9][0-9][0-9]-[0-9]'')', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Lab  - Records with invalid CPT code 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records with invalid CPT code', 
          TargetStagingTable = 'Labresult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 5, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>]', 
          WHERESQL      = 'WHERE [<LabResult.CPTProcedureCode>] NOT LIKE ''[0-9][0-9][0-9][0-9][0-9]''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Lab  - Records with invalid or Null Date of Service 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records with invalid or Null Date of Service', 
          TargetStagingTable = 'Labresult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 6, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>]', 
          WHERESQL      = 'WHERE ISDATE(REPLACE([<LabResult.DateofService>],''-'',''/'')) = 0', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Lab  - Records with null claim number 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records with null claim number', 
          TargetStagingTable = 'Labresult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 7, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>]', 
          WHERESQL      = 'WHERE ISNULL([<LabResult.ClaimNumber>],'''') = ''''', 
          bActive       = 1, 
          
          bDetailReport = 1 

    -- -------------------------------------------------------------------- 
    -- ProfileName: Lab  - Records with invalid PNIndicator 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Records with invalid PNIndicator', 
          TargetStagingTable = 'Labresult', 
          LevelID       = 1, 
          ReportId      = 13, 
          Order_No      = 8, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>]', 
          WHERESQL      = 'WHERE [<LabResult.PNIndicator>] NOT IN (''P'',''N'','''')', 
          bActive       = 1, 
          
          bDetailReport = 1 

  END
END --   Lab  
  
  
/* -------------------------------------------------------------------- 
   ReportID not defined 
*/ -------------------------------------------------------------------- 
 
IF 1 = 2 
BEGIN  
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: ReportID not defined - SupplementalData 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'SupplementalData', 
          TargetStagingTable = 1, 
          LevelID       = 1, 
          ReportId      = 15, 
          Order_No      = 6, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: ReportID not defined - Member 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Member', 
          TargetStagingTable = 1, 
          LevelID       = 1, 
          ReportId      = 15, 
          Order_No      = 5, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Member.RDSMDB>].[<Member.RDSMSchema>].[<Member.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: ReportID not defined - Eligibility 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Eligibility', 
          TargetStagingTable = 1, 
          LevelID       = 1, 
          ReportId      = 15, 
          Order_No      = 1, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Eligibility.RDSMDB>].[<Eligibility.RDSMSchema>].[<Eligibility.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: ReportID not defined - Medical Claims 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Medical Claims', 
          TargetStagingTable = 1, 
          LevelID       = 1, 
          ReportId      = 15, 
          Order_No      = 3, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Claim.RDSMDB>].[<Claim.RDSMSchema>].[<Claim.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
    -- -------------------------------------------------------------------- 
    -- ProfileName: ReportID not defined - Provider 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Provider', 
          TargetStagingTable = 1, 
          LevelID       = 1, 
          ReportId      = 15, 
          Order_No      = 2, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Provider.RDSMDB>].[<Provider.RDSMSchema>].[<Provider.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: ReportID not defined - Pharmacy 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Pharmacy', 
          TargetStagingTable = 1, 
          LevelID       = 1, 
          ReportId      = 15, 
          Order_No      = 4, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<PharmacyClaim.RDSMDB>].[<PharmacyClaim.RDSMSchema>].[<PharmacyClaim.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 

    -- -------------------------------------------------------------------- 
    -- ProfileName: ReportID not defined - Lab 
    -- -------------------------------------------------------------------- 
  
    INSERT INTO DataEvaluation.ProfileDefinitions --DataEvalution.HEDISProfile 
    (ProfileName, TargetStagingTable, LevelId, ReportId, Order_no, SELECTSQL, FROMSQL, WHERESQL, bActive,  bDetailReport 
      ) 
    SELECT  
          ProfileName   = 'Lab', 
          TargetStagingTable = 1, 
          LevelID       = 1, 
          ReportId      = 15, 
          Order_No      = 6, 
          SelectSQL     = 'COUNT(*)', 
          FROMSQL       = 'FROM [<Labresult.RDSMDB>].[<Labresult.RDSMSchema>].[<Labresult.RDSMTab>]', 
          WHERESQL      = 'WHERE 1 = 1', 
          bActive       = 1, 
          
          bDetailReport = 0 
  
END --   ReportID not defined 
  

--GO
--EXEC [DataEvaluation].[RebuildHEDISProfileTables] 
GO
