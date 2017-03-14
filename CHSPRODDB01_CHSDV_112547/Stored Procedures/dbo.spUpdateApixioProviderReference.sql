SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	12/14/2016
-- Description:	Loads new providers into the provider reference table from the Apixio Return staging table
-- Usage:			
--		  EXECUTE dbo.spUpdateApixioProviderReference
-- =============================================

CREATE PROCEDURE [dbo].[spUpdateApixioProviderReference]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

            --BEGIN TRANSACTION;
		  
		  --update the matches to current suspect providers
            UPDATE  a
            SET     a.CentauriProviderID = s.CentauriProviderID
            FROM    CHSStaging.dbo.ApixioReturn AS a
                    INNER JOIN dbo.vwSuspectProvider s ON a.Suspect_PK = s.Suspect_PK
                                                          AND LEFT(s.FirstName, 5) = LEFT(a.PROVIDER_FIRST, 5)
                                                          AND LEFT(s.LastName, 5) = LEFT(a.PROVIDER_LAST, 5)
            WHERE   a.CentauriProviderID IS NULL; 


		  --update the matches to current providers on NPI and Name
            UPDATE  a
            SET     a.CentauriProviderID = s.CentauriProviderID
            FROM    CHSStaging.dbo.ApixioReturn AS a
                    INNER JOIN dbo.vwSuspectProvider s ON a.PROVIDER_NPI = s.NPI
                                                          AND LEFT(a.PROVIDER_FIRST, 5) = LEFT(s.FirstName, 5)
                                                          AND LEFT(a.PROVIDER_LAST, 5) = LEFT(s.LastName, 5)
            WHERE   a.CentauriProviderID IS NULL; 

             --LOAD NEW PROVIDERS FROM Apixio STAGING
            INSERT  INTO CHSDV.dbo.R_Provider
                    ( ClientID ,
                      NPI ,
                      ChaseID ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT  a.ClientID ,
                            a.PROVIDER_NPI ,
                            'Apixio:' + a.PROVIDER_LAST + ':' + a.PROVIDER_FIRST AS ChaseID ,
                            GETDATE() ,
                            MIN(a.FileName) AS FileName
                    FROM    CHSStaging.dbo.ApixioReturn AS a
                            INNER JOIN dbo.vwSuspectProvider s ON a.Suspect_PK = s.Suspect_PK
                                                                  AND ( LEFT(s.FirstName, 5) <> LEFT(a.PROVIDER_FIRST, 5)
                                                                        OR LEFT(s.LastName, 5) <> LEFT(a.PROVIDER_LAST, 5)
                                                                      )
                            LEFT JOIN dbo.vwSuspectProvider s2 ON LEFT(a.PROVIDER_FIRST, 5) = LEFT(s2.FirstName, 5)
                                                                  AND LEFT(a.PROVIDER_LAST, 5) = LEFT(s2.LastName, 5)
                                                                  AND a.PROVIDER_NPI = s2.NPI
                            LEFT JOIN CHSDV.dbo.R_Provider r ON a.PROVIDER_NPI = r.NPI
                                                                AND a.ClientID = r.ClientID
												    AND 'Apixio:' + a.PROVIDER_LAST + ':' + a.PROVIDER_FIRST = r.ChaseID
                    WHERE   s2.Suspect_PK IS NULL
                            AND r.CentauriProviderID IS NULL
					   AND a.CentauriProviderID IS NULL 
					   --AND ISNULL(a.PROVIDER_NPI, '') <> ''
                    GROUP BY a.ClientID ,
                            a.PROVIDER_NPI ,
                            a.PROVIDER_LAST ,
                            a.PROVIDER_FIRST ,
                            r.CentauriProviderID; --2041


		  --update the matches to new providers
            UPDATE  a
            SET     a.CentauriProviderID = r.CentauriProviderID
            FROM    CHSStaging.dbo.ApixioReturn AS a
                    INNER JOIN CHSDV.dbo.R_Provider r ON a.PROVIDER_NPI = r.NPI
                                                                AND a.ClientID = r.ClientID
												    AND 'Apixio:' + a.PROVIDER_LAST + ':' + a.PROVIDER_FIRST = r.ChaseID
            WHERE   a.CentauriProviderID IS NULL; 

            --COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            --IF @@TRANCOUNT > 0
            --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;

GO
