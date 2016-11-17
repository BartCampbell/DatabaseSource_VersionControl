SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/16/2016
--Update 09/27/2016 Adding ContactPerson/loaddate PJ
-- Description:	Data Vault Provider Load - based on CHSDV.[dbo].[prDV_Provider_LoadSats]
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Provider_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

--**S_PROVIDERDEMO LOAD


INSERT INTO [dbo].[S_ProviderMasterDemo]
           ([S_ProviderMasterDemo_RK]
           ,[LoadDate]
           ,[H_Provider_RK]
           ,[ProviderMaster_PK]
           ,[Provider_ID]
           ,[NPI]
           ,[TIN]
           ,[PIN]
           ,[LastName]
           ,[FirstName]
           ,[LastUpdated]
           ,[HashDiff]
           ,[RecordSource]
)

                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CPI, ''))), ':', 
														  RTRIM(LTRIM(COALESCE(rw.ProviderMaster_PK, ''))), ':',
														  RTRIM(LTRIM(COALESCE(rw.Provider_ID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.NPI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.TIN, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.PIN, ''))), ':', RTRIM(LTRIM(COALESCE(rw.Lastname, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Firstname, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.LastUpdated , ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        LoadDate ,
                        ProviderMasterHashKey ,
						rw.ProviderMaster_PK,
                        Provider_ID ,
                        [NPI] ,
                        [TIN] ,
                        [PIN] ,
                        [Lastname] ,
                        [Firstname] ,
                        [LastUpdated] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.ProviderMaster_PK, ''))), ':',RTRIM(LTRIM(COALESCE(rw.Provider_ID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.NPI, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.TIN, ''))), ':', RTRIM(LTRIM(COALESCE(rw.PIN, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Lastname, ''))), ':', RTRIM(LTRIM(COALESCE(rw.Firstname, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.LastUpdated , '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblProviderMasterStage rw WITH ( NOLOCK )
                WHERE     UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.ProviderMaster_PK, ''))), ':',RTRIM(LTRIM(COALESCE(rw.Provider_ID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.NPI, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.TIN, ''))), ':', RTRIM(LTRIM(COALESCE(rw.PIN, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Lastname, ''))), ':', RTRIM(LTRIM(COALESCE(rw.Firstname, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.LastUpdated , '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ProviderMasterDemo
                        WHERE   H_Provider_RK = rw.ProviderMasterHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CPI, ''))), ':', 
														  RTRIM(LTRIM(COALESCE(rw.ProviderMaster_PK, ''))), ':',
														  RTRIM(LTRIM(COALESCE(rw.Provider_ID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.NPI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.TIN, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.PIN, ''))), ':', RTRIM(LTRIM(COALESCE(rw.Lastname, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Firstname, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.LastUpdated , ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        LoadDate ,
                        ProviderMasterHashKey ,
						rw.ProviderMaster_PK,
                        Provider_ID ,
                        [NPI] ,
                        [TIN] ,
                        [PIN] ,
                        [Lastname] ,
                        [Firstname] ,
                        [LastUpdated] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.ProviderMaster_PK, ''))), ':',RTRIM(LTRIM(COALESCE(rw.Provider_ID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.NPI, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.TIN, ''))), ':', RTRIM(LTRIM(COALESCE(rw.PIN, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Lastname, ''))), ':', RTRIM(LTRIM(COALESCE(rw.Firstname, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.LastUpdated , '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ProviderMasterDemo
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ProviderMasterDemo z
                                  WHERE     z.H_Provider_RK = a.H_Provider_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ProviderMasterDemo a
        WHERE   a.RecordEndDate IS NULL; 


--**S_PROVIDEROffice LOAD

        INSERT  INTO [dbo].[S_ProviderOfficeDetail]
                ( [S_ProviderOfficeDetail_RK] ,
                  [LoadDate] ,
                  [H_ProviderOffice_RK] ,
                  [EMR_Type] ,
                  [EMR_Type_PK] ,
                  [GroupName] ,
                  [LocationID] ,
                  [ProviderOfficeBucket_PK] ,
                  [Pool_PK] ,
                  [AssignedUser_PK] ,
                  [AssignedDate] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.LoadDate, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.EMR_Type, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.EMR_Type_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.GroupName, ''))), ':', RTRIM(LTRIM(COALESCE(a.LocationID, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.ProviderOfficeBucket_PK, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.Pool_PK, ''))), ':', RTRIM(LTRIM(COALESCE(a.AssignedUser_PK, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.AssignedDate, '')))))), 2)) ,
                        a.LoadDate ,
                        a.ProviderOfficeHashKey ,
                        RTRIM(LTRIM(COALESCE(a.EMR_Type, ''))) AS [EMR_Type] ,
                        a.[EMR_Type_PK] ,
                        RTRIM(LTRIM(COALESCE(a.GroupName, ''))) AS GroupName ,
                        [LocationID] ,
                        [ProviderOfficeBucket_PK] ,
                        [Pool_PK] ,
                        [AssignedUser_PK] ,
                        [AssignedDate] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.EMR_Type, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.EMR_Type_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.GroupName, ''))), ':', RTRIM(LTRIM(COALESCE(a.LocationID, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.ProviderOfficeBucket_PK, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.Pool_PK, ''))), ':', RTRIM(LTRIM(COALESCE(a.AssignedUser_PK, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.AssignedDate, '')))))), 2)) ,
                        a.RecordSource
                FROM    [CHSStaging].[adv].[tblProviderOfficeWCStage] a WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.EMR_Type, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.EMR_Type_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.GroupName, ''))), ':', RTRIM(LTRIM(COALESCE(a.LocationID, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.ProviderOfficeBucket_PK, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.Pool_PK, ''))), ':', RTRIM(LTRIM(COALESCE(a.AssignedUser_PK, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.AssignedDate, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ProviderOfficeDetail
                        WHERE   H_ProviderOffice_RK = a.ProviderOfficeHashKey
                                AND RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.LoadDate, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.EMR_Type, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(a.EMR_Type_PK AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.GroupName, ''))), ':', RTRIM(LTRIM(COALESCE(a.LocationID, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(a.ProviderOfficeBucket_PK, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.Pool_PK, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.AssignedUser_PK, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.AssignedDate, '')))))), 2)) ,
                        a.LoadDate ,
                        a.ProviderOfficeHashKey ,
                        RTRIM(LTRIM(COALESCE(a.EMR_Type, ''))) ,
                        a.[EMR_Type_PK] ,
                        RTRIM(LTRIM(COALESCE(a.GroupName, ''))) ,
                        [LocationID] ,
                        [ProviderOfficeBucket_PK] ,
                        [Pool_PK] ,
                        [AssignedUser_PK] ,
                        [AssignedDate] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.EMR_Type, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.EMR_Type_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.GroupName, ''))), ':', RTRIM(LTRIM(COALESCE(a.LocationID, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.ProviderOfficeBucket_PK, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.Pool_PK, ''))), ':', RTRIM(LTRIM(COALESCE(a.AssignedUser_PK, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.AssignedDate, '')))))), 2)) ,
                        a.RecordSource;
	
	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ProviderOfficeDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ProviderOfficeDetail z
                                  WHERE     z.H_ProviderOffice_RK = a.H_ProviderOffice_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ProviderOfficeDetail a
        WHERE   a.RecordEndDate IS NULL; 

--*** Insert Into S_Location
        INSERT  INTO [dbo].[S_Location]
                ( [S_Location_RK] ,
                  [LoadDate] ,
                  [H_Location_RK] ,
                  [Address1] ,
                  [Zip] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) ,
                        RTRIM(LTRIM(COALESCE(a.[Address], ''))) AS [Address] ,
                        RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), ''))) AS ZipCode_PK ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) ,
                        a.RecordSource
                FROM    [CHSStaging].[adv].[tblProviderOfficeWCStage] a WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Location
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) ,
                        RTRIM(LTRIM(COALESCE(a.[Address], ''))) ,
                        RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), ''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) ,
                        a.RecordSource;


--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Location
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Location z
                                  WHERE     z.H_Location_RK = a.H_Location_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Location a
        WHERE   a.RecordEndDate IS NULL; 
			
--**** INSERT S_CONTACT



        INSERT  INTO [dbo].[S_Contact]
                ( [S_Contact_RK] ,
                  [LoadDate] ,
                  [H_Contact_RK] ,
                  [ContactPerson] ,
                  [Phone] ,
                  [Fax] ,
                  [EmailAddress] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) ,
                        RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))) AS ContactPerson ,
                        RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))) AS ContactNumber ,
                        RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))) AS FaxNumber ,
                        RTRIM(LTRIM(COALESCE(a.Email_Address, ''))) AS Email_Address ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) ,
                        a.RecordSource
                FROM    [CHSStaging].[adv].[tblProviderOfficeWCStage] a WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Contact
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) ,
                        RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))) ,
                        RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))) ,
                        RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))) ,
                        RTRIM(LTRIM(COALESCE(a.Email_Address, ''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) ,
                        a.RecordSource;


		
--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Contact
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Contact z
                                  WHERE     z.H_Contact_RK = a.H_Contact_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Contact a
        WHERE   a.RecordEndDate IS NULL; 


--** Load S_ProviderOfficeSchedule

        INSERT  INTO [dbo].[S_ProviderOfficeSchedule]
                ( [S_ProviderOfficeSchedule_RK] ,
                  [LoadDate] ,
                  [H_ProviderOfficeSchedule_RK] ,
                  [Sch_Start] ,
                  [Sch_End] ,
                  [Sch_User_PK] ,
                  [LastUpdated_Date] ,
                  [followup] ,
                  [AddInfo] ,
                  [sch_type] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Sch_Start], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Sch_End], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Sch_User_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[followup], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[AddInfo], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[sch_type], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        LoadDate ,
                        ProviderOfficeScheduleHashKey ,
                        [Sch_Start] ,
                        [Sch_End] ,
                        [Sch_User_PK] ,
                        [LastUpdated_Date] ,
                        [followup] ,
                        [AddInfo] ,
                        [sch_type] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Sch_Start], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Sch_End], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[Sch_User_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[followup], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[AddInfo], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[sch_type], '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblProviderOfficeScheduleStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Sch_Start], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Sch_End], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[Sch_User_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[followup], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[AddInfo], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[sch_type], '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ProviderOfficeSchedule
                        WHERE   H_ProviderOfficeSchedule_RK = rw.ProviderOfficeScheduleHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Sch_Start], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Sch_End], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Sch_User_PK], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[followup], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[AddInfo], ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(rw.[sch_type], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        LoadDate ,
                        ProviderOfficeScheduleHashKey ,
                        [Sch_Start] ,
                        [Sch_End] ,
                        [Sch_User_PK] ,
                        [LastUpdated_Date] ,
                        [followup] ,
                        [AddInfo] ,
                        [sch_type] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Sch_Start], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Sch_End], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[Sch_User_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[followup], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[AddInfo], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[sch_type], '')))))), 2)) ,
                        RecordSource;



	--** Load dbo.S_ProviderOfficeSchedule 

        UPDATE  dbo.S_ProviderOfficeSchedule
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ProviderOfficeSchedule z
                                  WHERE     z.H_ProviderOfficeSchedule_RK = a.H_ProviderOfficeSchedule_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ProviderOfficeSchedule a
        WHERE   a.RecordEndDate IS NULL;

    END;





GO
