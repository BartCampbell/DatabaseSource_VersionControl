SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	07/21/2016
-- Description:	merges the stage to dim for Provider
-- Usage:			
--		  EXECUTE dbo.sp834MergeProvider
-- =============================================
CREATE PROC [dbo].[sp834MergeProvider]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.Provider AS t
        USING
            ( SELECT    CentauriProviderID ,
                        MAX(LastName) AS LastName ,
                        MAX(FirstName) AS FirstName 
              FROM      stage.Provider
		    GROUP BY CentauriProviderID
            ) AS s
        ON t.CentauriProviderID = s.CentauriProviderID
        WHEN MATCHED AND ( t.LastName <> s.LastName OR t.FirstName <> s.FirstName
                         ) THEN
            UPDATE SET
                    t.LastName = s.LastName,
				t.FirstName = s.FirstName,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriProviderID ,
                     LastName ,
				 FirstName ,
				 CreateDate ,
				 LastUpdate
                   )
            VALUES ( CentauriProviderID ,
                     s.LastName,
				 s.FirstName,
				 @CurrentDate,
				 @CurrentDate
                   );

    END;     


GO
