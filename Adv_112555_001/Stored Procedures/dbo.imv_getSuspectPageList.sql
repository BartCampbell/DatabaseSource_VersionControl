SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	imv_getSuspectPageList 38429,0,0
CREATE PROCEDURE [dbo].[imv_getSuspectPageList] 
	@Suspect bigint,
	@is_admin bit,
	@AllMemberChartsInViewer bit,
	@User INT,
	@QA SmallInt
AS
BEGIN
	DECLARE @level AS tinyint
	SELECT @level=CoderLevel FROM tblUser WITH (NOLOCK) WHERE User_PK=@User

	SELECT S.Suspect_PK,M.Member_ID,M.Lastname+', '+M.Firstname MemberName,DOB,S.Scanned_Date,S.Scanned_User_PK
	FROM tblMember M INNER JOIN tblSuspect S ON S.Member_PK=M.Member_PK
	WHERE S.Suspect_PK=@Suspect

	If (@AllMemberChartsInViewer=0)
	BEGIN
		SELECT SD.ScannedData_PK --,IsNull(DocumentType,CAST(Month(SD.dtInsert) AS VARCHAR)+'-'+CAST(Day(SD.dtInsert) AS VARCHAR)+'-'+CAST(Year(SD.dtInsert) AS VARCHAR)) DocumentType, SD.DocumentType_PK
			,SD.is_deleted,SDPS.PageStatus_PK CodedStatus,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider_Name,SD.Suspect_PK
		FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblScannedData SD WITH (NOLOCK) ON SD.Suspect_PK = S.Suspect_PK
			LEFT JOIN tblScannedDataPageStatus SDPS WITH (NOLOCK) ON SDPS.ScannedData_PK =  SD.ScannedData_PK AND SDPS.CoderLevel = @level
		WHERE S.Suspect_PK=@Suspect 
			AND (@is_admin=1 OR ISNULL(SD.is_deleted,0)=0)
		ORDER BY DocumentType_PK
			,--CASE WHEN ISNUMERIC(LEFT(RIGHT(Filename,LEN(Filename)-CharIndex('_'+CAST(SD.DocumentType_PK AS VARCHAR)+'_',Filename)-2),CharIndex('_',RIGHT(Filename,LEN(Filename)-CharIndex('_'+CAST(SD.DocumentType_PK AS VARCHAR)+'_',Filename)-2))-1))=0 THEN
				SD.ScannedData_PK
			--ELSE
			--	CAST(LEFT(RIGHT(Filename,LEN(Filename)-CharIndex('_'+CAST(SD.DocumentType_PK AS VARCHAR)+'_',Filename)-2),CharIndex('_',RIGHT(Filename,LEN(Filename)-CharIndex('_'+CAST(SD.DocumentType_PK AS VARCHAR)+'_',Filename)-2))-1) AS INT)
			--END ASC
	END
	ELSE
	BEGIN
		SELECT M.Suspect_PK,M.Provider_PK INTO #tmpSuspect FROM tblSuspect S INNER JOIN tblSuspect M ON M.Member_PK=S.Member_PK WHERE S.Suspect_PK=@Suspect AND S.IsScanned=1

		SELECT SD.ScannedData_PK,SD.is_deleted,SDPS.PageStatus_PK CodedStatus,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider_Name,SD.Suspect_PK
		FROM #tmpSuspect S
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblScannedData SD WITH (NOLOCK) ON S.Suspect_PK = SD.Suspect_PK
			LEFT JOIN tblScannedDataPageStatus SDPS WITH (NOLOCK) ON SDPS.ScannedData_PK =  SD.ScannedData_PK AND SDPS.CoderLevel = @level
		WHERE (@is_admin=1 OR ISNULL(SD.is_deleted,0)=0)
		ORDER BY SD.Suspect_PK,DocumentType_PK
	END

	SELECT ScanningQANoteText_PK, ScanningQANoteText, IsCopy, IsMove, IsRemove FROM tblScanningQANoteText
END
GO
