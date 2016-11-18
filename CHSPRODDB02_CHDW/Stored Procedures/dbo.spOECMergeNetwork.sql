SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to dim for Network
-- Usage:			
--		  EXECUTE dbo.spOECMergeNetwork
-- =============================================
CREATE PROC [dbo].[spOECMergeNetwork]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.Network AS t
        USING
            ( SELECT    CentauriNetworkID ,
                        Network ,
                        NetworkName
              FROM      stage.Network
            ) AS s
        ON t.CentauriNetworkID = s.CentauriNetworkID
        WHEN MATCHED AND ( t.Network <> s.Network
                           OR t.NetworkName <> s.NetworkName
                         ) THEN
            UPDATE SET
                    t.Network = s.Network ,
                    t.NetworkName = s.NetworkName ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriNetworkID ,
                     Network ,
                     NetworkName 
                   )
            VALUES ( CentauriNetworkID ,
                     Network ,
                     NetworkName 
                   );

    END;     

GO
