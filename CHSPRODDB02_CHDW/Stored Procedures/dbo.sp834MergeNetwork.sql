SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	07/21/2016
-- Description:	merges the stage to dim for Network
-- Usage:			
--		  EXECUTE dbo.sp834MergeNetwork
-- =============================================
CREATE PROC [dbo].[sp834MergeNetwork]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.Network AS t
        USING
            ( SELECT    CentauriNetworkID ,
                        Network 
              FROM      stage.Network
            ) AS s
        ON t.CentauriNetworkID = s.CentauriNetworkID
        WHEN MATCHED AND ( t.Network <> s.Network
                         ) THEN
            UPDATE SET
                    t.Network = s.Network,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriNetworkID ,
                     Network ,
				 CreateDate ,
				 LastUpdate
                   )
            VALUES ( CentauriNetworkID ,
                     s.Network,
				 @CurrentDate,
				 @CurrentDate
                   );

    END;     


GO
