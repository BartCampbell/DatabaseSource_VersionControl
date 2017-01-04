SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
--Udpate 10/04/2016 Removing update PJ
--Update 12/28/2016 Adding OfficeLocation and OfficeContact PJ
-- Description:	merges the stage to dim for advance ProviderOffice based on spOECMergeProvider
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProviderOffice
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProviderOffice]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN

	
        MERGE INTO dim.ProviderOffice AS t
        USING
            ( SELECT    DISTINCT
                        m.ProviderID ,
                        a.CentauriProviderOfficeID ,
                        a.CentauriProviderID
				    FROM      stage.ProviderOffice_ADV a
                        INNER JOIN dim.Provider m ON m.CentauriProviderID = a.CentauriProviderID
            ) AS s
        ON t.CentauriProviderOfficeID = s.CentauriProviderOfficeID AND t.CentauriProviderID = s.CentauriProviderID
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ProviderID ,
                     CentauriProviderOfficeID ,
                     CentauriProviderID 
                   )
            VALUES ( ProviderID ,
                     CentauriProviderOfficeID ,
                     CentauriProviderID
                   );


    MERGE INTO dim.OfficeLocation AS t
        USING
            ( SELECT    DISTINCT  
                        a.Addr1 ,
						a.Addr2,
                        a.Zip ,
						z.City,
						z.[State],
						z.County
		       FROM      stage.ProviderLocation_ADV a 
				  LEFT OUTER JOIN dim.ZipCode z ON a.Zip = z.ZipCode
		     ) AS s
        ON  ISNULL(t.Addr1,'') = ISNULL(s.Addr1,'') AND ISNULL(t.Zip,'') = ISNULL(s.Zip,'')
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( Addr1 ,
					 Addr2,
				 	 Zip ,
					 City,
					[State],
					County
                   )
            VALUES ( 
                     Addr1 ,
					 Addr2,
					Zip,
					City,
					[State],
					County
                   );

				   
		UPDATE pl
		SET pl.OfficeLocationID = o.OfficeLocationID
		FROM  stage.ProviderLocation_ADV pl
		INNER JOIN dim.OfficeLocation o
		ON ISNULL(o.Addr1,'') = ISNULL(pl.Addr1,'') AND ISNULL(o.Zip,'') = ISNULL(pl.Zip,'')


		UPDATE po
		SET po.OfficeLocationID=pl.OfficeLocationID, po.LastUpdate=@CurrentDate
		FROM dim.ProviderOffice po
		INNER JOIN  stage.ProviderLocation_ADV pl
		ON pl.CentauriProviderOfficeID = po.CentauriProviderOfficeID AND ISNULL(pl.OfficeLocationID,'') <> ISNULL(po.OfficeLocationID,'')
		 

		  MERGE INTO dim.OfficeContact AS t
        USING
            ( SELECT   DISTINCT  a.Phone ,
                        a.Fax,
						a.EmailAddress
                FROM      stage.ProviderContact_ADV a
			    
		    
            ) AS s
        ON  ISNULL(t.Phone,'') = ISNULL(s.Phone,'')
            AND ISNULL(t.Fax,'') = ISNULL(s.Fax,'')
			AND ISNULL(t.EmailAddress,'') = ISNULL( s.EmailAddress,'')
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (  Phone, Fax, EmailAddress )
            VALUES (  Phone, Fax, EmailAddress );

			
		UPDATE pc
			SET pc.OfficeContactId = oc.OfficeContactID
			FROM stage.ProviderContact_ADV pc
			INNER JOIN dim.OfficeContact oc
			ON ISNULL(oc.EmailAddress,'') = ISNULL(pc.EmailAddress,'') AND ISNULL(oc.Fax,'') = ISNULL(pc.Fax,'') AND ISNULL(oc.Phone ,'') = ISNULL(pc.Phone,'')

		UPDATE po
		SET po.OfficeContactID=pl.OfficeContactId, po.LastUpdate=@CurrentDate
		FROM dim.ProviderOffice po
		INNER JOIN  stage.ProviderContact_ADV pl
		ON pl.CentauriProviderOfficeID = po.CentauriProviderOfficeID AND ISNULL(pl.OfficeContactId,'') <> ISNULL(po.OfficeContactID,'')
		


				SELECT ProviderOfficeID INTO #po FROM dim.ProviderOffice GROUP BY ProviderOfficeID 
				
				SELECT a.ProviderOfficeID,MAX(a.LastUpdate) AS LU INTO #mp
					FROM dim.ProviderOffice  a 
				GROUP BY a.ProviderOfficeID

				UPDATE a
				SET a.RecordEndDate = NULL
				FROM dim.ProviderOffice  a 
				INNER JOIN #mp b
				ON b.ProviderOfficeID = a.ProviderOfficeID AND a.LastUpdate = b.LU
				WHERE a.RecordEndDate IS NOT NULL

				UPDATE a
				SET a.RecordEndDate = @CurrentDate
				FROM dim.ProviderOffice  a 
				LEFT OUTER JOIN #mp b
				ON b.ProviderOfficeID = a.ProviderOfficeID AND a.LastUpdate = b.LU
				WHERE b.ProviderOfficeID IS NULL AND a.RecordEndDate IS NULL

				DROP TABLE #po
				DROP table #mp



    END;     
	

GO
