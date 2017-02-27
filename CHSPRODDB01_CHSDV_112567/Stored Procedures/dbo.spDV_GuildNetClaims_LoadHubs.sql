SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
-- ============================================= 
-- Author:		Paul Johnson 
-- Create date: 01/03/2017 
-- Update 01/23/2017 Adding Pharmacy claims PDJ 
-- Description:	Load all Hubs from the GuildNet Claims staging table.   
-- ============================================= 
CREATE PROCEDURE [dbo].[spDV_GuildNetClaims_LoadHubs] 
AS 
    BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from 
	-- interfering with SELECT statements. 
        SET NOCOUNT ON; 
 
 
 
--** LOAD H_Pharmacy for esi1900 
INSERT INTO dbo.H_Pharmacy 
        ( H_Pharmacy_RK , 
          Pharmacy_BK , 
          ClientPharmacyID , 
          RecordSource , 
          LoadDate 
        ) 
SELECT	DISTINCT 
                       b.PharmacyHashKey , 
                        b.CentauriPharmacyID, 
                        b.ClientPharmacyID , 
                        b.RecordSource , 
                        b.LoadDate 
                FROM    CHSStaging.dbo.GuildNet_esi_guildnet_1900_extract a 
                        INNER JOIN CHSDV.dbo.R_Pharmacy b ON a.PharmacyNABPNumber = b.ClientPharmacyID AND b.ClientID=112567 
                WHERE   b.PharmacyHashKey COLLATE Compatibility_52_409_30003 NOT IN ( SELECT H_Pharmacy_RK 
                                                                                     FROM   H_Pharmacy );  
		 
INSERT INTO dbo.H_PharmacyClaim 
        ( H_PharmacyClaim_RK , 
          PharmacyClaim_BK , 
          ClientPharmacyClaimID , 
          RecordSource , 
          LoadDate 
        ) 
SELECT	DISTINCT        b.GNPharmacyClaimHashKey , 
                        b.CentauriPharmacyClaimID, 
                        a.TransactionID , 
                        b.RecordSource , 
                        b.LoadDate 
                FROM    CHSStaging.dbo.GuildNet_esi_guildnet_1900_extract a 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim b ON a.TransactionID = b.ClientPharmacyClaimID AND b.ClientID=112567 
                WHERE   b.GNPharmacyClaimHashKey COLLATE Compatibility_52_409_30003 NOT IN ( SELECT H_PharmacyClaim_RK 
                                                                                     FROM   dbo.H_PharmacyClaim );  
 
INSERT INTO dbo.H_Member 
        ( H_Member_RK , 
          Member_BK , 
          ClientMemberID , 
          LoadDate , 
          RecordSource 
        ) 
SELECT	DISTINCT        b.MemberHashKey , 
                        b.CentauriMemberID, 
                        b.ClientMemberID , 
						b.LoadDate, 
                        b.RecordSource  
                         
                FROM    CHSStaging.dbo.GuildNet_esi_guildnet_1900_extract a 
                        INNER JOIN CHSDV.dbo.R_Member b ON a.CardHolderID +'_'+a.MemberNumber = b.ClientMemberID AND b.ClientID=112567 
                WHERE   b.MemberHashKey COLLATE Compatibility_52_409_30003 NOT IN ( SELECT H_Member_RK 
                                                                                     FROM   dbo.H_Member );  
 
		 
--Load [H_MKM301] 
 
			INSERT INTO dbo.H_Claims 
					( H_Claims_RK , 
					  Claims_BK , 
					  ClientClaimID , 
					  RecordSource , 
					  LoadDate 
					) 
					SELECT DISTINCT b.ClaimDataHashKey, 
							b.CentauriClaimDataID, 
							b.ClientClaimDataID, 
							b.RecordSource, 
							b.LoadDate 
 
							FROM    CHSStaging.dbo.[GuildNet_GHI_MKM301_MEDCLAIMS_DELM] a 
									INNER JOIN CHSDV.dbo.R_claimdata b ON a.centauriClaimDataID = b.CentauriClaimDataID 
									LEFT OUTER JOIN dbo.H_Claims c ON c.H_Claims_RK = b.ClaimDataHashKey 
									WHERE c.H_Claims_RK  IS NULL 
 
 
			INSERT INTO dbo.H_Provider 
					( H_Provider_RK , 
					  Provider_BK , 
					  ClientProviderID , 
					  RecordSource , 
					  LoadDate 
					) 
			SELECT DISTINCT        b.ProviderHashKey, 
					b.CentauriProviderID, 
					b.CentauriProviderID, 
					b.RecordSource, 
					b.LoadDate 
						FROM    CHSStaging.dbo.[GuildNet_GHI_MKM301_MEDCLAIMS_DELM] a 
									INNER JOIN CHSDV.dbo.R_Provider b ON a.centauriProviderID = b.CentauriProviderID 
									LEFT OUTER JOIN dbo.H_Provider c ON c.H_Provider_RK = b.ProviderHashKey 
				WHERE c.H_Provider_RK  IS NULL 
 
 
 
	--Load [H_MKM302] 
	INSERT INTO dbo.H_Claims 
	        ( H_Claims_RK , 
	          Claims_BK , 
	          ClientClaimID , 
	          RecordSource , 
	          LoadDate 
	        ) 
	select DISTINCT b.ClaimDataHashKey, 
			b.CentauriClaimDataID, 
			b.ClientClaimDataID, 
			b.RecordSource, 
			b.LoadDate 
	FROM CHSStaging.dbo.GuildNet_ghi_mkm302_hospclaims_delm a 
	INNER JOIN CHSDV.dbo.R_ClaimData b ON a.CentauriClaimDataID=b.CentauriClaimDataID 
	LEFT OUTER JOIN dbo.H_Claims c ON c.H_Claims_RK = b.ClaimDataHashKey 
	WHERE c.H_Claims_RK  IS NULL 
 
 
        
	   INSERT INTO dbo.H_Provider 
	           ( H_Provider_RK , 
	             Provider_BK , 
	             ClientProviderID , 
	             RecordSource , 
	             LoadDate 
	           ) 
	    
	   SELECT DISTINCT b.ProviderHashKey, 
			b.CentauriProviderID, 
			b.ClientProviderID, 
			b.RecordSource, 
			b.LoadDate 
	   FROM CHSStaging.dbo.GuildNet_ghi_mkm302_hospclaims_delm a 
	   INNER JOIN chsdv.dbo.R_Provider b ON b.CentauriProviderID = a.CentauriProviderID 
	   LEFT OUTER JOIN dbo.H_Provider c ON c.H_Provider_RK = b.ProviderHashKey 
	   WHERE c.H_Provider_RK IS NULL 
 
		--Load [H_GNClaimRpt] 
		INSERT INTO dbo.H_PharmacyClaim 
		        ( H_PharmacyClaim_RK , 
		          PharmacyClaim_BK , 
		          ClientPharmacyClaimID , 
		          RecordSource , 
		          LoadDate 
		        ) 
		SELECT DISTINCT b.GNPharmacyClaimHashKey, 
				b.CentauriPharmacyClaimID, 
				b.ClientPharmacyClaimID, 
				b.RecordSource, 
				b.LoadDate 
		FROM CHSStaging.dbo.GuildNet_GNClaimRpt a 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim b ON a.CentauriPharmacyClaimID = b.CentauriPharmacyClaimID AND b.ClientID=112567 
						LEFT OUTER JOIN dbo.H_PharmacyClaim c ON c.H_PharmacyClaim_RK = b.GNPharmacyClaimHashKey 
						WHERE c.H_PharmacyClaim_RK IS NULL 
 
 
		INSERT INTO dbo.H_Pharmacy 
		        ( H_Pharmacy_RK , 
		          Pharmacy_BK , 
		          ClientPharmacyID , 
		          RecordSource , 
		          LoadDate 
		        ) 
		SELECT DISTINCT b.PharmacyHashKey, 
					b.CentauriPharmacyID, 
					b.ClientPharmacyID, 
					b.RecordSource, 
					b.LoadDate 
		FROM CHSStaging.dbo.GuildNet_GNClaimRpt a 
                        INNER JOIN CHSDV.dbo.R_Pharmacy b ON a.CentauriPharmacyID = b.CentauriPharmacyID AND b.ClientID=112567 
						LEFT OUTER JOIN dbo.H_Pharmacy c ON c.H_Pharmacy_RK = b.PharmacyHashKey 
						WHERE c.H_Pharmacy_RK IS NULL 
 
		INSERT INTO dbo.H_Member 
		        ( H_Member_RK , 
		          Member_BK , 
		          ClientMemberID , 
		          LoadDate , 
		          RecordSource 
		        ) 
		SELECT DISTINCT b.MemberHashKey, 
					b.CentauriMemberID, 
					b.ClientMemberID, 
					b.RecordSource, 
					b.LoadDate 
		FROM CHSStaging.dbo.GuildNet_GNClaimRpt a 
                        INNER JOIN CHSDV.dbo.R_Member b ON a.CentauriMemberID = b.CentauriMemberID AND b.ClientID=112567 
						LEFT OUTER JOIN dbo.H_Member c ON c.H_Member_RK = b.MemberHashKey 
						WHERE c.H_Member_RK IS NULL 
 
	 
 
		--** LOAD H_Pharmacy 
         
        INSERT  INTO [dbo].[H_Pharmacy] 
                ( [H_Pharmacy_RK] , 
                  [Pharmacy_BK] , 
                  [ClientPharmacyID] , 
                  [RecordSource] , 
                  [LoadDate] 
                ) 
                SELECT	DISTINCT 
                        b.PharmacyHashKey , 
                        b.CentauriPharmacyID , 
                        a.[PHR-PHARMACY-NABP-NO] , 
                        b.RecordSource , 
                        b.LoadDate 
                FROM    CHSStaging.dbo.GuildNet_GNESIBatchPayDet_PharmacyHeader a 
                        INNER JOIN CHSDV.dbo.R_Pharmacy b ON b.CentauriPharmacyID = a.CentauriPharmacyID 
                WHERE   b.PharmacyHashKey COLLATE Compatibility_52_409_30003 NOT IN ( SELECT    H_Pharmacy_RK 
                                                                                      FROM      H_Pharmacy );  
 
        INSERT  INTO [dbo].[H_Pharmacy] 
                ( [H_Pharmacy_RK] , 
                  [Pharmacy_BK] , 
                  [ClientPharmacyID] , 
                  [RecordSource] , 
                  [LoadDate] 
                ) 
                SELECT	DISTINCT 
                        b.PharmacyHashKey , 
                        b.CentauriPharmacyID , 
                        a.[PTR-PHARMACY-NABP-NO] , 
                        b.RecordSource , 
                        b.LoadDate 
                FROM    CHSStaging.dbo.GuildNet_GNESIBatchPayDet_PharmacyTrailer a 
                        INNER JOIN CHSDV.dbo.R_Pharmacy b ON b.CentauriPharmacyID = a.CentauriPharmacyID 
                WHERE   b.PharmacyHashKey COLLATE Compatibility_52_409_30003 NOT IN ( SELECT    H_Pharmacy_RK 
                                                                                      FROM      H_Pharmacy );  
	 
		 
	--Pharmacy Claim 
 
	         
        INSERT  INTO [dbo].[H_PharmacyClaim] 
                ( [H_PharmacyClaim_RK] , 
                  [PharmacyClaim_BK] , 
                  [ClientPharmacyClaimID] , 
                  [RecordSource] , 
                  [LoadDate] 
                ) 
                SELECT	DISTINCT 
                        b.GNPharmacyClaimHashKey , 
                        b.CentauriPharmacyClaimID , 
                        a.[CR-CLAIM-NUMBER] + '-' + a.[CR-TRANSACTION-TYPE] , 
                        b.RecordSource , 
                        b.LoadDate 
                FROM    CHSStaging.[dbo].[GuildNet_GNESIBatchPayDet_PharmacyClaim] a 
                        INNER JOIN CHSDV.dbo.R_PharmacyClaim b ON b.CentauriPharmacyClaimID = a.CentauriID 
                WHERE   b.GNPharmacyClaimHashKey COLLATE Compatibility_52_409_30003 NOT IN ( SELECT H_PharmacyClaim_RK 
                                                                                             FROM   dbo.H_PharmacyClaim );  
 
 
 
  -- Provider  Pharmacy 
 
        INSERT  INTO [dbo].[H_Provider] 
                ( [H_Provider_RK] , 
                  [Provider_BK] , 
                  [ClientProviderID] , 
                  [RecordSource] , 
                  [LoadDate] 
                ) 
                SELECT DISTINCT 
                        b.ProviderHashKey , 
                        b.CentauriProviderID , 
                        b.ClientProviderID , 
                        'GuildNet_GNESIBatchPayDet_PharmacyClaim' , 
                        GETDATE() 
                FROM    CHSStaging.[dbo].[GuildNet_GNESIBatchPayDet_PharmacyClaim] a 
                        INNER JOIN CHSDV.dbo.R_Provider b ON b.CentauriProviderID = a.CentauriProviderID 
                        LEFT OUTER JOIN dbo.H_Provider c ON b.CentauriProviderID = c.Provider_BK 
                WHERE   c.H_Provider_RK IS NULL; 
 
	--Member Pharmacy 
        INSERT  INTO dbo.H_Member 
                ( H_Member_RK , 
                  Member_BK , 
                  ClientMemberID , 
                  LoadDate , 
                  RecordSource 
		        ) 
                SELECT DISTINCT 
                        b.MemberHashKey , 
                        b.CentauriMemberID , 
                        b.ClientMemberID , 
                        GETDATE() , 
                        'GuildNet_GNESIBatchPayDet_PharmacyClaim' 
                FROM    CHSStaging.[dbo].[GuildNet_GNESIBatchPayDet_PharmacyClaim] a 
                        INNER JOIN CHSDV.dbo.R_Member b ON b.CentauriMemberID = a.CentauriMemberID 
                        LEFT OUTER JOIN dbo.H_Member c ON b.CentauriMemberID = c.Member_BK 
                WHERE   c.H_Member_RK IS NULL; 
 
--GNClaims_16807 
        INSERT  INTO dbo.H_Claims 
                ( H_Claims_RK , 
                  Claims_BK , 
                  ClientClaimID , 
                  RecordSource , 
                  LoadDate 
		        ) 
                SELECT DISTINCT 
                        b.ClaimDataHashKey , 
                        b.CentauriClaimDataID , 
                        b.ClientClaimDataID , 
                        'GNClaims_160807' , 
                        GETDATE() 
                FROM    CHSStaging.dbo.GNClaims_160807Parsed a 
                        INNER JOIN CHSDV.dbo.R_ClaimData b ON a.CentauriClaimsID = b.CentauriClaimDataID 
                                                              AND b.ClientID = 112567 
                        LEFT OUTER JOIN dbo.H_Claims h ON h.H_Claims_RK = b.ClaimDataHashKey 
                WHERE   h.H_Claims_RK IS NULL;  
 
-- Provider - GNClaims_16807	 
 
        INSERT  INTO [dbo].[H_Provider] 
                ( [H_Provider_RK] , 
                  [Provider_BK] , 
                  [ClientProviderID] , 
                  [RecordSource] , 
                  [LoadDate] 
                ) 
                SELECT DISTINCT 
                        b.ProviderHashKey , 
                        b.CentauriProviderID , 
                        b.ClientProviderID , 
                        'GNClaims_160807' , 
                        GETDATE() 
                FROM    CHSStaging.[dbo].GNClaims_160807Parsed a 
                        INNER JOIN CHSDV.dbo.R_Provider b ON b.CentauriProviderID = a.CentauriProviderID 
                        LEFT OUTER JOIN dbo.H_Provider c ON b.CentauriProviderID = c.Provider_BK 
                WHERE   c.H_Provider_RK IS NULL; 
 
	--Member GNClaims_160807 
        INSERT  INTO dbo.H_Member 
                ( H_Member_RK , 
                  Member_BK , 
                  ClientMemberID , 
                  LoadDate , 
                  RecordSource 
		        ) 
                SELECT DISTINCT 
                        b.MemberHashKey , 
                        b.CentauriMemberID , 
                        b.ClientMemberID , 
                        GETDATE() , 
                        'GNClaims_160807' 
                FROM    CHSStaging.[dbo].GNClaims_160807Parsed a 
                        INNER JOIN CHSDV.dbo.R_Member b ON b.CentauriMemberID = a.CentauriMemberID 
                        LEFT OUTER JOIN dbo.H_Member c ON b.CentauriMemberID = c.Member_BK 
                WHERE   c.H_Member_RK IS NULL; 
 
 
 
 
    END; 
 
 
 
 
GO
