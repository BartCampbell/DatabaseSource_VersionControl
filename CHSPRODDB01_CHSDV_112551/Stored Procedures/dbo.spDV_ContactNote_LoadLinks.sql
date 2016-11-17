SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/29/2016
-- Description:	Load all Link Tables from the tblContactNotesOfficeStage table.  BAsed on CHSDV.dbo.prDV_ContactNotesOffice_LoadLinks
-- =============================================
CREATE  PROCEDURE [dbo].[spDV_ContactNote_LoadLinks]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
	
--*LOAD L_ContactNotesOfficeProvider

        INSERT  INTO L_ContactNotesOfficeProvider
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ProviderOfficeHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSStaging.adv.tblProviderOfficeStage b
                        WITH ( NOLOCK ) ON b.ProviderOffice_PK = rw.Office_PK
                                           AND b.CCI = rw.CCI
                        
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ContactNotesOfficeProvider_RK
                        FROM    L_ContactNotesOfficeProvider
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ProviderOfficeHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;

	
		--** Load L_ContactNotesOfficeUser
        INSERT  INTO L_ContactNotesOfficeUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.UserHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSStaging.adv.tblUserStage b WITH ( NOLOCK ) ON b.User_PK = rw.LastUpdated_User_PK
                                                              AND rw.CCi = b.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ContactNotesOfficeUser_RK
                        FROM    L_ContactNotesOfficeUser
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.UserHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;



--** Load L_ContactNotesOfficeContactNote
        INSERT  INTO L_ContactNotesOfficeContactNote
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ContactNoteHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSStaging.adv.tblContactNoteStage b WITH ( NOLOCK ) ON b.ContactNote_PK = rw.ContactNote_PK
                                                              AND rw.CCi = b.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ContactNotesOfficeContactNote_RK
                        FROM    L_ContactNotesOfficeContactNote
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ContactNoteHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;

	
	
--** Load L_ContactNotesOfficeProject
        INSERT  INTO L_ContactNotesOfficeProject
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ProjectHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSStaging.adv.tblProjectStage b WITH ( NOLOCK ) ON b.Project_PK = rw.Project_PK
                                                              AND rw.CCi = b.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_ContactNotesOfficeProject_RK
                        FROM    L_ContactNotesOfficeProject
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ProjectHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;



    END;

GO
