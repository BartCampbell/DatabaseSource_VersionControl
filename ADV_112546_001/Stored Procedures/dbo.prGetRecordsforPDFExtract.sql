SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prGetRecordsforPDFExtract]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--LOADED MEMBERS THAT HAVE IMAGES

SELECT DISTINCT M.Lastname+', '+M.Firstname Member,[Member ID],[Member Individual ID],[REN Provider ID],S.Member_PK,S.Suspect_PK,[CHART NAME] AS 'CHARTNAME',S.ChaseID,InDummy,InNormal 
FROM tmpExportChartStaging S INNER JOIN tblMember M ON S.Member_PK = M.Member_PK
WHERE S.Suspect_PK IN (

SELECT Distinct SD.Suspect_PK FROM tblScannedData SD 
INNER JOIN tblSuspect S ON S.Suspect_PK=SD.Suspect_PK 
WHERE IsNull(SD.is_deleted,0)=0 AND SD.DocumentType_PK<>99 AND S.IsScanned=1 
--AND s.suspect_pk='8240'
) 

--IMAGES
SELECT SD.ScannedData_PK, SD.Suspect_PK,sd.DocumentType_PK, sd.FileName, sd.User_PK, sd.dtInsert, sd.is_deleted, sd.CodedStatus, S.Provider_PK,S.Project_PK 

FROM tblScannedData SD INNER JOIN tmpExportChartStaging T ON T.Suspect_PK = SD.Suspect_PK 
INNER JOIN tblSuspect S ON S.Suspect_PK=SD.Suspect_PK
 WHERE IsNull(SD.is_deleted,0)=0 AND SD.DocumentType_PK<>99 AND S.IsScanned=1 
-- AND s.suspect_pk='8240'

ORDER By SD.Suspect_PK,CAST(LEFT(RIGHT(Filename,LEN(Filename)-CharIndex('_'+CAST(SD.DocumentType_PK AS VARCHAR)+'_',Filename)-2),CharIndex('_',RIGHT(Filename,LEN(Filename)-CharIndex('_'+CAST(SD.DocumentType_PK AS VARCHAR)+'_',Filename)-2))-1) AS VARCHAR);


END


--SELECT * FROM dbo.tblSuspect WHERE Suspect_PK='8240'




GO
