SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	10/06/2016
-- Description:	merges the stage to dim for client
-- Usage:			
--		  EXECUTE dbo.spHEDISMergeClient
-- =============================================
CREATE PROC [dbo].[spHEDISMergeClient]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.Client AS t
        USING
            ( SELECT    CentauriClientID ,
                        ClientName
              FROM      stage.Client_HEDIS
            ) AS s
        ON t.CentauriClientID = s.CentauriClientID
        WHEN MATCHED AND t.ClientName <> s.ClientName THEN
            UPDATE SET
                    t.ClientName = s.ClientName, 
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriClientID ,
                     ClientName ,
                     Description
                   )
            VALUES ( CentauriClientID ,
                     ClientName ,
                     ClientName
                   );

    END;     

GO
