SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
-- ============================================= 
-- Author:		Paul Johnson 
-- Create date: 08/19/2016 
--Updated 09/21/2016 Linked tables changed to CHSDV PJ 
--Updated 09/26/2016 Added record end date cleanup code PJ 
--Uddate 09/27/2016 Adding ContactPerson and LoadDate to hash PJ 
--Update 10/04/2016 Replacing RecordEndDate and LoadDate with Link Satellites PJ 
--Updated 02/07/2017 Adding RecordSource to joins PJ 
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) , 
                        a.ProviderOfficeHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) , 
                        a.LoadDate , 
                        a.RecordSource , 
                        NULL 
                FROM    [CHSStaging].[adv].[tblProviderOfficeWCStage] a 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderOfficeLocation_RK 
                        FROM    L_ProviderOfficeLocation 
                        WHERE   RecordEndDate IS NULL ) 
                        AND a.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) , 
                        a.ProviderOfficeHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) , 
                        a.LoadDate , 
                        a.RecordSource; 
 
 
--*** INSERT INTO LS_ProviderOfficeLOCATION 
 
        INSERT  INTO [dbo].[LS_ProviderOfficeLocation] 
                ( [LS_ProviderOfficeLocation_RK] , 
                  [LoadDate] , 
                  [L_ProviderOfficeLocation_RK] , 
                  [H_ProviderOffice_RK] , 
                  [H_Location_RK] , 
                  [Active] , 
                  [HashDiff] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        a.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) , 
                        a.ProviderOfficeHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) , 
                        'Y' , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), ''))), ':Y'))), 2)) , 
                        a.RecordSource 
                FROM    [CHSStaging].[adv].[tblProviderOfficeWCStage] a 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), ''))), ':Y'))), 2)) NOT IN ( 
                        SELECT  HashDiff 
                        FROM    LS_ProviderOfficeLocation 
                        WHERE   RecordEndDate IS NULL ) 
                        AND a.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        a.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) , 
                        a.ProviderOfficeHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), '')))))), 2)) , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR), ''))), ':Y'))), 2)) , 
                        a.RecordSource;  
 
 
 
		--RECORD END DATE CLEANUP 
        UPDATE  dbo.LS_ProviderOfficeLocation 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.LS_ProviderOfficeLocation z 
                                  WHERE     z.[H_ProviderOffice_RK] = a.[H_ProviderOffice_RK] 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.LS_ProviderOfficeLocation a 
        WHERE   a.RecordEndDate IS NULL;  
 
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) , 
                        a.ProviderOfficeHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) , 
                        a.LoadDate , 
                        a.RecordSource , 
                        NULL 
                FROM    [CHSStaging].[adv].[tblProviderOfficeWCStage] a 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderOfficeContact_RK 
                        FROM    L_ProviderOfficeContact 
                        WHERE   RecordEndDate IS NULL ) 
                        AND a.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) , 
                        a.ProviderOfficeHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) , 
                        a.LoadDate , 
                        a.RecordSource; 
 
 
--*** INSERT INTO LS_ProviderOfficeCONTACT 
 
        INSERT  INTO [dbo].[LS_ProviderOfficeContact] 
                ( [LS_ProviderOfficeContact_RK] , 
                  [LoadDate] , 
                  [L_ProviderOfficeContact_RK] , 
                  [H_ProviderOffice_RK] , 
                  [H_Contact_RK] , 
                  [Active] , 
                  [HashDiff] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        a.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) , 
                        a.ProviderOfficeHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) , 
                        'Y' , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, ''))), ':Y'))), 2)) , 
                        a.RecordSource 
                FROM    [CHSStaging].[adv].[tblProviderOfficeWCStage] a 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, ''))), ':Y'))), 2)) NOT IN ( 
                        SELECT  HashDiff 
                        FROM    LS_ProviderOfficeContact 
                        WHERE   RecordEndDate IS NULL ) 
                        AND a.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(a.Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        a.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) , 
                        a.ProviderOfficeHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, '')))))), 2)) , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContactPerson, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ContactNumber, ''))), ':', RTRIM(LTRIM(COALESCE(a.FaxNumber, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Email_Address, ''))), ':Y'))), 2)) , 
                        a.RecordSource;  
 
 
 
--RECORD END DATE CLEANUP 
        UPDATE  dbo.LS_ProviderOfficeContact 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.LS_ProviderOfficeContact z 
                                  WHERE     z.[H_ProviderOffice_RK] = a.[H_ProviderOffice_RK] 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.LS_ProviderOfficeContact a 
        WHERE   a.RecordEndDate IS NULL;  
 
 
 
--*** INSERT INTO L_ProviderMasterOffice 
        INSERT  INTO [dbo].[L_ProviderMasterOffice] 
                ( [L_ProviderMasterOffice_RK] , 
                  [H_Provider_RK] , 
                  [H_ProviderOffice_RK] , 
                  [LoadDate] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) , 
                        a.ProviderMasterHashKey , 
                        b.ProviderOfficeHashKey , 
                        p.LoadDate , 
                        p.RecordSource 
                FROM    [CHSStaging].[adv].[tblProviderStage] p WITH ( NOLOCK ) 
                        INNER JOIN [CHSStaging].[adv].[tblProviderMasterStage] a WITH ( NOLOCK ) ON p.ProviderMaster_PK = a.ProviderMaster_PK 
                                                                                                    AND a.CCI = p.CCI AND a.RecordSource = p.RecordSource 
                        INNER JOIN CHSDV.dbo.R_ProviderOffice b WITH ( NOLOCK ) ON b.ClientProviderOfficeID = p.ProviderOffice_PK 
                                                                                   AND b.ClientID = p.CCI AND b.RecordSource = p.RecordSource 
 
 
	                   --INNER JOIN [CHSStaging].[adv].[tblProviderMasterStage] b ON a.ProviderMaster_PK = b.ProviderMaster_PK AND b.CCI = a.CCI 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderMasterOffice_RK 
                        FROM    L_ProviderMasterOffice 
                        WHERE   RecordEndDate IS NULL ) 
                        AND p.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) , 
                        a.ProviderMasterHashKey , 
                        b.ProviderOfficeHashKey , 
                        p.LoadDate , 
                        p.RecordSource;  
 
 
						 
        INSERT  INTO [dbo].[L_ProviderMasterOffice] 
                ( [L_ProviderMasterOffice_RK] , 
                  [H_Provider_RK] , 
                  [H_ProviderOffice_RK] , 
                  [LoadDate] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(h.Provider_BK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) , 
                        h.H_Provider_RK , 
                        b.ProviderOfficeHashKey , 
                        p.LoadDate , 
                        p.RecordSource 
                FROM    [CHSStaging].[adv].[tblProviderStage] p WITH ( NOLOCK ) 
                        INNER JOIN dbo.S_ProviderMasterDemo a WITH ( NOLOCK ) ON p.ProviderMaster_PK = a.ProviderMaster_PK AND a.RecordEndDate IS NULL AND a.RecordSource = p.RecordSource 
                        INNER JOIN dbo.H_Provider h ON h.H_Provider_RK = a.H_Provider_RK  
                        INNER JOIN CHSDV.dbo.R_ProviderOffice b WITH ( NOLOCK ) ON b.ClientProviderOfficeID = p.ProviderOffice_PK 
                                                                                   AND b.ClientID = p.CCI AND b.RecordSource = p.RecordSource 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(h.Provider_BK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderMasterOffice_RK 
                        FROM    L_ProviderMasterOffice 
                        WHERE   RecordEndDate IS NULL ) 
                        AND p.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(h.Provider_BK, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) , 
                        h.H_Provider_RK , 
                        b.ProviderOfficeHashKey , 
                        p.LoadDate , 
                        p.RecordSource; 
 
--*** INSERT INTO LS_ProviderMasterOffice 
 
        INSERT  INTO [dbo].[LS_ProviderMasterOffice] 
                ( [LS_ProviderMasterOffice_RK] , 
                  [LoadDate] , 
                  [L_ProviderMasterOffice_RK] , 
                  [Provider_PK] , 
                  [ProviderOffice_PK] , 
                  [ProviderMaster_PK] , 
                  [HashDiff] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Provider_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.ClientProviderOfficeID, '')))))), 2)) , 
                        p.[LoadDate] , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) , 
                        p.[Provider_PK] , 
                        b.ClientProviderOfficeID , 
                        a.ProviderMaster_PK , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Provider_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.ClientProviderOfficeID, '')))))), 2)) , 
                        p.[RecordSource] 
                FROM    [CHSStaging].[adv].[tblProviderStage] p WITH ( NOLOCK ) 
                        INNER JOIN [CHSStaging].[adv].[tblProviderMasterStage] a WITH ( NOLOCK ) ON p.ProviderMaster_PK = a.ProviderMaster_PK 
                                                                                                    AND a.CCI = p.CCI AND a.RecordSource = p.RecordSource 
                        INNER JOIN CHSDV.dbo.R_ProviderOffice b WITH ( NOLOCK ) ON b.ClientProviderOfficeID = p.ProviderOffice_PK 
                                                                                   AND b.ClientID = p.CCI AND b.RecordSource = p.RecordSource 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Provider_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.ClientProviderOfficeID, '')))))), 2)) NOT IN ( 
                        SELECT  HashDiff 
                        FROM    LS_ProviderMasterOffice 
                        WHERE   RecordEndDate IS NULL ) 
                        AND p.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Provider_PK, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(b.ClientProviderOfficeID, '')))))), 2)) , 
                        p.[LoadDate] , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) , 
                        p.[Provider_PK] , 
                        b.ClientProviderOfficeID , 
                        a.ProviderMaster_PK , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Provider_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.ClientProviderOfficeID, '')))))), 2)) , 
                        p.[RecordSource]; 
 
        INSERT  INTO [dbo].[LS_ProviderMasterOffice] 
                ( [LS_ProviderMasterOffice_RK] , 
                  [LoadDate] , 
                  [L_ProviderMasterOffice_RK] , 
                  [Provider_PK] , 
                  [ProviderOffice_PK] , 
                  [ProviderMaster_PK] , 
                  [HashDiff] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Provider_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.ClientProviderOfficeID, '')))))), 2)) , 
                        p.[LoadDate] , 
                      UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(h.Provider_BK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) , 
                        p.[Provider_PK] , 
                        b.ClientProviderOfficeID , 
                        a.ProviderMaster_PK , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Provider_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.ClientProviderOfficeID, '')))))), 2)) , 
                        p.[RecordSource] 
                FROM    [CHSStaging].[adv].[tblProviderStage] p WITH ( NOLOCK ) 
                        INNER JOIN dbo.S_ProviderMasterDemo a WITH ( NOLOCK ) ON p.ProviderMaster_PK = a.ProviderMaster_PK AND a.RecordEndDate IS NULL AND a.RecordSource = p.RecordSource 
                        INNER JOIN dbo.H_Provider h ON h.H_Provider_RK = a.H_Provider_RK 
                        INNER JOIN CHSDV.dbo.R_ProviderOffice b WITH ( NOLOCK ) ON b.ClientProviderOfficeID = p.ProviderOffice_PK AND b.ClientID = p.CCI AND b.RecordSource = p.RecordSource 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Provider_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.ClientProviderOfficeID, '')))))), 2)) NOT IN ( 
                        SELECT  HashDiff 
                        FROM    LS_ProviderMasterOffice 
                        WHERE   RecordEndDate IS NULL ) 
                        AND p.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Provider_PK, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(b.ClientProviderOfficeID, '')))))), 2)) , 
                        p.[LoadDate] , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(h.Provider_BK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) , 
                        p.[Provider_PK] , 
                        b.ClientProviderOfficeID , 
                        a.ProviderMaster_PK , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Provider_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.ClientProviderOfficeID, '')))))), 2)) , 
                        p.[RecordSource]; 
                                                           
--RECORD END DATE CLEANUP 
        UPDATE  dbo.LS_ProviderMasterOffice 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.LS_ProviderMasterOffice z 
                                  WHERE     z.Provider_PK = a.Provider_PK 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.LS_ProviderMasterOffice a 
        WHERE   a.RecordEndDate IS NULL;  
 
 
 
 
----*** INSERT INTO L_ProviderProviderOffice 
--        INSERT  INTO [dbo].[L_ProviderProviderOffice] 
--                ( [L_ProviderProviderOffice_RK] , 
--                  [H_Provider_RK] , 
--                  [H_ProviderOffice_RK] , 
--                  [LoadDate] , 
--                  [RecordSource] 
--                ) 
--                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
--                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
--                                                                       RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) , 
--                        a.ProviderHashKey , 
--                        b.ProviderOfficeHashKey , 
--                        a.LoadDate , 
--                        a.RecordSource 
--                FROM    [CHSStaging].[adv].[tblProviderStage] a WITH ( NOLOCK ) 
--                        INNER JOIN CHSDV.dbo.R_ProviderOffice b WITH ( NOLOCK ) ON b.ClientProviderOfficeID = a.ProviderOffice_PK 
--                                                                                   AND b.ClientID = a.CCI 
--                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
--                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
--                                                                       RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) NOT IN ( 
--                        SELECT  L_ProviderProviderOffice_RK 
--                        FROM    L_ProviderProviderOffice 
--                        WHERE   RecordEndDate IS NULL ) 
--                        AND a.CCI = @CCI 
--                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
--                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
--                                                                        RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, '')))))), 2)) , 
--                        a.ProviderHashKey , 
--                        b.ProviderOfficeHashKey , 
--                        a.LoadDate , 
--                        a.RecordSource;  
 
 
----RECORD END DATE CLEANUP 
--        UPDATE  dbo.L_ProviderProviderOffice 
--        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
--                                  FROM      dbo.L_ProviderProviderOffice z 
--                                  WHERE     z.[H_Provider_RK] = a.[H_Provider_RK] 
--                                            AND z.LoadDate > a.LoadDate 
--                                ) 
--        FROM    dbo.L_ProviderProviderOffice a 
--        WHERE   a.RecordEndDate IS NULL;  
 
 
 
						 
--*** INSERT INTO L_ProviderProviderOfficeSchedule 
        INSERT  INTO [dbo].[L_ProviderOfficeProviderOfficeSchedule] 
                ( [L_ProviderOfficeProviderOfficeSchedule_RK] , 
                  [H_ProviderOffice_RK] , 
                  [H_ProviderOfficeSchedule_RK] , 
                  [LoadDate] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderOfficeID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CPI, '')))))), 2)) , 
                        a.ProviderOfficeHashKey , 
                        b.ProviderOfficeScheduleHashKey , 
                        b.LoadDate , 
                        b.RecordSource 
                FROM    CHSDV.dbo.R_ProviderOffice a WITH ( NOLOCK ) 
                        INNER JOIN [CHSStaging].[adv].[tblProviderOfficeScheduleStage] b ON a.ClientProviderOfficeID = b.ProviderOffice_PK 
                                                                                            AND b.CCI = a.ClientID AND b.RecordSource = a.RecordSource 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderOfficeID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CPI, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderOfficeProviderOfficeSchedule_RK 
                        FROM    L_ProviderOfficeProviderOfficeSchedule 
                        WHERE   RecordEndDate IS NULL ) 
                        AND b.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderOfficeID, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(b.CPI, '')))))), 2)) , 
                        a.ProviderOfficeHashKey , 
                        b.ProviderOfficeScheduleHashKey , 
                        b.LoadDate , 
                        b.RecordSource; 
						 
						 
						 
--*** INSERT INTO LS_ProviderProviderOfficeSchedule 
 
        INSERT  INTO [dbo].[LS_ProviderOfficeProviderOfficeSchedule] 
                ( [LS_ProviderOfficeProviderOfficeSchedule_RK] , 
                  [LoadDate] , 
                  [L_ProviderOfficeProviderOfficeSchedule_RK] , 
                  [H_ProviderOfficeSchedule_RK] , 
                  [H_ProviderOffice_RK] , 
                  [Active] , 
                  [HashDiff] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderOfficeID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        b.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderOfficeID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CPI, '')))))), 2)) , 
                        b.ProviderOfficeScheduleHashKey , 
                        a.ProviderOfficeHashKey , 
                        'Y' , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderOfficeID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CPI, ''))), ':Y'))), 2)) , 
                        b.RecordSource 
                FROM    CHSDV.dbo.R_ProviderOffice a WITH ( NOLOCK ) 
                        INNER JOIN [CHSStaging].[adv].[tblProviderOfficeScheduleStage] b ON a.ClientProviderOfficeID = b.ProviderOffice_PK AND b.RecordSource = a.RecordSource 
                                                                                            AND b.CCI = a.ClientID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderOfficeID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CPI, ''))), ':Y'))), 2)) NOT IN ( 
                        SELECT  HashDiff 
                        FROM    LS_ProviderOfficeProviderOfficeSchedule 
                        WHERE   RecordEndDate IS NULL ) 
                        AND b.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderOfficeID, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(b.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        b.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderOfficeID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CPI, '')))))), 2)) , 
                        b.ProviderOfficeScheduleHashKey , 
                        a.ProviderOfficeHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderOfficeID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CPI, ''))), ':Y'))), 2)) , 
                        b.RecordSource; 
 
 
 
--RECORD END DATE CLEANUP 
        UPDATE  dbo.LS_ProviderOfficeProviderOfficeSchedule 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.LS_ProviderOfficeProviderOfficeSchedule z 
                                  WHERE     z.[H_ProviderOfficeSchedule_RK] = a.[H_ProviderOfficeSchedule_RK] 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.LS_ProviderOfficeProviderOfficeSchedule a 
        WHERE   a.RecordEndDate IS NULL;  
 
 
						 
--*** INSERT INTO L_ProviderOfficeScheduleUser 
 
        INSERT  INTO [dbo].[L_ProviderOfficeScheduleUser] 
                ( [L_ProviderOfficeScheduleUser_RK] , 
                  [H_ProviderOfficeSchedule_RK] , 
                  [H_User_RK] , 
                  [LoadDate] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.UserHashKey , 
                        a.LoadDate , 
                        a.RecordSource 
                FROM    [CHSStaging].[adv].[tblProviderOfficeScheduleStage] a WITH ( NOLOCK ) 
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON b.ClientUserID = a.LastUpdated_User_PK 
                                                                                AND b.ClientID = a.CCI AND b.RecordSource = a.RecordSource 
			 --        INNER JOIN [CHSStaging].[adv].[tblUserWCStage] b ON a.LastUpdated_User_PK = b.User_PK AND b.CCI = a.CCI 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderOfficeScheduleUser_RK 
                        FROM    L_ProviderOfficeScheduleUser 
                        WHERE   RecordEndDate IS NULL ) 
                        AND a.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.UserHashKey , 
                        a.LoadDate , 
                        a.RecordSource; 
 
--*** INSERT INTO LS_ProviderOfficeScheduleUser 
        INSERT  INTO [dbo].[LS_ProviderOfficeScheduleUser] 
                ( [LS_ProviderOfficeScheduleUser_RK] , 
                  [LoadDate] , 
                  [L_ProviderOfficeScheduleUser_RK] , 
                  [H_ProviderOfficeSchedule_RK] , 
                  [H_User_RK] , 
                  [Active] , 
                  [HashDiff] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        a.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.UserHashKey , 
                        'Y' , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), 
                                                                       ':Y'))), 2)) , 
                        a.RecordSource 
                FROM    [CHSStaging].[adv].[tblProviderOfficeScheduleStage] a WITH ( NOLOCK ) 
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON b.ClientUserID = a.LastUpdated_User_PK 
                                                                                AND b.ClientID = a.CCI AND b.RecordSource = a.RecordSource 
			 --        INNER JOIN [CHSStaging].[adv].[tblUserWCStage] b ON a.LastUpdated_User_PK = b.User_PK AND b.CCI = a.CCI 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), 
                                                                       ':Y'))), 2)) NOT IN ( SELECT HashDiff 
                                                                                             FROM   LS_ProviderOfficeScheduleUser 
                                                                                             WHERE  RecordEndDate IS NULL ) 
                        AND a.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), 
                                                                        ':', RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        a.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.UserHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), 
                                                                       ':Y'))), 2)) , 
                        a.RecordSource; 
						 
--RECORD END DATE CLEANUP 
        UPDATE  dbo.LS_ProviderOfficeScheduleUser 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.LS_ProviderOfficeScheduleUser z 
                                  WHERE     z.[H_ProviderOfficeSchedule_RK] = a.[H_ProviderOfficeSchedule_RK] 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.LS_ProviderOfficeScheduleUser a 
        WHERE   a.RecordEndDate IS NULL;  
 
						 
--*** INSERT INTO L_ProviderOfficeScheduleProject 
 
        INSERT  INTO [dbo].[L_ProviderOfficeScheduleProject] 
                ( [L_ProviderOfficeScheduleProject_RK] , 
                  [H_ProviderOfficeSchedule_RK] , 
                  [H_Project_RK] , 
                  [LoadDate] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.ProjectHashKey , 
                        a.LoadDate , 
                        a.RecordSource 
                FROM    [CHSStaging].[adv].[tblProviderOfficeScheduleStage] a WITH ( NOLOCK ) 
                        INNER JOIN CHSDV.dbo.R_AdvanceProject b WITH ( NOLOCK ) ON b.ClientProjectID = a.Project_PK 
                                                                                   AND b.ClientID = a.CCI AND b.RecordSource = a.RecordSource 
                        --INNER JOIN [CHSStaging].[adv].[tblProjectStage] b ON a.Project_PK = b.Project_PK AND b.CCI = a.CCI 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderOfficeScheduleProject_RK 
                        FROM    L_ProviderOfficeScheduleProject 
                        WHERE   RecordEndDate IS NULL ) 
                        AND a.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.ProjectHashKey , 
                        a.LoadDate , 
                        a.RecordSource; 
 
						 
--*** INSERT INTO LS_ProviderOfficeScheduleProject 
 
        INSERT  INTO [dbo].[LS_ProviderOfficeScheduleProject] 
                ( [LS_ProviderOfficeScheduleProject_RK] , 
                  [LoadDate] , 
                  [L_ProviderOfficeScheduleProject_RK] , 
                  [H_ProviderOfficeSchedule_RK] , 
                  [H_Project_RK] , 
                  [Active] , 
                  [HashDiff] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), 
                                                                       ':', RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        a.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.ProjectHashKey , 
                        'Y' , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), 
                                                                       ':Y'))), 2)) , 
                        a.RecordSource 
                FROM    [CHSStaging].[adv].[tblProviderOfficeScheduleStage] a WITH ( NOLOCK ) 
                        INNER JOIN CHSDV.dbo.R_AdvanceProject b WITH ( NOLOCK ) ON b.ClientProjectID = a.Project_PK 
                                                                                   AND b.ClientID = a.CCI AND b.RecordSource = a.RecordSource 
                        --INNER JOIN [CHSStaging].[adv].[tblProjectStage] b ON a.Project_PK = b.Project_PK AND b.CCI = a.CCI 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), 
                                                                       ':Y'))), 2)) NOT IN ( SELECT HashDiff 
                                                                                             FROM   LS_ProviderOfficeScheduleProject 
                                                                                             WHERE  RecordEndDate IS NULL ) 
                        AND a.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), 
                                                                        ':', RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        a.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.ProjectHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), 
                                                                       ':Y'))), 2)) , 
                        a.RecordSource; 
 
--RECORD END DATE CLEANUP 
        UPDATE  dbo.LS_ProviderOfficeScheduleProject 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.LS_ProviderOfficeScheduleProject z 
                                  WHERE     z.[H_ProviderOfficeSchedule_RK] = a.[H_ProviderOfficeSchedule_RK] 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.LS_ProviderOfficeScheduleProject a 
        WHERE   a.RecordEndDate IS NULL;  
 
						 
--*** INSERT INTO L_ProviderOfficeScheduleType 
 
        INSERT  INTO [dbo].[L_ProviderOfficeScheduleScheduleType] 
                ( [L_ProviderOfficeScheduleScheduleType_RK] , 
                  [H_ProviderOfficeSchedule_RK] , 
                  [H_ScheduleType_RK] , 
                  [LoadDate] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriScheduleTypeID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.ScheduleTypeHashKey , 
                        a.LoadDate , 
                        a.RecordSource 
                FROM    [CHSStaging].[adv].[tblProviderOfficeScheduleStage] a WITH ( NOLOCK ) 
                        INNER JOIN CHSDV.dbo.R_AdvanceScheduleType b WITH ( NOLOCK ) ON b.ClientScheduleTypeID = a.sch_type 
                                                                                        AND a.CCI = b.ClientID  
                --        INNER JOIN [CHSStaging].[adv].[tblScheduleTypeStage] b ON a.sch_type = b.ScheduleType_PK                                                              AND b.CCI = a.CCI 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriScheduleTypeID, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderOfficeScheduleScheduleType_RK 
                        FROM    L_ProviderOfficeScheduleScheduleType 
                        WHERE   RecordEndDate IS NULL ) 
                        AND a.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(b.CentauriScheduleTypeID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.ScheduleTypeHashKey , 
                        a.LoadDate , 
                        a.RecordSource; 
 
										 
--*** INSERT INTO LS_ProviderOfficeScheduleType 
        INSERT  INTO [dbo].[LS_ProviderOfficeScheduleScheduleType] 
                ( [LS_ProviderOfficeScheduleScheduleType_RK] , 
                  [LoadDate] , 
                  [L_ProviderOfficeScheduleScheduleType_RK] , 
                  [H_ProviderOfficeSchedule_RK] , 
                  [H_ScheduleType_RK] , 
                  [Active] , 
                  [HashDiff] , 
                  [RecordSource] 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriScheduleTypeID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        a.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriScheduleTypeID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.ScheduleTypeHashKey , 
                        'Y' , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriScheduleTypeID, ''))), ':Y'))), 2)) , 
                        a.RecordSource 
                FROM    [CHSStaging].[adv].[tblProviderOfficeScheduleStage] a WITH ( NOLOCK ) 
                        INNER JOIN CHSDV.dbo.R_AdvanceScheduleType b WITH ( NOLOCK ) ON b.ClientScheduleTypeID = a.sch_type 
                                                                                        AND a.CCI = b.ClientID  
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriScheduleTypeID, ''))), ':Y'))), 2)) NOT IN ( 
                        SELECT  HashDiff 
                        FROM    LS_ProviderOfficeScheduleScheduleType 
                        WHERE   RecordEndDate IS NULL ) 
                        AND a.CCI = @CCI 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(b.CentauriScheduleTypeID, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) , 
                        a.LoadDate , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriScheduleTypeID, '')))))), 2)) , 
                        a.ProviderOfficeScheduleHashKey , 
                        b.ScheduleTypeHashKey , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CPI, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriScheduleTypeID, ''))), ':Y'))), 2)) , 
                        a.RecordSource; 
 
--RECORD END DATE CLEANUP 
        UPDATE  dbo.LS_ProviderOfficeScheduleScheduleType 
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate)) 
                                  FROM      dbo.LS_ProviderOfficeScheduleScheduleType z 
                                  WHERE     z.[H_ProviderOfficeSchedule_RK] = a.[H_ProviderOfficeSchedule_RK] 
                                            AND z.LoadDate > a.LoadDate 
                                ) 
        FROM    dbo.LS_ProviderOfficeScheduleScheduleType a 
        WHERE   a.RecordEndDate IS NULL;  
 
 
 
    END; 
 
 
GO
