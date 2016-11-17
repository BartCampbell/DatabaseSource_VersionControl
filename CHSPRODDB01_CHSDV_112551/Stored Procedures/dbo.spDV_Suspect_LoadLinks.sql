SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/24/2016
-- Description:	Load all Link Tables from the tblSuspectStage table
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Suspect_LoadLinks]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


--** Load L_SuspectCLIENT
        INSERT  INTO L_SuspectClient
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CCI,
                                                              '')))))), 2)) ,
                        rw.SuspectHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CCI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectClient_RK
                        FROM    L_SuspectClient
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CCI,
                                                              '')))))), 2)) ,
                        rw.SuspectHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;


		
--** Load L_SuspectProject
        INSERT  INTO L_SuspectProject
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.ProjectHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblProjectStage b WITH ( NOLOCK ) ON a.Project_PK = b.Project_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectProject_RK
                        FROM    L_SuspectProject
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.ProjectHashKey ,
                        a.LoadDate ,
                        a.RecordSource;

	 
--** Load L_SuspectProvider
        INSERT  INTO L_SuspectProvider
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.ProviderHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblProviderStage b WITH ( NOLOCK ) ON a.Provider_PK = b.Provider_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectProvider_RK
                        FROM    L_SuspectProvider
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CPI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.ProviderHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


	 
--** Load L_SuspectMember
        INSERT  INTO L_SuspectMember
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CMI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.MemberHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblMemberStage b WITH ( NOLOCK ) ON a.Member_PK = b.Member_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CMI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectMember_RK
                        FROM    L_SuspectMember
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CMI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.MemberHashKey ,
                        a.LoadDate ,
                        a.RecordSource;

	 
--** Load L_SuspectUser from ScannedUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblUserStage b WITH ( NOLOCK ) ON a.Scanned_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


	 
--** Load L_SuspectUser from CNAUSer
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblUserStage b WITH ( NOLOCK ) ON a.CNA_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


	 
--** Load L_SuspectUser from CodedUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblUserStage b WITH ( NOLOCK ) ON a.Coded_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;
	 
	 
--** Load L_SuspectUser from QAUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblUserStage b WITH ( NOLOCK ) ON a.QA_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;

						--** Load L_SuspectUser from tblSuspectChartRecLogStage
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.[adv].[tblSuspectChartRecLogStage] rw WITH ( NOLOCK )
						INNER JOIN	CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK ) ON rw.suspect_pk = a.suspect_pk
                        LEFT OUTER JOIN CHSStaging.adv.tblUserStage b WITH ( NOLOCK ) ON rw.User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource

	 --REMOVED USER
	 
--** Load L_SuspectUser from ScannedUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblUserRemovedStage b
                        WITH ( NOLOCK ) ON a.Scanned_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


	 
--** Load L_SuspectUser from CNAUSer
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblUserRemovedStage b
                        WITH ( NOLOCK ) ON a.CNA_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


	 
--** Load L_SuspectUser from CodedUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblUserRemovedStage b
                        WITH ( NOLOCK ) ON a.Coded_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;
	 
	 
--** Load L_SuspectUser from QAUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK )
                        LEFT OUTER JOIN CHSStaging.adv.tblUserRemovedStage b
                        WITH ( NOLOCK ) ON a.QA_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;



--**Load L_SupsectUserInvoiceVendor

        INSERT  INTO [dbo].[L_SuspectUserInvoiceVendor]
                ( [L_SuspectUserInvoiceVendor_RK] ,
                  [H_Suspect_RK] ,
                  [H_User_RK] ,
                  [H_InvoiceVendor_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CVI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        a.UserHashKey ,
                        a.InvoiceVendorHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblSuspectInvoiceInfoStage a WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CVI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUserInvoiceVendor_RK
                        FROM    L_SuspectUserInvoiceVendor
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CVI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        a.UserHashKey ,
                        a.InvoiceVendorHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


   --     DECLARE @sql VARCHAR(2000),	@CCI VARCHAR(50)
			--	SET @cci='112551'

   --     SET @sql = 'UPDATE  CHSStaging.[adv].[tblSuspectInvoiceInfoStage]		
			--SET     [SuspectUserInvoiceVendorHashKey] = c.[L_SuspectUserInvoiceVendor_RK]
			--	FROM    CHSStaging.[adv].[tblSuspectInvoiceInfoStage]		 a
			--	INNER JOIN  CHSDV_' + @CCI
   --         + '.[dbo].[L_SuspectUserInvoiceVendor] c 
			--		 ON ISNULL(a.SuspectHashKey,'''') = ISNULL(c.H_Suspect_RK,'''') AND ISNULL(a.UserHashKey,'''') = ISNULL(c.H_User_RK,'''') AND ISNULL(a.InvoiceVendorHashKey,'''') = ISNULL(c.H_InvoiceVendor_RK,'''');';
					 
			--	SELECT @sql						 
   --     EXEC (@sql);

        UPDATE  CHSStaging.[adv].[tblSuspectInvoiceInfoStage]
        SET     [SuspectUserInvoiceVendorHashKey] = c.[L_SuspectUserInvoiceVendor_RK]
        FROM    CHSStaging.[adv].[tblSuspectInvoiceInfoStage] a
                INNER JOIN [dbo].[L_SuspectUserInvoiceVendor] c ON ISNULL(a.SuspectHashKey,
                                                              '') = ISNULL(c.H_Suspect_RK,
                                                              '')
                                                              AND ISNULL(a.UserHashKey,
                                                              '') = ISNULL(c.H_User_RK,
                                                              '')
                                                              AND ISNULL(a.InvoiceVendorHashKey,
                                                              '') = ISNULL(c.H_InvoiceVendor_RK,
                                                              '')
															  WHERE   a.CCI = @CCI
															  ;



--**Load L_SupsectUserNote

        INSERT  INTO [dbo].[L_SuspectUserNote]
                ( [L_SuspectUserNote_RK] ,
                  [H_Suspect_RK] ,
                  [H_User_RK] ,
                  [H_NoteText_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CNI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        a.UserHashKey ,
                        a.NoteTextHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblSuspectNoteStage a WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CNI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUserNote_RK
                        FROM    L_SuspectUserNote
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CNI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        a.UserHashKey ,
                        a.NoteTextHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


  UPDATE  CHSStaging.[adv].[tblSuspectNoteStage]
        SET     [SuspectUserNoteHashKey] = c.[L_SuspectUserNote_RK]
        FROM    CHSStaging.[adv].[tblSuspectNoteStage] a
                INNER JOIN [dbo].[L_SuspectUserNote] c ON ISNULL(a.SuspectHashKey,
                                                              '') = ISNULL(c.H_Suspect_RK,
                                                              '')
                                                              AND ISNULL(a.UserHashKey,
                                                              '') = ISNULL(c.H_User_RK,
                                                              '')
                                                              AND ISNULL(a.NoteTextHashKey,
                                                              '') = ISNULL(c.H_NoteText_RK,
                                                              '')
															  WHERE   a.CCI = @CCI
															  ;


															  
--**Load L_SupsectUserScanningNotes

        INSERT  INTO [dbo].[L_SuspectUserScanningNotes]
                ( [L_SuspectUserScanningNotes_RK] ,
                  [H_Suspect_RK] ,
                  [H_User_RK] ,
                  [H_ScanningNotes_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CNI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        a.UserHashKey ,
                        a.ScanningNoteHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblSuspectScanningNotesStage a WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CNI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUserScanningNotes_RK
                        FROM    L_SuspectUserScanningNotes
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CNI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        a.UserHashKey ,
                        a.ScanningNoteHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


  UPDATE  CHSStaging.[adv].[tblSuspectScanningNotesStage]
        SET     [SuspectUserScanningNoteHashKey] = c.[L_SuspectUserScanningNotes_RK]
        FROM    CHSStaging.[adv].[tblSuspectScanningNotesStage] a
                INNER JOIN [dbo].[L_SuspectUserScanningNotes] c ON ISNULL(a.SuspectHashKey,
                                                              '') = ISNULL(c.H_Suspect_RK,
                                                              '')
                                                              AND ISNULL(a.UserHashKey,
                                                              '') = ISNULL(c.H_User_RK,
                                                              '')
                                                              AND ISNULL(a.ScanningNoteHashKey,
                                                              '') = ISNULL(c.H_ScanningNotes_RK,
                                                              '')
															 WHERE   a.CCI = @CCI
															  ;


															  --** Load L_SuspectUser from tblSuspectChartRecLogStage
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.[adv].[tblSuspectChartRecLogStage] rw WITH ( NOLOCK )
						INNER JOIN	CHSStaging.adv.tblSuspectStage a WITH ( NOLOCK ) ON rw.suspect_pk = a.suspect_pk
                        LEFT OUTER JOIN CHSStaging.adv.tblUserRemovedStage b WITH ( NOLOCK ) ON rw.User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CUI,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource


						--**LS_InvoiceInfo LOAD

        INSERT  INTO [dbo].[LS_InvoiceInfo]
                ( [LS_InvoiceInfo_RK] ,
                  [LoadDate] ,
                  [L_SuspectUserInvoiceVendor_RK] ,
                  [InvoiceNumber] ,
                  [AccountNumber] ,
                  [InvoiceAmount] ,
                  [dtInsert] ,
                  [IsApproved] ,
                  [Update_User_PK] ,
                  [dtUpdate] ,
                  [Invoice_PK] ,
                  [AmountPaid] ,
                  [Check_Transaction_Number] ,
                  [PaymentType_PK] ,
                  [InvoiceAccountNumber] ,
                  [Inv_File] ,
                  [IsPaid] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CVI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AccountNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceAmount],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsApproved],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Update_User_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtUpdate],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Invoice_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AmountPaid],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Check_Transaction_Number],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[PaymentType_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceAccountNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Inv_File],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsPaid],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        [SuspectUserInvoiceVendorHashKey] ,
                        RTRIM(LTRIM([InvoiceNumber])) ,
                        RTRIM(LTRIM([AccountNumber])) ,
                        RTRIM(LTRIM([InvoiceAmount])) ,
                        [dtInsert] ,
                        [IsApproved] ,
                        [Update_User_PK] ,
                        [dtUpdate] ,
                        [Invoice_PK] ,
                        [AmountPaid] ,
                        RTRIM(LTRIM([Check_Transaction_Number])) ,
                        [PaymentType_PK] ,
                        RTRIM(LTRIM([InvoiceAccountNumber])) ,
                        [Inv_File] ,
                        [IsPaid] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[InvoiceNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AccountNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceAmount],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsApproved],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Update_User_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtUpdate],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Invoice_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AmountPaid],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Check_Transaction_Number],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[PaymentType_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceAccountNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Inv_File],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsPaid],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblSuspectInvoiceInfoStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[InvoiceNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AccountNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceAmount],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsApproved],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Update_User_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtUpdate],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Invoice_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AmountPaid],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Check_Transaction_Number],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[PaymentType_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceAccountNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Inv_File],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsPaid],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    LS_InvoiceInfo
                        WHERE   L_SuspectUserInvoiceVendor_RK = rw.SuspectUserInvoiceVendorHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CVI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AccountNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceAmount],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsApproved],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Update_User_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtUpdate],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Invoice_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AmountPaid],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Check_Transaction_Number],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[PaymentType_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceAccountNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Inv_File],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsPaid],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        [SuspectUserInvoiceVendorHashKey] ,
                        RTRIM(LTRIM([InvoiceNumber])) ,
                        RTRIM(LTRIM([AccountNumber])) ,
                        RTRIM(LTRIM([InvoiceAmount])) ,
                        [dtInsert] ,
                        [IsApproved] ,
                        [Update_User_PK] ,
                        [dtUpdate] ,
                        [Invoice_PK] ,
                        [AmountPaid] ,
                        RTRIM(LTRIM([Check_Transaction_Number])) ,
                        [PaymentType_PK] ,
                        RTRIM(LTRIM([InvoiceAccountNumber])) ,
                        [Inv_File] ,
                        [IsPaid] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[InvoiceNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AccountNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceAmount],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsApproved],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Update_User_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtUpdate],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Invoice_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AmountPaid],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Check_Transaction_Number],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[PaymentType_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[InvoiceAccountNumber],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Inv_File],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsPaid],
                                                              '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_InvoiceInfo
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_InvoiceInfo z
                                  WHERE     z.[LS_InvoiceInfo_RK] = a.[LS_InvoiceInfo_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_InvoiceInfo a
        WHERE   a.RecordEndDate IS NULL; 





		--**LS_SuspectNote LOAD

        INSERT  INTO [dbo].[LS_SuspectNote]
                ( [LS_SuspectNote_RK] ,
                  [LoadDate] ,
                  [L_SuspectUserNote_RK] ,
                  [Coded_Date] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        [SuspectUserNoteHashKey] ,
                        rw.[Coded_Date] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblSuspectNoteStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    [LS_SuspectNote]
                        WHERE   [L_SuspectUserNote_RK] = rw.[SuspectUserNoteHashKey]
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        [SuspectUserNoteHashKey] ,
                        rw.[Coded_Date] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
                                                              '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_SuspectNote
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_SuspectNote z
                                  WHERE     z.LS_SuspectNote_RK = a.LS_SuspectNote_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_SuspectNote a
        WHERE   a.RecordEndDate IS NULL; 



		
		--**LS_SuspectScanningNote LOAD

		
        INSERT  INTO [dbo].[LS_SuspectScanningNote]
                ( [LS_SuspectScanningNote_RK] ,
                  [LoadDate] ,
                  [L_SuspectUserScanningNotes_RK] ,
                  [dtInsert] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        [SuspectUserScanningNoteHashKey] ,
                        rw.[dtInsert] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblSuspectScanningNotesStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    [LS_SuspectScanningNote]
                        WHERE   [L_SuspectUserScanningNotes_RK] = rw.[SuspectUserScanningNoteHashKey]
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        [SuspectUserScanningNoteHashKey] ,
                        rw.[dtInsert] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_SuspectScanningNote
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_SuspectScanningNote z
                                  WHERE     z.LS_SuspectScanningNote_RK = a.LS_SuspectScanningNote_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_SuspectScanningNote a
        WHERE   a.RecordEndDate IS NULL; 


----**Load L_SupsectUserDocument

--        INSERT  INTO [dbo].[L_SuspectUserDocument]
--                ( [L_SuspectUserDocument_RK] ,
--                  [H_Suspect_RK] ,
--                  [H_User_RK] ,
--                  [H_DocumentType_RK] ,
--                  [LoadDate] ,
--                  [RecordSource]
--                )
--                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
--                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CUI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CDI,
--                                                              '')))))), 2)) ,
--                        a.SuspectHashKey ,
--                        a.UserHashKey ,
--                        a.DocumentTypeHashKey ,
--                        a.LoadDate ,
--                        a.RecordSource
--                FROM    CHSStaging.adv.tblScannedDataStage a WITH ( NOLOCK )
--                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
--                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CUI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CDI,
--                                                              '')))))), 2)) NOT IN (
--                        SELECT  L_SuspectUserDocument_RK
--                        FROM    L_SuspectUserDocument
--                        WHERE   RecordEndDate IS NULL )
--                        AND a.CCI = @CCI
--                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
--                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CUI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CDI,
--                                                              '')))))), 2)) ,
--                        a.SuspectHashKey ,
--                        a.UserHashKey ,
--                        a.DocumentTypeHashKey ,
--                        a.LoadDate ,
--                        a.RecordSource;


--  UPDATE  CHSStaging.[adv].[tblScannedDataStage]
--        SET     [SuspectUserDocumentHashKey] = c.[L_SuspectUserDocument_RK]
--        FROM    CHSStaging.[adv].[tblScannedDataStage] a
--                INNER JOIN [dbo].[L_SuspectUserDocument] c ON ISNULL(a.SuspectHashKey,
--                                                              '') = ISNULL(c.H_Suspect_RK,
--                                                              '')
--                                                              AND ISNULL(a.UserHashKey,
--                                                              '') = ISNULL(c.H_User_RK,
--                                                              '')
--                                                              AND ISNULL(a.DocumentTypeHashKey,
--                                                              '') = ISNULL(c.H_DocumentType_RK,
--                                                              '')
--															 WHERE   a.CCI = @CCI
--															  ;

    END;
GO
