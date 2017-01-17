SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 01/03/2017
-- Description:	Load all Hubs from the GuildNet Claims staging table.  
-- =============================================
CREATE PROCEDURE [dbo].[spDV_GuildNetClaims_LoadHubs]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;



--** LOAD H_esi1900
        INSERT  INTO [dbo].[H_esi1900]
                ( [H_esi1900_RK] ,
                  [esi1900_BK] ,
                  [Clientesi1900ID] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT	DISTINCT
                        b.esi1900HashKey ,
                        b.Centauriesi1900ID ,
                        a.TransactionID ,
                        b.RecordSource ,
                        b.LoadDate
                FROM    CHSStaging.dbo.GuildNet_esi_guildnet_1900_extract a
                        INNER JOIN CHSDV.dbo.R_esi1900 b ON a.TransactionID = b.Clientesi1900ID
                WHERE   b.esi1900HashKey COLLATE Compatibility_52_409_30003 NOT IN ( SELECT H_esi1900_RK
                                                                                     FROM   H_esi1900 ); 
		
		
--Load [H_MKM301]
        INSERT  INTO [dbo].[H_MKM301]
                ( [H_MKM301_RK] ,
                  [MKM301_BK] ,
                  [ClientMKM301ID] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT	DISTINCT
                        b.MKM301HashKey ,
                        b.CentauriMKM301ID ,
                        a.GHASH ,
                        b.RecordSource ,
                        b.LoadDate
                FROM    CHSStaging.dbo.[GuildNet_GHI_MKM301_MEDCLAIMS_DELM] a
                        INNER JOIN CHSDV.dbo.R_MKM301 b ON a.GHASH = b.ClientMKM301ID
                WHERE   b.MKM301HashKey COLLATE Compatibility_52_409_30003 NOT IN ( SELECT  H_MKM301_RK
                                                                                    FROM    H_MKM301 ); 
		
	--Load [H_MKM302]
        INSERT  INTO [dbo].[H_MKM302]
                ( [H_MKM302_RK] ,
                  [MKM302_BK] ,
                  [ClientMKM302ID] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT	DISTINCT
                        b.MKM302HashKey ,
                        b.CentauriMKM302ID ,
                        a.GHASH ,
                        b.RecordSource ,
                        b.LoadDate
                FROM    CHSStaging.dbo.GuildNet_ghi_mkm302_hospclaims_delm a
                        INNER JOIN CHSDV.dbo.R_MKM302 b ON a.GHASH = b.ClientMKM302ID
                WHERE   b.MKM302HashKey COLLATE Compatibility_52_409_30003 NOT IN ( SELECT  H_MKM302_RK
                                                                                    FROM    H_MKM302 ); 

		--Load [H_GNClaimRpt]
        INSERT  INTO [dbo].[H_GNClaimRpt]
                ( [H_GNClaimRpt_RK] ,
                  [GNClaimRpt_BK] ,
                  [ClientGNClaimRptID] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT	DISTINCT
                        b.GNClaimRptHashKey ,
                        b.CentauriGNClaimRptID ,
                        a.[GL BATCHID] ,
                        b.RecordSource ,
                        b.LoadDate
                FROM    CHSStaging.dbo.GuildNet_GNClaimRpt a
                        INNER JOIN CHSDV.dbo.R_GNClaimRpt b ON a.[GL BATCHID] = b.ClientGNClaimRptID
                WHERE   b.GNClaimRptHashKey COLLATE Compatibility_52_409_30003 NOT IN ( SELECT  H_GNClaimRpt_RK
                                                                                        FROM    H_GNClaimRpt ); 


			
		
	


    END;





GO
