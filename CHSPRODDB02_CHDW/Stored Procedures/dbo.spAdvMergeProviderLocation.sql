SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
--Upate 09/29/2016 adding city,state county PJ
-- Description:	merges the stage to dim for advance ProviderLocation based on spOECMergeProviderLocation
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProviderLocation
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProviderLocation]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ProviderLocation AS t
        USING
            ( SELECT    DISTINCT o.ProviderID ,
                        a.Addr1 ,
                        a.Zip ,
						z.City,
						z.[State],
						z.County
              FROM      stage.ProviderLocation_ADV a 
			  INNER JOIN dim.ProviderOffice o ON a.CentauriProviderOfficeID = o.CentauriProviderOfficeID
			  LEFT OUTER JOIN dim.ZipCode z ON a.Zip = z.ZipCode
		     ) AS s
        ON t.ProviderID = s.ProviderID AND ISNULL(t.Addr1,'') = ISNULL(s.Addr1,'') AND ISNULL(t.Zip,'') = ISNULL(s.Zip,'')
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ProviderID ,
                     Addr1 ,
				 	 Zip ,
					 City,
					[State],
					County
                   )
            VALUES ( ProviderID ,
                     Addr1 ,
				 Zip,
				  City,
					[State],
					County
                   );

    END;     


GO
