SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
-- Description:	merges the stage to dim for advantage ProviderContact based on dbo.spOECMergeProviderContact
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProviderContact
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProviderContact]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ProviderContact AS t
        USING
            ( SELECT   DISTINCT o.ProviderID ,
                        a.Phone ,
                        a.Fax,
						a.EmailAddress
              FROM      stage.ProviderContact_ADV a
			    INNER JOIN dim.ProviderOffice o ON a.CentauriProviderOfficeID = o.CentauriProviderOfficeID
		    
            ) AS s
        ON t.ProviderID = s.ProviderID
            AND ISNULL(t.Phone,'') = ISNULL(s.Phone,'')
            AND ISNULL(t.Fax,'') = ISNULL(s.Fax,'')
			AND ISNULL(t.EmailAddress,'') = ISNULL( s.EmailAddress,'')
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ProviderID, Phone, Fax, EmailAddress )
            VALUES ( ProviderID, Phone, Fax, EmailAddress );

			

				SELECT ProviderID INTO #po FROM dim.ProviderContact GROUP BY ProviderID 
				
				SELECT a.ProviderID,MAX(a.LastUpdate) AS LU INTO #mp
				FROM dim.ProviderContact  a 
				INNER JOIN #po b ON b.ProviderID = a.ProviderID 
				GROUP BY a.ProviderID

				UPDATE a
				SET a.RecordEndDate = NULL
				FROM dim.ProviderContact  a 
				INNER JOIN #mp b
				ON b.ProviderID = a.ProviderID AND a.LastUpdate = b.LU
				WHERE a.RecordEndDate IS NOT NULL

				UPDATE a
				SET a.RecordEndDate = GETDATE()
				FROM dim.ProviderContact  a 
				LEFT OUTER JOIN #mp b
				ON b.ProviderID = a.ProviderID AND a.LastUpdate = b.LU
				WHERE b.ProviderID IS NULL AND a.RecordEndDate IS NULL

				DROP TABLE #po
				DROP table #mp
    END;     



GO
