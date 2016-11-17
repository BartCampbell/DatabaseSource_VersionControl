SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	07/25/2016
-- Description:	returns the ClientID and ClientDB from the MOR staging table
-- Usage:			
--		  EXECUTE mor.spGetClientID
-- =============================================
CREATE PROC [mor].[spGetClientID]
AS
    SET NOCOUNT ON;


    SELECT TOP 1
            t.ClientID,
		  'CHSDV_' + CONVERT(VARCHAR(10),t.ClientID ) AS ClientDB
    FROM    ( SELECT TOP 1
                        m.ClientID ,
                        0 AS rownum
              FROM      mor.MOR_Header_Stage s
                        INNER JOIN ETLConfig.dbo.ClientPlanMap m ON m.PlanNo = s.ContractNumber AND m.Process = 'MOR'
              UNION
              SELECT    0 AS ClientID ,
                        1 AS rownum
            ) t
    ORDER BY t.rownum;


GO
