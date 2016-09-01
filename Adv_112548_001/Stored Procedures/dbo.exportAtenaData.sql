SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-19-2014
-- Description:	RA Coder will use this sp to pull diagnosis code description
-- =============================================
/*
INSERT INTO tmpExportChases
SELECT *,GetDate() QuickRAPSDate FROM tmpExportAtenaProvMemb 

SELECT COUNT(*) Charts,QuickRAPSDate FROM tmpExportChases GROUP BY QuickRAPSDate ORDER BY QuickRAPSDate DESC 
*/
--	exportAtenaData
CREATE PROCEDURE [dbo].[exportAtenaData]
AS
BEGIN
	RETRY: -- Label RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		--DROP TABLE #tmpIncomplete
		SELECT DISTINCT S.Suspect_PK--,S.Member_PK,ClD.DOS_Thru
		INTO #tmpIncomplete
		FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN tblClaimData ClD ON ClD.Member_PK = S.Member_PK-- AND ClD.DiagnosisCode<>''
			LEFT JOIN tblCodedData CD WITH (NOLOCK) ON CD.Suspect_PK = S.Suspect_PK AND ClD.DOS_Thru = CD.DOS_Thru AND IsNull(CD.Is_Deleted,0)=0
		WHERE IsCoded=1 AND CD.CodedData_PK IS NULL

		--DROP TABLE #Member
		SELECT DISTINCT TOP 500 S.Member_PK,S.Suspect_PK,P.Provider_PK,PM.Provider_ID [REN PROVIDER ID],M.Member_ID [MEMBER ID],M.HICNumber [Member Individual ID],M.ChaseID,M.REN_PROVIDER_SPECIALTY [PROVIDER TYPE],PM.TIN REN_TIN, PM.PIN REN_PIN,M.PID
		,'YHA'+Right(CAST(Year(S.dtCreated) AS VARCHAR),2)+Right('0'+CAST(Month(S.dtCreated) AS VARCHAR(2)),2)+'_01'+'_'+CAST(M.ChaseID AS varchar)+'_'+M.HICNumber+'_'+PM.Provider_ID [CHART NAME]
		INTO #Member 
		FROM tblCodedData CD 
			INNER JOIN tblSuspect S ON S.Suspect_PK = CD.Suspect_PK
			INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
			INNER JOIN tblModelCode MC ON MC.DiagnosisCode = CD.DiagnosisCode AND V12HCC IS NOT NULL
			LEFT JOIN tmpExportChases T ON T.Suspect_PK = S.Suspect_PK
			LEFT JOIN #tmpIncomplete N ON N.Suspect_PK = S.Suspect_PK
		WHERE T.Suspect_PK IS NULL AND N.Suspect_PK IS NULL AND IsNull(CD.Is_Deleted,0)=0
		--AND S.Suspect_PK IN (SELECT SUSPECT_PK FROM tmpExportAtenaProvMemb)
	
		--Coded Data
		-- DROP TABLE #tmp
		SELECT DISTINCT tM.[MEMBER ID],tM.[Member Individual ID],CAST('' AS VARCHAR(50)) [Claim ID],tM.[PROVIDER TYPE]
			,CAST(CD.DOS_From AS DATE) [SERVICE FROM DT], CAST(CD.DOS_Thru AS DATE) [SERVICE TO DT]
			,tM.[REN Provider ID],CD.DiagnosisCode [ICD Code],CASE WHEN MC.IsICD10=1 THEN '02' ELSE '01' END [DX CODE CATEGORY]
			,NT.NoteType [ICD CODE DISPOSITION]
			,IsNull(NTe.NoteText,'') [ICD CODE DISPOSITION REASON]
			,CD.OpenedPage [Page From],CD.OpenedPage [Page To],PID,REN_TIN,REN_PIN,[CHART NAME]
			,tM.Member_PK,tM.Suspect_PK,tM.ChaseID
			INTO #tmp
			FROM tblCodedData CD WITH (NOLOCK)  
				INNER JOIN #Member tM ON CD.Suspect_PK = tM.Suspect_PK
				INNER JOIN tblModelCode MC ON MC.DiagnosisCode = CD.DiagnosisCode AND V12HCC IS NOT NULL
				INNER JOIN tblNoteType NT WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK
				INNER JOIN tblCodedDataNote CDN WITH (NOLOCK) ON CDN.CodedData_PK = CD.CodedData_PK
				LEFT JOIN tblNoteText NTe ON NTe.NoteText_PK = CDN.NoteText_PK AND NT.NoteType_PK = NTe.NoteType_PK
			WHERE IsNull(CD.Is_Deleted,0)=0


		--Updating Claim ID WHERE DOS and Diag match with Historical data
		Update T SET [Claim ID] = CD.Claim_ID
			FROM #tmp T INNER JOIN tblClaimData CD ON CD.Member_PK = T.Member_PK AND T.[SERVICE TO DT]=CD.DOS_Thru AND T.[ICD Code] = CD.DiagnosisCode WHERE CD.DiagnosisCode<>''

		--If Diagnosis and DOS is not in the Historical claim then "DELETE" should not be sent
		DELETE FROM #tmp WHERE [Claim ID]='' AND [ICD CODE DISPOSITION]='Delete'
		--If Diagnosis and DOS is in the Historical claim then "ADD" should be "VALID" with no secondary comment
		Update #tmp SET [ICD CODE DISPOSITION]='Valid',[ICD CODE DISPOSITION REASON]='' WHERE [Claim ID]<>'' AND [ICD CODE DISPOSITION] IN ('Add','AddCC')
		--If Diagnosis and DOS is in the Historical claim then "VALID" should not have any secondary comment
		Update #tmp SET [ICD CODE DISPOSITION]='Valid',[ICD CODE DISPOSITION REASON]='' WHERE [Claim ID]<>'' AND [ICD CODE DISPOSITION] IN ('Valid')
		--If Diagnosis and DOS is NOT in the Historical claim then "VALID" should be "ADD" with no secondary comment
		Update #tmp SET [ICD CODE DISPOSITION]='Add',[ICD CODE DISPOSITION REASON]='' WHERE [Claim ID]='' AND [ICD CODE DISPOSITION] IN ('Valid')
		--If Diagnosis and DOS is NOT in the Historical claim AND [ICD CODE DISPOSITION] is  "DELETE" then secondary comment should be "Unsupported DX"
		Update #tmp SET [ICD CODE DISPOSITION REASON]='Unsupported DX' WHERE [ICD CODE DISPOSITION] IN ('Delete') AND [ICD CODE DISPOSITION REASON]<>'Unsupported DX'
		

		--Updating Claim ID WHERE DOS match with Historical data
		Update T SET [Claim ID] = CD.Claim_ID
			FROM #tmp T INNER JOIN tblClaimData CD ON CD.Member_PK = T.Member_PK AND T.[SERVICE TO DT]=CD.DOS_Thru WHERE [Claim ID]=''

		--Inserting DOSs which are present in Claim history:
		-- with Diagnosis Code which is coded but not found any HCC maped codes
		-- without Diagnosis Code but now we did not find a HCC mapped code or may be did not even coded in anything for the DOS
		INSERT INTO #tmp
		SELECT DISTINCT tM.[MEMBER ID],tM.[Member Individual ID],CD.Claim_ID [Claim ID],tM.[PROVIDER TYPE]
			,CAST(CD.DOS_From AS DATE) [SERVICE FROM DT], CAST(CD.DOS_Thru AS DATE) [SERVICE TO DT]
			,tM.[REN Provider ID],CD.DiagnosisCode [ICD Code],CASE WHEN MC.IsICD10=1 THEN '02' WHEN MC.IsICD10=0 THEN '01' ELSE '' END [DX CODE CATEGORY]
			,'Valid' [ICD CODE DISPOSITION]
			,'No HCC found' [ICD CODE DISPOSITION REASON]
			,0 [Page From],0 [Page To],tM.PID,tM.REN_TIN,tM.REN_PIN,tM.[CHART NAME]
			,tM.Member_PK,tM.Suspect_PK,tM.ChaseID
			FROM tblClaimData CD WITH (NOLOCK)  
				INNER JOIN #Member tM ON CD.Member_PK = tM.Member_PK
				LEFT JOIN tblModelCode MC ON MC.DiagnosisCode = CD.DiagnosisCode
				LEFT JOIN #tmp T ON T.Member_PK = CD.Member_PK AND T.[SERVICE TO DT]=CD.DOS_Thru
			WHERE T.Member_PK IS NULL

		Update #tmp set [ICD CODE DISPOSITION REASON]='' WHERE [ICD CODE DISPOSITION REASON]='Clinical Documentation Supports'

		--Drop Table #tmpFinal
		SELECT [MEMBER ID],[Member Individual ID],[Claim ID],[PROVIDER TYPE]
			,[SERVICE FROM DT], [SERVICE TO DT]
			,[REN Provider ID],UPPER([ICD Code]) [ICD Code],[DX CODE CATEGORY]
			,MAX([ICD CODE DISPOSITION]) [ICD CODE DISPOSITION]
			,MAX([ICD CODE DISPOSITION REASON]) [ICD CODE DISPOSITION REASON]
			,MAX([Page From]) [Page From],MAX([Page To]) [Page To],PID,REN_TIN,REN_PIN,[CHART NAME]
			,Member_PK,Suspect_PK,ChaseID
		INTO #tmpFinal FROM #tmp
		GROUP BY [MEMBER ID],[Member Individual ID],[Claim ID],[PROVIDER TYPE]
			,[SERVICE FROM DT], [SERVICE TO DT]
			,[REN Provider ID],[ICD Code],[DX CODE CATEGORY]
			,PID,REN_TIN,REN_PIN,[CHART NAME]
			,Member_PK,Suspect_PK,ChaseID

		--INSERT INTO #tmpIncomplete SELECT DIStINCT Suspect_PK FROM #tmpFinal Where [ICD CODE DISPOSITION]='ASR' AND [ICD CODE DISPOSITION REASON]=''
/*
SELECT * FROM #tmpFinal WHERE [ICD Code]<>'' AND [ICD CODE DISPOSITION]='VALID' AND [ICD CODE DISPOSITION REASON]='No HCC found'
SELECT * FROM #tmpFinal WHERE ChaseID='153127' AND [Claim ID]<>''
SELECT * FROM #tmp WHERE ChaseID='734344'
SELECT DISTINCT ChaseID FROM #Member WHERE [Member ID]='101_207171644' Suspect_PK=106699
SELECT DISTINCT ChaseID FROM #tmp
SELECT COUNT(DISTINCT [CHART NAME]) FROM tmpExportAtena
SELECT COUNT(DISTINCT [CHART NAME]) FROM tmpExportAtenaNoClaimID

DECLARE @ChaseID AS VARCHAR(20) = '37080'
DECLARE @Suspect AS INT
DECLARE @Member AS INT
SELECT @Suspect=Suspect_PK, @Member=Member_PK FROM #Member WHERE ChaseID=@ChaseID
SELECT * FROM #tmp WHERE ChaseID=@ChaseID ORDER BY [SERVICE To DT]
SELECT MC.V12HCC HCC,CD.DOS_Thru,CD.DiagnosisCode [Coded Code] FROM tblCodedData CD LEFT JOIN tblModelCode MC ON MC.DiagnosisCode=CD.DiagnosisCode WHERE Suspect_PK=@Suspect ORDER BY DOS_Thru
SELECT MC.V12HCC HCC ,CD.DOS_Thru,CD.DiagnosisCode [Historical Code] FROM tblClaimData CD LEFT JOIN tblModelCode MC ON MC.DiagnosisCode=CD.DiagnosisCode WHERE Member_PK=@Member ORDER BY DOS_Thru
*/

		--QuickRAPS
		DROP TABLE tmpExportAtena
		SELECT [MEMBER ID],[Member Individual ID],[Claim ID],[PROVIDER TYPE]
			,[SERVICE FROM DT], [SERVICE TO DT]
			,[REN Provider ID],[ICD Code],[DX CODE CATEGORY]
			,[ICD CODE DISPOSITION]
			,[ICD CODE DISPOSITION REASON]
			,[Page From],[Page To],REN_TIN,REN_PIN,PID,[CHART NAME]
		INTO tmpExportAtena
		FROM #tmpFinal
		WHERE [Claim ID]<>''
		
		DROP TABLE tmpExportAtenaNoClaimID
		SELECT [MEMBER ID],[Member Individual ID],[Claim ID],[PROVIDER TYPE]
			,[SERVICE FROM DT], [SERVICE TO DT]
			,[REN Provider ID],[ICD Code],[DX CODE CATEGORY]
			,[ICD CODE DISPOSITION]
			,[ICD CODE DISPOSITION REASON]
			,[Page From],[Page To],REN_TIN,REN_PIN,PID,[CHART NAME]
		INTO tmpExportAtenaNoClaimID
		FROM #tmpFinal
		WHERE [Claim ID]=''
		
		DROP TABLE tmpExportAtenaProvMemb	
		SELECT DISTINCT [Member ID],[Member Individual ID],[REN Provider ID],Member_PK,Suspect_PK,[CHART NAME],ChaseID,MAX(CASE WHEN [Claim ID]='' THEN 1 ELSE 0 END) InDummy,MAX(CASE WHEN [Claim ID]<>'' THEN 1 ELSE 0 END) InNormal
		INTO tmpExportAtenaProvMemb
		FROM #tmpFinal T
		GROUP BY [Member ID],[Member Individual ID],[REN Provider ID],Member_PK,Suspect_PK,[CHART NAME],ChaseID
	
		DROP TABLE #tmp
		DROP TABLE #tmpFinal
		DROP TABLE #Member
		DROP TABLE #tmpIncomplete

/*
SELECT COUNT(*),[ICD CODE DISPOSITION],[ICD CODE DISPOSITION REASON] FROM tmpExportAtena GROUP BY [ICD CODE DISPOSITION],[ICD CODE DISPOSITION REASON] ORDER BY [ICD CODE DISPOSITION]
SELECT COUNT(*),[ICD CODE DISPOSITION],[ICD CODE DISPOSITION REASON] FROM tmpExportAtenaNoClaimID GROUP BY [ICD CODE DISPOSITION],[ICD CODE DISPOSITION REASON] ORDER BY [ICD CODE DISPOSITION]
SELECT COUNT(DISTINCT [CHART NAME]),Count(*) FROM tmpExportAtena
SELECT COUNT(DISTINCT [CHART NAME]),Count(*) FROM tmpExportAtenaNoClaimID
*/

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT 
		   ERROR_MESSAGE() AS ErrorMessage,
			ERROR_NUMBER() AS ErrorNumber		
		PRINT 'Rollback Transaction'
		ROLLBACK TRANSACTION
		IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
		BEGIN
			WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
			GOTO RETRY -- Go to Label RETRY
		END
	END CATCH
END


/*
SELECT * FROM tblSuspect WHERE Suspect_PK=106699
SELECT * FROM tblMember WHERE Member_PK=168138
SELECT * FROM tmpExportAtena WHEre [Member ID]='101_207522056'
SELECT * FROM tmpExportAtenaNoClaimID WHEre [Member ID]='101_207522056'
*/
GO
