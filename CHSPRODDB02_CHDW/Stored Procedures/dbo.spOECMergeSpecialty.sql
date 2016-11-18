SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to dim for Specialty
-- Usage:			
--		  EXECUTE dbo.spOECMergeSpecialty
-- =============================================
CREATE PROC [dbo].[spOECMergeSpecialty]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.Specialty AS t
        USING
            ( SELECT DISTINCT   ProviderTypeDesc
              FROM      stage.Specialty
            ) AS s
        ON t.ProviderTypeDesc = s.ProviderTypeDesc
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ProviderTypeDesc
                   )
            VALUES ( ProviderTypeDesc
                   );

    END;     
GO
