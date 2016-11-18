SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
-- Description:	merges the stage to dim for advance Provider based on spOECMergeProvider
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProvider
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProvider]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.Provider AS t
        USING
            ( SELECT    CentauriProviderID ,
                        LastName ,
                        FirstName ,
                        NPI
              FROM      stage.Provider_ADV
            ) AS s
        ON t.CentauriProviderID = s.CentauriProviderID
        WHEN MATCHED AND (ISNULL(t.LastName,'') <> ISNULL(s.LastName,'') OR ISNULL(t.FirstName,'') <> ISNULL(s.FirstName,'') OR ISNULL(t.NPI,'') <> ISNULL(s.NPI,'')) THEN
            UPDATE SET
                    t.LastName = s.LastName, 
				t.FirstName = s.FirstName,
				t.NPI = s.NPI,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriProviderID ,
                     LastName ,
				 FirstName ,
				 NPI 
                   )
            VALUES ( CentauriProviderID ,
                     LastName ,
				 FirstName ,
				 NPI 
                   );

    END;     
GO
