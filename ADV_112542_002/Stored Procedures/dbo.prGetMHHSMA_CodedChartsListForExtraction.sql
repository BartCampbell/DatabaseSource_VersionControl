SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 10/28/2016
-- Description:	Pulls the latest batch of coded chart information for the MHHS MA extract
-- =============================================
CREATE PROCEDURE [dbo].[prGetMHHSMA_CodedChartsListForExtraction]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#MHHSTemp') IS NOT NULL DROP TABLE #MHHSTemp
                 
--TRUNCATE TABLE MHHS_ChartExtract

SELECT distinct mem.Member_ID AS [MEMBERID]
, claim.Claim_ID AS [CLAIMID],
sus.REN_PROVIDER_SPECIALTY AS [PROVIDERTYPE],
claim.DOS_From AS [SERVICEFROMDATE],
claim.DOS_Thru AS [SERVICETODATE],
provmas.NPI AS [RENDERINGPROVIDERID],
code.DiagnosisCode AS [ICDCODE],
 CASE   
      WHEN code.DOS_From > '9/30/2015' THEN '02'
	  WHEN code.DOS_From < '10/01/2015' THEN '01'
END AS [DXCODECATEGORY],
code.OpenedPage AS [PAGEFROM],
code.OpenedPage AS [PAGETO],
provmas.TIN AS [REN_TIN],
provmas.PIN AS [REN_PIN]
,sus.CHASEID
,sus.ChaseID+'_'+mem.Member_ID+'_MHHS_RAPS_CHART' AS [CHART NAME]
,sus.Suspect_PK
,mem.Member_PK
INTO #MHHSTemp
--INTO MHHS_ChartExtract
FROM dbo.tblMember mem
INNER JOIN dbo.tblSuspect sus ON sus.Member_PK = mem.Member_PK
INNER JOIN dbo.tblCodedData code ON code.Suspect_PK = sus.Suspect_PK
INNER JOIN dbo.tblClaimData claim ON claim.Suspect_PK = sus.Suspect_PK
INNER JOIN dbo.tblProvider prov ON prov.Provider_PK = sus.Provider_PK
INNER JOIN dbo.tblProviderMaster provmas ON provmas.ProviderMaster_PK = prov.ProviderMaster_PK
WHERE sus.ChaseID+':'+mem.Member_ID+':'+code.DiagnosisCode NOT IN (SELECT DISTINCT ChaseID+':'+MEMBERID+':'+ICDCode FROM MHHS_ChartExtract)

--TRUNCATE TABLE MHHS_ChartExtract
--select distinct [CHART NAME] from MHHS_ChartExtract
--drop table MHHS_ChartExtract
 
INSERT INTO MHHS_ChartExtract
SELECT * FROM #MHHSTemp



--LOADED MEMBERS THAT HAVE IMAGES
SELECT DISTINCT M.Lastname+', '+M.Firstname Member,[MemberID],S.Member_PK,S.Suspect_PK,[CHART NAME]AS [CHARTNAME],S.ChaseID,
s.claimID, s.[PROVIDERTYPE],s.[SERVICEFROMDATE], s.[SERVICETODATE]
,s.[RENDERINGPROVIDERID],s.[ICDCODE], s.[DXCODECATEGORY], s.[PAGEFROM], s.[PAGETO], s.[REN_TIN],s.[REN_PIN]
FROM #MHHSTemp S INNER JOIN tblMember M ON S.Member_PK = M.Member_PK
WHERE S.Suspect_PK IN (

SELECT Distinct SD.Suspect_PK FROM tblScannedData SD Inner JOIN #MHHSTemp T ON T.Suspect_PK = SD.Suspect_PK 
INNER JOIN tblSuspect S ON S.Suspect_PK=SD.Suspect_PK 
WHERE IsNull(SD.is_deleted,0)=0 AND SD.DocumentType_PK<>99 AND S.IsScanned=1
) 


--IMAGES
SELECT SD.ScannedData_PK, SD.Suspect_PK,sd.DocumentType_PK, sd.FileName, sd.User_PK, sd.dtInsert, sd.is_deleted, sd.CodedStatus, S.Provider_PK,S.Project_PK 

FROM tblScannedData SD INNER JOIN #MHHSTemp T ON T.Suspect_PK = SD.Suspect_PK 
INNER JOIN tblSuspect S ON S.Suspect_PK=SD.Suspect_PK WHERE IsNull(SD.is_deleted,0)=0 AND SD.DocumentType_PK<>99 
GROUP BY SD.ScannedData_PK, SD.Suspect_PK,sd.DocumentType_PK, sd.FileName, sd.User_PK, sd.dtInsert, sd.is_deleted, sd.CodedStatus, S.Provider_PK,S.Project_PK 
ORDER By SD.Suspect_PK,CAST(LEFT(RIGHT(Filename,LEN(Filename)-CharIndex('_'+CAST(SD.DocumentType_PK AS VARCHAR)+'_',Filename)-2),CharIndex('_',RIGHT(Filename,LEN(Filename)-CharIndex('_'+CAST(SD.DocumentType_PK AS VARCHAR)+'_',Filename)-2))-1) AS VARCHAR);



END
GO
