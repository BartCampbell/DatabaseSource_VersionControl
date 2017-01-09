SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ============================================= 
-- Author:		Jason Franks 
-- Create date: 7/21/2016 
-- Description:	<Description,,> 
-- ============================================= 
CREATE PROCEDURE [dbo].[prCopyHistorytotmpExportChases] 
	-- Add the parameters for the stored procedure here 
AS 
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from 
	-- interfering with SELECT statements. 
	SET NOCOUNT ON; 
 
		INSERT INTO tmpExportChases 
		SELECT [Member ID], [Member Individual ID], [REN Provider ID], T.Member_PK, T.Suspect_PK, [CHART NAME],T.ChaseID, InDummy, InNormal, CONVERT(varchar(8), getdate(), 112)  
		FROM tmpExportChartStaging T 
		INNER JOIN tblScannedData SD ON T.Suspect_PK = SD.Suspect_PK  
		INNER JOIN tblSuspect S ON S.Suspect_PK=SD.Suspect_PK  
		WHERE IsNull(SD.is_deleted,0)=0 AND SD.DocumentType_PK<>99 AND S.IsScanned=1 AND S.Channel_PK=10 
		GROUP BY [Member ID], [Member Individual ID], [REN Provider ID], T.Member_PK, T.Suspect_PK, [CHART NAME],T.ChaseID, InDummy, InNormal 
 
					 
END 
GO
