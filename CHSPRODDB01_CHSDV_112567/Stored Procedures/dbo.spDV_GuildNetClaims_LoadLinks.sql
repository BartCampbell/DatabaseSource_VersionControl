SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
 
-- ============================================= 
-- Author:		Paul Johnson 
  
-- Create date: 01/25/2017 
 -- Description:	Load all Link Tables for GuildNet 
-- ============================================= 
CREATE PROCEDURE [dbo].[spDV_GuildNetClaims_LoadLinks] 
AS 
    BEGIN 
        SET NOCOUNT ON; 
	 
--*LOAD L_ProviderPharmacyClaim 
 
        INSERT  INTO dbo.L_ProviderPharmacyClaim 
                ( L_ProviderPharmacyClaim_RK , 
                  H_Provider_RK , 
                  H_PharmacyClaim_RK , 
                  LoadDate , 
                  RecordSource , 
                  RecordEndDate 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) , 
                        p.H_Provider_RK , 
                        r.GNPharmacyClaimHashKey , 
                        rw.LoadDate , 
                        rw.FileName , 
                        NULL 
                FROM    CHSStaging.dbo.GuildNet_GNESIBatchPayDet_PharmacyClaim rw 
                        INNER JOIN dbo.H_Provider p ON rw.CentauriProviderID = p.Provider_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriID = r.CentauriPharmacyClaimID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderPharmacyClaim_RK 
                        FROM    L_ProviderPharmacyClaim 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) , 
                        p.H_Provider_RK , 
                        r.GNPharmacyClaimHashKey , 
                        rw.LoadDate , 
                        rw.FileName; 
 
--Load history for L_ProviderPharmacyClaim 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_ProviderPharmacyClaim' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_ProviderPharmacyClaim', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_ProviderPharmacyClaim' 
                        ) , 
                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) , 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = rw.FileName  COLLATE Compatibility_52_409_30003 
                        ) 
                 FROM    CHSStaging.dbo.GuildNet_GNESIBatchPayDet_PharmacyClaim rw 
                        INNER JOIN dbo.H_Provider p ON rw.CentauriProviderID = p.Provider_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriID = r.CentauriPharmacyClaimID 
 
 
--*LOAD L_MemberPharmacyClaim 
 
        INSERT  INTO dbo.L_MemberPharmacyClaim 
                ( L_MemberPharmacyClaim_RK , 
                  H_Member_RK , 
                  H_PharmacyClaim_RK , 
                  LoadDate , 
                  RecordSource , 
                  RecordEndDate 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) , 
                        b.H_Member_RK , 
                        r.GNPharmacyClaimHashKey , 
                        rw.LoadDate , 
                        rw.FileName , 
                        NULL 
                FROM    CHSStaging.dbo.GuildNet_GNESIBatchPayDet_PharmacyClaim rw 
                        INNER JOIN dbo.H_Member b ON rw.CentauriMemberID = b.Member_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriID = r.CentauriPharmacyClaimID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) NOT IN ( 
                        SELECT  L_MemberPharmacyClaim_RK 
                        FROM    L_MemberPharmacyClaim 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) , 
                        b.H_Member_RK , 
                        r.GNPharmacyClaimHashKey , 
                        rw.LoadDate , 
                        rw.FileName; 
 
 
--Load history for  L_MemberPharmacyClaim 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_MemberPharmacyClaim' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_MemberPharmacyClaim', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_MemberPharmacyClaim' 
                        ) , 
                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) , 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = rw.FileName  COLLATE Compatibility_52_409_30003 
                        ) 
               FROM    CHSStaging.dbo.GuildNet_GNESIBatchPayDet_PharmacyClaim rw 
                        INNER JOIN dbo.H_Member b ON rw.CentauriMemberID = b.Member_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriID = r.CentauriPharmacyClaimID 
 
 
--*LOAD L_PharmacyPharmacyClaim 
 
        INSERT  INTO dbo.L_PharmacyPharmacyClaim 
                ( L_PharmacyPharmacyClaim_RK , 
                  H_Pharmacy_RK , 
                  H_PharmacyClaim_RK , 
                  LoadDate , 
                  RecordSource , 
                  RecordEndDate 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) , 
                        H_Pharmacy_RK , 
                        r.GNPharmacyClaimHashKey , 
                        rw.LoadDate , 
                        rw.FileName , 
                        NULL 
                FROM    CHSStaging.dbo.GuildNet_GNESIBatchPayDet_PharmacyClaim rw 
                        INNER JOIN dbo.H_Pharmacy p ON rw.PharamcyCode = p.ClientPharmacyID 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriID = r.CentauriPharmacyClaimID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) NOT IN ( 
                        SELECT  L_PharmacyPharmacyClaim_RK 
                        FROM    L_PharmacyPharmacyClaim 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) , 
                        H_Pharmacy_RK , 
                        r.GNPharmacyClaimHashKey , 
                        rw.LoadDate , 
                        rw.FileName; 
 
 
 
--Load history for  L_PharmacyPharmacyClaim 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_PharmacyPharmacyClaim' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_PharmacyPharmacyClaim', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_PharmacyPharmacyClaim' 
                        ) , 
                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CentauriID, '')))))), 2)) , 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = rw.FileName  COLLATE Compatibility_52_409_30003 
                        ) 
               FROM    CHSStaging.dbo.GuildNet_GNESIBatchPayDet_PharmacyClaim rw 
                        INNER JOIN dbo.H_Pharmacy p ON rw.PharamcyCode = p.ClientPharmacyID 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriID = r.CentauriPharmacyClaimID 
 
 
 
--*LOAD L_ProviderClaims 
 
        INSERT  INTO dbo.L_ProviderClaims 
                ( L_ProviderClaims_RK , 
                  H_Provider_RK , 
                  H_Claims_RK , 
                  LoadDate , 
                  RecordSource , 
                  RecordEndDate 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimsID, '')))))), 2)) , 
                        p.H_Provider_RK , 
                        r.ClaimDataHashKey , 
                        GETDATE() , 
                        'GNClaims_160807' , 
                        NULL 
                FROM    CHSStaging.dbo.GNClaims_160807Parsed rw 
                        INNER JOIN dbo.H_Provider p ON rw.CentauriProviderID = p.Provider_BK 
                        INNER JOIN CHSDV.dbo.R_ClaimData r ON rw.CentauriClaimsID = r.CentauriClaimDataID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimsID, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderClaims_RK 
                        FROM    L_ProviderClaims 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(rw.CentauriClaimsID, '')))))), 2)) , 
                        p.H_Provider_RK , 
                        r.ClaimDataHashKey;  
                         
 
--Load history for  L_PharmacyPharmacyClaim 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_ProviderClaims' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_ProviderClaims', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_ProviderClaims' 
                        ) , 
                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimsID, '')))))), 2)), 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = 'GNClaims_160807' 
                        ) 
                FROM    CHSStaging.dbo.GNClaims_160807Parsed rw 
                        INNER JOIN dbo.H_Provider p ON rw.CentauriProviderID = p.Provider_BK 
                        INNER JOIN CHSDV.dbo.R_ClaimData r ON rw.CentauriClaimsID = r.CentauriClaimDataID 
 
--*LOAD L_MemberClaims 
 
        INSERT  INTO dbo.L_MemberClaims 
                ( L_MemberClaims_RK , 
                  H_Member_RK , 
                  H_Claims_RK , 
                  LoadDate , 
                  RecordSource , 
                  RecordEndDate 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimsID, '')))))), 2)) , 
                        p.H_Member_RK , 
                        r.ClaimDataHashKey , 
                        GETDATE() , 
                        'GNClaims_160807' , 
                        NULL 
                FROM    CHSStaging.dbo.GNClaims_160807Parsed rw 
                        INNER JOIN dbo.H_Member p ON rw.CentauriMemberID = p.Member_BK 
                        INNER JOIN CHSDV.dbo.R_ClaimData r ON rw.CentauriClaimsID = r.CentauriClaimDataID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimsID, '')))))), 2)) NOT IN ( 
                        SELECT  L_MemberClaims_RK 
                        FROM    L_MemberClaims 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(rw.CentauriClaimsID, '')))))), 2)) , 
                        p.H_Member_RK , 
                        r.ClaimDataHashKey;  
                         
 
--Load history for  L_PharmacyPharmacyClaim 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_MemberClaims' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_MemberClaims', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_MemberClaims' 
                        ) , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimsID, '')))))), 2)), 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = 'GNClaims_160807' 
                        ) 
                FROM    CHSStaging.dbo.GNClaims_160807Parsed rw 
                        INNER JOIN dbo.H_Member p ON rw.CentauriMemberID = p.Member_BK 
                        INNER JOIN CHSDV.dbo.R_ClaimData r ON rw.CentauriClaimsID = r.CentauriClaimDataID 
 
 
-- Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  
-- Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  
-- Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  
-- Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  Esi1900 ***  
 
 
 
 
--*LOAD L_MemberPharmacyClaim 
 
        INSERT  INTO dbo.L_MemberPharmacyClaim 
                ( L_MemberPharmacyClaim_RK , 
                  H_Member_RK , 
                  H_PharmacyClaim_RK , 
                  LoadDate , 
                  RecordSource , 
                  RecordEndDate 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) , 
                        b.H_Member_RK , 
                        r.GNPharmacyClaimHashKey , 
                        GETDATE() , 
                        'GuildNet_esi_guildnet_1900_extract' , 
                        NULL 
                FROM    CHSStaging.dbo.GuildNet_esi_guildnet_1900_extract rw 
                        INNER JOIN dbo.H_Member b ON rw.CentauriMemberID = b.Member_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriPharmacyClaimID = r.CentauriPharmacyClaimID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) NOT IN ( 
                        SELECT  L_MemberPharmacyClaim_RK 
                        FROM    L_MemberPharmacyClaim 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) , 
                        b.H_Member_RK , 
                        r.GNPharmacyClaimHashKey; 
 
 
 
--Load history for  L_MemberPharmacyClaim 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_MemberPharmacyClaim' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_MemberPharmacyClaim', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_MemberPharmacyClaim' 
                        ) , 
                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) , 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = rw.FileName  COLLATE Compatibility_52_409_30003 
                        ) 
               FROM    CHSStaging.dbo.GuildNet_esi_guildnet_1900_extract rw 
                        INNER JOIN dbo.H_Member b ON rw.CentauriMemberID = b.Member_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriPharmacyClaimID = r.CentauriPharmacyClaimID 
 
 
 
--*LOAD L_PharmacyPharmacyClaim 
 
        INSERT  INTO dbo.L_PharmacyPharmacyClaim 
                ( L_PharmacyPharmacyClaim_RK , 
                  H_Pharmacy_RK , 
                  H_PharmacyClaim_RK , 
                  LoadDate , 
                  RecordSource , 
                  RecordEndDate 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) , 
                        H_Pharmacy_RK , 
                        r.GNPharmacyClaimHashKey , 
                        GETDATE() , 
                        'GuildNet_esi_guildnet_1900_extract' , 
                        NULL 
                FROM    CHSStaging.dbo.GuildNet_esi_guildnet_1900_extract rw 
                        INNER JOIN dbo.H_Pharmacy p ON rw.CentauriPharmacyID = p.Pharmacy_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriPharmacyClaimID = r.CentauriPharmacyClaimID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) NOT IN ( 
                        SELECT  L_PharmacyPharmacyClaim_RK 
                        FROM    L_PharmacyPharmacyClaim 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) , 
                        H_Pharmacy_RK , 
                        r.GNPharmacyClaimHashKey; 
 
 
--Load history for L_PharmacyPharmacyClaim 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_PharmacyPharmacyClaim' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_PharmacyPharmacyClaim', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_PharmacyPharmacyClaim' 
                        ) , 
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) , 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = rw.FileName  COLLATE Compatibility_52_409_30003 
                        ) 
             FROM    CHSStaging.dbo.GuildNet_esi_guildnet_1900_extract rw 
                        INNER JOIN dbo.H_Pharmacy p ON rw.CentauriPharmacyID = p.Pharmacy_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriPharmacyClaimID = r.CentauriPharmacyClaimID 
 
 
 
-- MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  
-- MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  
-- MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  
-- MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  MKM301 ***  
 
	INSERT INTO dbo.L_ProviderClaims 
	        ( L_ProviderClaims_RK , 
	          H_Provider_RK , 
	          H_Claims_RK , 
	          LoadDate , 
	          RecordSource , 
	          RecordEndDate 
	        ) 
	 
 SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimDataID, '')))))), 2)) , 
                        p.H_Provider_RK , 
                        r.ClaimDataHashKey , 
                        GETDATE() , 
                        'GuildNet_GHI_MKM301_MEDCLAIMS_DELM' , 
                        NULL 
				FROM    CHSStaging.dbo.GuildNet_GHI_MKM301_MEDCLAIMS_DELM rw 
                        INNER JOIN dbo.H_Provider p ON rw.CentauriProviderID = p.Provider_BK 
                        INNER JOIN CHSDV.dbo.R_ClaimData r ON rw.CentauriClaimDataID = r.CentauriClaimDataID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimDataID, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderClaims_RK 
                        FROM    L_ProviderClaims 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimDataID, '')))))), 2)) , 
                        p.H_Provider_RK , 
                        r.ClaimDataHashKey;  
                         
 
--Load history for L_ProviderClaims 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_ProviderClaims' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_ProviderClaims', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_ProviderClaims' 
                        ) , 
                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimDataID, '')))))), 2)), 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = rw.FileName  COLLATE Compatibility_52_409_30003 
                        ) 
             FROM    CHSStaging.dbo.GuildNet_GHI_MKM301_MEDCLAIMS_DELM rw 
                        INNER JOIN dbo.H_Provider p ON rw.CentauriProviderID = p.Provider_BK 
                        INNER JOIN CHSDV.dbo.R_ClaimData r ON rw.CentauriClaimDataID = r.CentauriClaimDataID 
 
 
-- MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   
-- MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   
-- MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   
-- MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   MKM302 ***   
 
	INSERT INTO dbo.L_ProviderClaims 
	        ( L_ProviderClaims_RK , 
	          H_Provider_RK , 
	          H_Claims_RK , 
	          LoadDate , 
	          RecordSource , 
	          RecordEndDate 
	        ) 
	 
 SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimDataID, '')))))), 2)) , 
                        p.H_Provider_RK , 
                        r.ClaimDataHashKey , 
                        GETDATE() , 
                        'GuildNet_GHI_MKM301_MEDCLAIMS_DELM' , 
                        NULL 
				FROM    CHSStaging.dbo.GuildNet_ghi_mkm302_hospclaims_delm rw 
                        INNER JOIN dbo.H_Provider p ON rw.CentauriProviderID = p.Provider_BK 
                        INNER JOIN CHSDV.dbo.R_ClaimData r ON rw.CentauriClaimDataID = r.CentauriClaimDataID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimDataID, '')))))), 2)) NOT IN ( 
                        SELECT  L_ProviderClaims_RK 
                        FROM    L_ProviderClaims 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimDataID, '')))))), 2)) , 
                        p.H_Provider_RK , 
                        r.ClaimDataHashKey;  
 
 
--Load history for L_ProviderClaims 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_ProviderClaims' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_ProviderClaims', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_ProviderClaims' 
                        ) , 
                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriProviderID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriClaimDataID, '')))))), 2)) , 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = rw.FileName  COLLATE Compatibility_52_409_30003 
                        ) 
            FROM    CHSStaging.dbo.GuildNet_ghi_mkm302_hospclaims_delm rw 
                        INNER JOIN dbo.H_Provider p ON rw.CentauriProviderID = p.Provider_BK 
                        INNER JOIN CHSDV.dbo.R_ClaimData r ON rw.CentauriClaimDataID = r.CentauriClaimDataID 
 
                         
 -- GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  
 -- GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  
 -- GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  
 -- GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  GuildNet_GNClaimRpt ***  
  
--*LOAD L_MemberPharmacyClaim 
 
        INSERT  INTO dbo.L_MemberPharmacyClaim 
                ( L_MemberPharmacyClaim_RK , 
                  H_Member_RK , 
                  H_PharmacyClaim_RK , 
                  LoadDate , 
                  RecordSource , 
                  RecordEndDate 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) , 
                        b.H_Member_RK , 
                        r.GNPharmacyClaimHashKey , 
                        rw.LoadDate , 
                        rw.FileName , 
                        NULL 
                FROM    CHSStaging.dbo.GuildNet_GNClaimRpt rw 
                        INNER JOIN dbo.H_Member b ON rw.CentauriMemberID = b.Member_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriPharmacyClaimID = r.CentauriPharmacyClaimID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) NOT IN ( 
                        SELECT  L_MemberPharmacyClaim_RK 
                        FROM    L_MemberPharmacyClaim 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) , 
                        b.H_Member_RK , 
                        r.GNPharmacyClaimHashKey , 
                        rw.LoadDate , 
                        rw.FileName; 
 
 
--Load history for L_MemberPharmacyClaim 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_MemberPharmacyClaim' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_MemberPharmacyClaim', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_MemberPharmacyClaim' 
                        ) , 
                     UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CentauriMemberID, ''))), ':', 
                                                                       RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2))  , 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = rw.FileName  COLLATE Compatibility_52_409_30003 
                        ) 
                 FROM    CHSStaging.dbo.GuildNet_GNClaimRpt rw 
                        INNER JOIN dbo.H_Member b ON rw.CentauriMemberID = b.Member_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriPharmacyClaimID = r.CentauriPharmacyClaimID 
 
 
--*LOAD L_PharmacyPharmacyClaim 
 
        INSERT  INTO dbo.L_PharmacyPharmacyClaim 
                ( L_PharmacyPharmacyClaim_RK , 
                  H_Pharmacy_RK , 
                  H_PharmacyClaim_RK , 
                  LoadDate , 
                  RecordSource , 
                  RecordEndDate 
                ) 
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) , 
                        H_Pharmacy_RK , 
                        r.GNPharmacyClaimHashKey , 
                        rw.LoadDate , 
                        rw.FileName , 
                        NULL 
                FROM    CHSStaging.dbo.GuildNet_GNClaimRpt rw 
                        INNER JOIN dbo.H_Pharmacy p ON rw.centauriPharmacyID = p.Pharmacy_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriPharmacyClaimID = r.CentauriPharmacyClaimID 
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) NOT IN ( 
                        SELECT  L_PharmacyPharmacyClaim_RK 
                        FROM    L_PharmacyPharmacyClaim 
                        WHERE   RecordEndDate IS NULL ) 
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', 
                                                                        RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2)) , 
                        H_Pharmacy_RK , 
                        r.GNPharmacyClaimHashKey , 
                        rw.LoadDate , 
                        rw.FileName; 
 
     
--Load history for L_PharmacyPharmacyClaim 
 
			--History Table 
        IF ( SELECT COUNT(*) 
             FROM   dbo.TableNames 
             WHERE  TableName = 'L_PharmacyPharmacyClaim' 
           ) = 0 
            INSERT  INTO dbo.TableNames 
                    ( TableName, CreateDate ) 
            VALUES  ( 'L_PharmacyPharmacyClaim', GETDATE() ); 
 
 
 
        INSERT  INTO LoadHistory2 
                ( TableName_PK , 
                  HashKey , 
                  RecordSource_PK 
                ) 
                SELECT	DISTINCT 
                        ( SELECT    TableName_PK 
                          FROM      TableNames 
                          WHERE     TableName = 'L_PharmacyPharmacyClaim' 
                        ) , 
                     UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', 
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.Pharmacy_BK, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CentauriPharmacyClaimID, '')))))), 2))  , 
                        ( SELECT    RecordSource_PK 
                          FROM      RecordSources 
                          WHERE     RecordSource = rw.FileName  COLLATE Compatibility_52_409_30003 
                        ) 
                 FROM    CHSStaging.dbo.GuildNet_GNClaimRpt rw 
                        INNER JOIN dbo.H_Pharmacy p ON rw.centauriPharmacyID = p.Pharmacy_BK 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim r ON rw.CentauriPharmacyClaimID = r.CentauriPharmacyClaimID 
	 
	END; 
 
 
 
 
 
GO
