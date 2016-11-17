SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [raps].[spGetClientID]
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT TOP 1
            ClientID
    FROM    ( SELECT TOP 1
                        m.ClientID ,
                        0 AS rownum
              FROM      raps.RAPS_RESPONSE_BBB b
                        INNER JOIN raps.ClientPlanMap m ON m.PlanNo = b.PlanNo
              UNION
              SELECT    0 AS ClientID ,
                        1 AS rownum
            ) t
    ORDER BY t.rownum;


GO
