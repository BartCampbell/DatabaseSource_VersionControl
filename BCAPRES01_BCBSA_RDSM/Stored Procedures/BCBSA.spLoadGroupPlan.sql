SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****************************************************************************************************************************************************
Purpose:				Load GroupPlan
Depenedents:			

Usage					Exec [BCBSA].[spLoadGroupPlan]
							 @rowCount INT=100
							 ,@DestinationTable VARCHAR(100)= 'GroupPlan_Tst100'
	


Change Log:
----------------------------------------------------------------------------------------------------------------------------------------------------- 
2017-03-28	Corey Collins		- Create

****************************************************************************************************************************************************/
;

CREATE PROC [BCBSA].[spLoadGroupPlan]
    @rowCount INT
   ,@DestinationTable VARCHAR(100)
AS --uncomment if running manually to test
/*
declare @rowcount int=4000000
,@DestinationTable varchar(100)='Group_Tst4m'
*/

    DECLARE @vcCmd NVARCHAR(MAX)
       ,@debug INT = 1;


--Drop destination Tables
    IF @DestinationTable = 'GroupPlan_Tst100'
        BEGIN 
            IF OBJECT_ID('bcbsa.GroupPlan_Tst100' , 'U') IS NOT NULL
                DROP TABLE bcbsa.GroupPlan_Tst100;
        END;
    IF @DestinationTable = 'GroupPlan_Tst4m'
        BEGIN
            IF OBJECT_ID('bcbsa.GroupPlan_Tst4m' , 'U') IS NOT NULL
                DROP TABLE bcbsa.GroupPlan_Tst4m;
        END;
      

       

 --Destination table insert
    SET @vcCmd = 'SELECT TOP ' + CAST(@rowCount AS VARCHAR(100)) + '	
[RowFileID]	RowFileID
,[LoadInstanceFileID]	LoadInstanceFileID
,[CustomerGroupID]	GroupID
,[MemberGroupName]	Company
,SICCode	MktSegmentCode
,MemberGroupName1	MktSegmentDesc
,CustomerMemberGroupID	BusinessMktSegCode
,MemberGroupName2	BusinessMktSegDesc
,null	Region
,null	AltPopID1
,null	AltPopID2
,null	NationalEmployerID
,null	GroupCustom1
,null	GroupCustom2
,null	GroupCustom3
,null	GroupCustom4
,null	HIOSID
,null	AsOfDate
,DataSource	SourceID

	   into  bcbsa.' + @DestinationTable + ' 
    FROM    IMI_IMIStaging.dbo.MemberGroup order by rowID desc
';

    IF @debug >= 2
        BEGIN 
            PRINT CHAR(13)
                + 'spLoadGroupPlan: EXEC INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
        END; 
    IF @debug < 2
        AND @debug >= 1
        BEGIN
            PRINT CHAR(13)
                + 'spLoadGroupPlan: Print INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
            EXEC (@vcCmd);
        END; 
	
	
GO
