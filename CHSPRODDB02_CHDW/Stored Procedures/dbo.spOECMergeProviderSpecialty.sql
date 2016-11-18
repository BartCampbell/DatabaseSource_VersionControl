SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to dim for ProviderSpecialty
-- Usage:			
--		  EXECUTE dbo.spOECMergeProviderSpecialty
-- =============================================
CREATE PROC [dbo].[spOECMergeProviderSpecialty]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ProviderSpecialty AS t
        USING
            ( SELECT    p.ProviderID ,
                        s.SpecialtyID
              FROM      stage.ProviderSpecialty sp
                        INNER JOIN dim.Specialty s ON sp.Specialty = s.ProviderTypeDesc
                        INNER JOIN dim.Provider p ON p.CentauriProviderID = sp.CentauriProviderID
            ) AS s
        ON t.ProviderID = s.ProviderID
            AND t.SpecialtyID = s.SpecialtyID
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ProviderID ,
                     SpecialtyID
                   )
            VALUES ( ProviderID ,
                     SpecialtyID
                   );

    END;     


GO
