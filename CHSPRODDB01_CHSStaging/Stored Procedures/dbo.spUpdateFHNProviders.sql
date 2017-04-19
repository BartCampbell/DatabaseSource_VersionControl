SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 04/03/2017
-- Description:	Update FHNProviders before DV load
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateFHNProviders] 
	
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

		DECLARE @LoadDate DATETIME
		SET @LoadDate = GETDATE()

    		UPDATE  CHSStaging.dbo.FHN_Provider_Stage SET LoadDate=@LoadDate


			SELECT a.npi,MIN(b.CentauriProviderID) AS CentauriProviderID 
			INTO #cen
			FROM CHSStaging.dbo.FHN_Provider_Stage a
			INNER JOIN chsdv.dbo.R_Provider b ON b.NPI = a.NPI
			GROUP BY a.npi


			UPDATE a
			SET a.CentauriProviderID = b.CentauriProviderID
			--SELECT MIN(b.CentauriProviderID)
			FROM CHSStaging.dbo.FHN_Provider_Stage a
			INNER JOIN #cen b ON b.NPI = a.NPI                    

			
			INSERT INTO chsdv.dbo.R_Provider
					( NPI ,
					  ClientID ,
					  ClientProviderID ,
					  ChaseID ,
					  ProjectID ,
					  TIN ,
					  LoadDate ,
					  RecordSource
					)
					SELECT DISTINCT a. NPI ,
					  100002 ,
					  '' ,
					  '' ,
					  '' ,
					  '' ,
					  GETDATE() ,
					  FileName
					   FROM CHSStaging.dbo.FHN_Provider_Stage a
					  LEFT OUTER JOIN chsdv.dbo.R_Provider b ON a.CentauriProviderID=b.CentauriProviderID AND b.ClientID=100002
			WHERE b.CentauriProviderID IS NULL



			UPDATE a
			SET a.CentauriProviderID = b.CentauriProviderID
			--SELECT * 
			FROM CHSStaging.dbo.FHN_Provider_Stage a
			INNER JOIN chsdv.dbo.R_Provider b ON  b.ClientID=100002 AND b.NPI = a.NPI AND b.RecordSource=a.FileName



			UPDATE a
			SET     a.HashKey = b.ProviderHashKey
			FROM    CHSStaging.dbo.FHN_Provider_Stage a
					INNER JOIN CHSDV.dbo.R_Provider b ON a.CentauriProviderID=b.CentauriProviderID  AND b.ClientID=100002

	
	INSERT INTO CHSDV.dbo.R_Network
	        ( 
	          ClientID ,
	          ClientNetworkID ,
	          LoadDate ,
	          RecordSource
	        )
	SELECT DISTINCT 100002,
			a.[Report To ID],
			a.LoadDate,
			a.FileName
		FROM    CHSStaging.dbo.FHN_Provider_Stage a
			LEFT OUTER JOIN CHSDV.dbo.R_Network b ON a.[Report To ID] = b.ClientNetworkID AND b.ClientID=100002
		WHERE b.CentauriNetworkID IS NULL

		UPDATE  a
		SET a.CentauriNetworkID = b.CentauriNetworkID
		--SELECT *
		FROM CHSStaging.dbo.FHN_Provider_Stage a
		INNER JOIN chsdv.dbo.R_Network b ON a.[Report To ID]=b.ClientNetworkID AND b.ClientID=100002 AND a.FileName=b.RecordSource

	UPDATE  a
		SET a.CentauriNetworkID = b.CentauriNetworkID
		--SELECT *
		FROM CHSStaging.dbo.FHN_Provider_Stage a
		INNER JOIN chsdv.dbo.R_Network b ON a.[Report To ID]=b.ClientNetworkID AND b.ClientID=100002
		WHERE a.CentauriNetworkID IS NULL



    END;


GO
