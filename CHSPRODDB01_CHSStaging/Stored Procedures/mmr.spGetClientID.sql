SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	07/28/2016
-- Description:	returns the ClientID and ClientDB from the MMR staging table
-- Usage:			
--		  EXECUTE mmr.spGetClientID
-- =============================================
CREATE PROC [mmr].[spGetClientID]
AS
    SET NOCOUNT ON;


    SELECT TOP 1
            t.ClientID ,
            'CHSDV_' + CONVERT(VARCHAR(10), t.ClientID) AS ClientDB
    FROM    ( SELECT TOP 1
                        m.ClientID ,
                        0 AS rownum
              FROM      mmr.MMR_Stage s
                        INNER JOIN dbo.ClientPlanMap m ON m.PlanNo = s.MCO_Contract_Nbr
                                                                    AND m.Process = 'MMR'
              UNION
              SELECT    0 AS ClientID ,
                        1 AS rownum
            ) t
    ORDER BY t.rownum;


GO
