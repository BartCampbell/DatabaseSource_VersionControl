SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/19/2016
-- Description:	Load all Link Tables from the ProviderOffice staging raw table.  based on CHSDV.[dbo].[prDV_ProviderOffice_LoadLinks]
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Provider_LoadLinks]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

	
					

--*** INSERT INTO L_ProviderOfficeLOCATION

        INSERT  INTO [dbo].[L_ProviderOfficeLocation]
                ( [L_ProviderOfficeLocation_RK] ,
                  [H_ProviderOffice_RK] ,
                  [H_Location_RK] ,
                  [LoadDate] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.[Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        a.ProviderOfficeHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    [CHSStaging].[adv].[tblProviderOfficeStage] a
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.[Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ProviderOfficeLocation_RK
                        FROM    L_ProviderOfficeLocation
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.[Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        a.ProviderOfficeHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        a.LoadDate ,
                        a.RecordSource;


--*** INSERT INTO L_ProviderOfficeCONTACT

        INSERT  INTO [dbo].[L_ProviderOfficeContact]
                ( [L_ProviderOfficeContact_RK] ,
                  [H_ProviderOffice_RK] ,
                  [H_Contact_RK] ,
                  [LoadDate] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              '')))))), 2)) ,
                        a.ProviderOfficeHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              '')))))), 2)) ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    [CHSStaging].[adv].[tblProviderOfficeStage] a
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ProviderOfficeContact_RK
                        FROM    L_ProviderOfficeContact
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              '')))))), 2)) ,
                        a.ProviderOfficeHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              '')))))), 2)) ,
                        a.LoadDate ,
                        a.RecordSource;






--*** INSERT INTO L_ProviderProviderMaster
        INSERT  INTO [dbo].[L_ProviderProviderMaster]
                ( [L_ProviderProviderMaster_RK] ,
                  [H_Provider_RK] ,
                  [H_ProviderMaster_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.ProviderHashKey ,
                        b.ProviderMasterHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    [CHSStaging].[adv].[tblProviderStage] a
                        INNER JOIN [CHSStaging].[adv].[tblProviderMasterStage] b ON a.ProviderMaster_PK = b.ProviderMaster_PK
                                                              AND b.CCI = a.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ProviderProviderMaster_RK
                        FROM    L_ProviderProviderMaster
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.ProviderHashKey ,
                        b.ProviderMasterHashKey ,
                        a.LoadDate ,
                        a.RecordSource; 



--*** INSERT INTO L_ProviderProviderOffice
        INSERT  INTO [dbo].[L_ProviderProviderOffice]
                ( [L_ProviderProviderOffice_RK] ,
                  [H_Provider_RK] ,
                  [H_ProviderOffice_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.ProviderHashKey ,
                        b.ProviderOfficeHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    [CHSStaging].[adv].[tblProviderStage] a
                        INNER JOIN [CHSStaging].[adv].[tblProviderOfficeStage] b ON a.ProviderOffice_PK = b.ProviderOffice_PK
                                                              AND b.CCI = a.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ProviderProviderOffice_RK
                        FROM    L_ProviderProviderOffice
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.ProviderHashKey ,
                        b.ProviderOfficeHashKey ,
                        a.LoadDate ,
                        a.RecordSource; 



						
--*** INSERT INTO L_ProviderProviderOfficeSchedule
        INSERT  INTO [dbo].[L_ProviderOfficeProviderOfficeSchedule]
                ( [L_ProviderOfficeProviderOfficeSchedule_RK] ,
                  [H_ProviderOffice_RK] ,
                  [H_ProviderOfficeSchedule_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.ProviderOfficeHashKey ,
                        b.ProviderOfficeScheduleHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    [CHSStaging].[adv].[tblProviderOfficeStage] a
                        INNER JOIN [CHSStaging].[adv].[tblProviderOfficeScheduleStage] b ON a.ProviderOffice_PK = b.ProviderOffice_PK
                                                              AND b.CCI = a.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ProviderOfficeProviderOfficeSchedule_RK
                        FROM    L_ProviderOfficeProviderOfficeSchedule
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.ProviderOfficeHashKey ,
                        b.ProviderOfficeScheduleHashKey ,
                        a.LoadDate ,
                        a.RecordSource; 




						
--*** INSERT INTO L_ProviderOfficeScheduleUser

        INSERT  INTO [dbo].[L_ProviderOfficeScheduleUser]
                ( [L_ProviderOfficeScheduleUser_RK] ,
                  [H_ProviderOfficeSchedule_RK] ,
                  [H_User_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.ProviderOfficeScheduleHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    [CHSStaging].[adv].[tblProviderOfficeScheduleStage] a
                        INNER JOIN [CHSStaging].[adv].[tblUserStage] b ON a.LastUpdated_User_PK = b.User_PK
                                                              AND b.CCI = a.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ProviderOfficeScheduleUser_RK
                        FROM    L_ProviderOfficeScheduleUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.ProviderOfficeScheduleHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


						
--*** INSERT INTO L_ProviderOfficeScheduleProject

        INSERT  INTO [dbo].[L_ProviderOfficeScheduleProject]
                ( [L_ProviderOfficeScheduleProject_RK] ,
                  [H_ProviderOfficeSchedule_RK] ,
                  [H_Project_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.ProviderOfficeScheduleHashKey ,
                        b.ProjectHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    [CHSStaging].[adv].[tblProviderOfficeScheduleStage] a
                        INNER JOIN [CHSStaging].[adv].[tblProjectStage] b ON a.Project_PK = b.Project_PK
                                                              AND b.CCI = a.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ProviderOfficeScheduleProject_RK
                        FROM    L_ProviderOfficeScheduleProject
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.ProviderOfficeScheduleHashKey ,
                        b.ProjectHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


						
--*** INSERT INTO L_ProviderOfficeScheduleType

        INSERT  INTO [dbo].[L_ProviderOfficeScheduleScheduleType]
                ( [L_ProviderOfficeScheduleScheduleType_RK] ,
                  [H_ProviderOfficeSchedule_RK] ,
                  [H_ScheduleType_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CSI,
                                                              '')))))), 2)) ,
                        a.ProviderOfficeScheduleHashKey ,
                        b.ScheduleTypeHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    [CHSStaging].[adv].[tblProviderOfficeScheduleStage] a
                        INNER JOIN [CHSStaging].[adv].[tblScheduleTypeStage] b ON a.sch_type = b.ScheduleType_PK
                                                              AND b.CCI = a.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CSI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ProviderOfficeScheduleScheduleType_RK
                        FROM    L_ProviderOfficeScheduleScheduleType
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CSI,
                                                              '')))))), 2)) ,
                        a.ProviderOfficeScheduleHashKey ,
                        b.ScheduleTypeHashKey ,
                        a.LoadDate ,
                        a.RecordSource;

    END;
GO
