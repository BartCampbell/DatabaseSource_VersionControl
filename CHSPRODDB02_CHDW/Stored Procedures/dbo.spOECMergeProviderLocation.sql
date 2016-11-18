SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to dim for ProviderLocation
-- Usage:			
--		  EXECUTE dbo.spOECMergeProviderLocation
-- =============================================
CREATE PROC [dbo].[spOECMergeProviderLocation]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ProviderLocation AS t
        USING
            ( SELECT    p.ProviderID ,
                        s.Addr1 ,
                        s.City ,
                        s.State ,
                        s.Zip 
              FROM      stage.ProviderLocation s 
		    INNER JOIN dim.Provider p ON p.CentauriProviderID = s.CentauriProviderID
            ) AS s
        ON t.ProviderID = s.ProviderID AND t.Addr1 = s.Addr1 AND t.City = s.City AND t.State = s.State AND t.Zip = s.Zip
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ProviderID ,
                     Addr1 ,
				 City ,
				 State ,
				 Zip 
                   )
            VALUES ( ProviderID ,
                     Addr1 ,
				 City ,
				 State ,
				 Zip
                   );

    END;     


GO
