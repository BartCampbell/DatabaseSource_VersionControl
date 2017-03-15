SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	07/18/2016
-- Description:	returns the ClientID and ClientDB from the 834 staging table
-- Usage:			
--		  EXECUTE dbo.spGetClientID
-- =============================================
CREATE PROC [dbo].[spGetClientID]
AS
    SET NOCOUNT ON;
    
    
    SELECT DISTINCT
            h.CentauriClientID,
		  'CHSDV_' + CONVERT(VARCHAR(10),h.CentauriClientID ) AS ClientDB
    FROM    dbo.X12_834_RawImport i
            INNER JOIN ETLConfig.dbo.TradingPartnerFile t ON i.FileLevelDetail_SenderID_GS02 = t.SenderID
                                                   AND i.FileLevelDetail_ReceiverID_GS03 = t.ReceiverID
            INNER JOIN CHSDV.dbo.R_Client h ON t.TradingPartner = h.ClientName;

GO
