SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/30/2016
-- Description:	Load all Link Tables from the tblIssueResponseStage table
-- =============================================
CREATE PROCEDURE [dbo].[spDV_IssueResponse_LoadLinks]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;




--**Load L_SupsectUserContactNotesOffice

        INSERT  INTO [dbo].[L_IssueResponseUserContactNotesOffice]
                ( [L_IssueResponseUserContactNotesOffice_RK] ,
                  [H_IssueResponse_RK] ,
                  [H_User_RK] ,
                  [H_ContactNotesOffice_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(c.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(d.CNI,
                                                              '')))))), 2)) ,
                        a.IssueResponseHashKey ,
                        c.UserHashKey ,
                        d.ContactNotesOfficeHashKey ,
                        b.LoadDate ,
                        b.RecordSource
                FROM    CHSStaging.adv.tblIssueResponseStage a WITH ( NOLOCK )
                        INNER JOIN CHSStaging.adv.tblIssueResponseOfficeStage b
                        WITH ( NOLOCK ) ON a.IssueResponse_PK = b.IssueResponse_PK
                        INNER JOIN CHSStaging.adv.tblUserStage c ON b.User_PK = c.User_PK
                        INNER JOIN CHSStaging.adv.tblContactNotesOfficeStage d ON b.ContactNotesOffice_PK = d.ContactNotesOffice_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(c.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(d.CNI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_IssueResponseUserContactNotesOffice_RK
                        FROM    L_IssueResponseUserContactNotesOffice
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(c.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(d.CNI,
                                                              '')))))), 2)) ,
                        a.IssueResponseHashKey ,
                        c.UserHashKey ,
                        d.ContactNotesOfficeHashKey ,
                        b.LoadDate ,
                        b.RecordSource;


       
--**LS_InvoiceInfo LOAD
INSERT INTO [dbo].[LS_IssueResponseOfficeDetail]
           ([LS_IssueResponseOfficeDetail_RK]
           ,[LoadDate]
           ,[L_IssueResponseUserContactNotesOffice_RK]
           ,[AdditionalResponse]
           ,[dtInsert]
           ,[HashDiff]
           ,[RecordSource]
)
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(d.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[AdditionalResponse],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[dtInsert],
                                                               '')))))), 2)) ,
                        b.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(c.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(d.CNI,
                                                              '')))))), 2)) ,
                       
           b.[AdditionalResponse],
           b.[dtInsert]     ,
		                UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(d.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[AdditionalResponse],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[dtInsert],
                                                               '')))))), 2))  ,

				           b.[RecordSource]
				FROM    CHSStaging.adv.tblIssueResponseStage a WITH ( NOLOCK )
                        INNER JOIN CHSStaging.adv.tblIssueResponseOfficeStage b
                        WITH ( NOLOCK ) ON a.IssueResponse_PK = b.IssueResponse_PK
                        INNER JOIN CHSStaging.adv.tblUserStage c ON b.User_PK = c.User_PK
                        INNER JOIN CHSStaging.adv.tblContactNotesOfficeStage d ON b.ContactNotesOffice_PK = d.ContactNotesOffice_PK
                      
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(d.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[AdditionalResponse],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[dtInsert],
                                                               '')))))), 2))   NOT IN (
                        SELECT  HashDiff
                        FROM    [dbo].[LS_IssueResponseOfficeDetail]
                        WHERE   [LS_IssueResponseOfficeDetail_RK] = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(d.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[AdditionalResponse],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[dtInsert],
                                                               '')))))), 2)) 
                                AND RecordEndDate IS NULL )
                        AND b.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(d.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[AdditionalResponse],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[dtInsert],
                                                               '')))))), 2)) ,
                        b.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(c.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(d.CNI,
                                                              '')))))), 2)) ,
                       
           b.[AdditionalResponse],
           b.[dtInsert]     ,
		                UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CRI,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(d.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[AdditionalResponse],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.[dtInsert],
                                                               '')))))), 2))  ,

				           b.[RecordSource];

	--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_IssueResponseOfficeDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_IssueResponseOfficeDetail z
                                  WHERE     z.[LS_IssueResponseOfficeDetail_RK] = a.[LS_IssueResponseOfficeDetail_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_IssueResponseOfficeDetail a
        WHERE   a.RecordEndDate IS NULL; 


    END;
GO
