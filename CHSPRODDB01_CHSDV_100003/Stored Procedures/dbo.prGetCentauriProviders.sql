SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
-- ===============================================================================================================
-- Author:		Travis Parker
-- Create date:	05/09/2016
-- Description:	Returns CentauriProviderID and Hash value for Providers passed in
-- Name:			prGetCentauriProviders
-- USAGE:  

DECLARE @RC INT;
DECLARE @ProviderList dbo.ProviderTableType;

INSERT INTO @ProviderList
   (
     ClientID,
     ClientProviderID,
	NPI,
     LoadDate,
     RecordSource
   )
       SELECT
            '100001' AS ClientID,
            'TPTest1235' AS ClientProviderID,
		  '123456789' AS NPI,
            GETDATE() AS LoadDate,
            'TravisParker' AS RecordSource; 

-- TODO: Set parameter values here.

CREATE TABLE #TempProviders
(
     CentauriProviderID INT,
     ProviderHashKey    VARCHAR(50),
     ClientID         VARCHAR(100),
     ClientProviderID   VARCHAR(50),
	NPI			    VARCHAR(20)
);

INSERT INTO #TempProviders
EXECUTE @RC = dbo.prGetCentauriProviders
        @ProviderList;
GO

SELECT
     *
FROM #TempProviders;

-- ===============================================================================================================
*/

CREATE PROCEDURE [dbo].[prGetCentauriProviders]
     @ProviderList ProviderTABLETYPE READONLY
AS
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO dbo.R_Provider
           (
             ClientID,
             ClientProviderID,
		   NPI,
             LoadDate,
             RecordSource
           )
               SELECT DISTINCT
                    l.ClientID,
                    l.ClientProviderID,
				l.NPI,
                    l.LoadDate,
                    l.RecordSource
               FROM  @ProviderList AS l
                     LEFT JOIN dbo.R_Provider AS r ON l.ClientProviderID = r.ClientProviderID
                                                    AND l.ClientID = r.ClientID
               WHERE ISNULL(l.NPI,'') = '' AND r.CentauriProviderID IS NULL;

        INSERT INTO dbo.R_Provider
           (
             ClientID,
             ClientProviderID,
		   NPI,
             LoadDate,
             RecordSource
           )
               SELECT DISTINCT
                    l.ClientID,
                    l.ClientProviderID,
				l.NPI,
                    l.LoadDate,
                    l.RecordSource
               FROM  @ProviderList AS l
                     LEFT JOIN dbo.R_Provider AS r ON l.NPI = r.NPI
               WHERE ISNULL(l.NPI,'') <> '' AND r.CentauriProviderID IS NULL;
	   
	   SELECT
             r.CentauriProviderID,
		   r.ProviderHashKey,
             r.ClientID,
             r.ClientProviderID,
		   r.NPI
        FROM @ProviderList AS l
             INNER JOIN dbo.R_Provider AS r ON l.ClientProviderID = r.ClientProviderID
                                             AND l.ClientID = r.ClientID
	   UNION
	   SELECT
             r.CentauriProviderID,
		   r.ProviderHashKey,
             r.ClientID,
             r.ClientProviderID,
		   r.NPI
        FROM @ProviderList AS l
             INNER JOIN dbo.R_Provider AS r ON l.NPI = r.NPI 

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


GO
