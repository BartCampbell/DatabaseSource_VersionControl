SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	10/25/2016
-- Description:	merges the stage to dim for advance ProviderOfficeLocation based on spAdvMergeProviderLocation
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProviderOfficeLocation
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProviderOfficeLocation]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ProviderOfficeLocation AS t
        USING
            ( SELECT    DISTINCT o.ProviderOfficeID ,
                        a.Addr1 ,
                        a.Zip ,
						z.City,
						z.[State],
						z.County
		       FROM      stage.ProviderLocation_ADV a 
			  INNER JOIN dim.ProviderOffice o ON a.CentauriProviderOfficeID = o.CentauriProviderOfficeID
			  LEFT OUTER JOIN dim.ZipCode z ON a.Zip = z.ZipCode
		     ) AS s
        ON t.ProviderOfficeID = s.ProviderOfficeID AND ISNULL(t.Addr1,'') = ISNULL(s.Addr1,'') AND ISNULL(t.Zip,'') = ISNULL(s.Zip,'')
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ProviderOfficeID ,
                     Addr1 ,
				 	 Zip ,
					 City,
					[State],
					County
                   )
            VALUES ( ProviderOfficeID ,
                     Addr1 ,
				 Zip,
				  City,
					[State],
					County
                   );

    END;     


GO
