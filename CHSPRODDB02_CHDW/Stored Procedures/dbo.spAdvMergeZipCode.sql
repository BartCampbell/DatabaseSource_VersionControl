SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
--update to match on zipcode (not centaurizipcode) PJ
-- Description:	merges the stage to dim for ZipCode for advance
-- Usage:			
--		  EXECUTE dbo.spAdvMergeZipCode
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeZipCode]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ZipCode AS t
        USING
            ( SELECT    [CentauriZipCodeID] ,
                        [ZipCode] ,
                        [City] ,
                        [State] ,
                        [County] ,
                        [Latitude] ,
                        [Longitude]
              FROM      stage.ZipCode_ADV
            ) AS s
        ON t.ZipCode = s.ZipCode
        WHEN MATCHED AND ( ISNULL(t.[ZipCode], '') <> ISNULL(s.[ZipCode], '')
                           OR ISNULL(t.[City], '') <> ISNULL(s.[City], '')
                           OR ISNULL(t.[State], '') <> ISNULL(s.[State], '')
                           OR ISNULL(t.[County], '') <> ISNULL(s.[County], '')
                           OR ISNULL(t.[Latitude], '') <> ISNULL(s.[Latitude],
                                                              '')
                           OR ISNULL(t.[Longitude], '') <> ISNULL(s.[Longitude],
                                                              '')
                         ) THEN
            UPDATE SET
                    t.[CentauriZipCodeID] = s.[CentauriZipCodeID] ,
                    t.[ZipCode] = s.[ZipCode] ,
                    t.[City] = s.[City] ,
                    t.[State] = s.[State] ,
                    t.[County] = s.[County] ,
                    t.[Latitude] = s.[Latitude] ,
                    t.[Longitude] = s.[Longitude] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriZipCodeID] ,
                     [ZipCode] ,
                     [City] ,
                     [State] ,
                     [County] ,
                     [Latitude] ,
                     [Longitude]
                     
                   )
            VALUES ( [CentauriZipCodeID] ,
                     [ZipCode] ,
                     [City] ,
                     [State] ,
                     [County] ,
                     [Latitude] ,
                     [Longitude]
                   );

    END;     


GO
