SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	11/14/2016
-- Description:	merges the stage to dim for Provider
-- Usage:			
--		  EXECUTE dbo.spHEDISMergeProvider
-- =============================================
CREATE PROC [dbo].[spHEDISMergeProvider]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.Provider AS t
        USING
            ( SELECT  CentauriProviderID ,
                               MAX(LastName) AS LastName ,
                               MAX(FirstName) AS FirstName ,
                               MAX(NPI) AS NPI ,
                               MAX(TIN) AS TIN ,
                               MAX(TINName) AS TINName
              FROM      stage.Provider_HEDIS
		    GROUP BY CentauriProviderID
            ) AS s
        ON t.CentauriProviderID = s.CentauriProviderID
    --    WHEN MATCHED AND (ISNULL(t.LastName,'') <> ISNULL(s.LastName,'') OR ISNULL(t.FirstName,'') <> ISNULL(s.FirstName,'') OR ISNULL(t.NPI,'') <> ISNULL(s.NPI,'') OR ISNULL(t.TIN,'') <> ISNULL(s.TIN,'') OR ISNULL(t.TINName,'') <> ISNULL(s.TINName,'')) THEN
    --        UPDATE SET
    --                t.LastName = s.LastName, 
				--t.FirstName = s.FirstName,
				--t.NPI = s.NPI,
				--t.TIN = s.TIN,
				--t.TINName = s.TINName ,
    --                t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriProviderID ,
                     LastName ,
				 FirstName ,
				 NPI ,
				 TIN ,
				 TINName
                   )
            VALUES ( s.CentauriProviderID ,
                     s.LastName ,
				 s.FirstName ,
				 s.NPI ,
				 s.TIN ,
				 s.TINName
                   );

    END;     

GO
