SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	imv_getSuspectPageList 38429,0,0,1,0
CREATE PROCEDURE [dbo].[imv_getSuspectPageList] 
	@Suspect bigint,
	@is_admin bit,
	@AllMemberChartsInViewer bit,
	@User INT,
	@QA SmallInt
AS
BEGIN
	DECLARE @Suspect4Images AS BIGINT = @Suspect
	DECLARE @level AS tinyint
	SELECT @level=CoderLevel FROM tblUser WITH (NOLOCK) WHERE User_PK=@User

	SELECT S.Suspect_PK,M.Member_ID,M.Lastname+', '+M.Firstname MemberName,DOB,S.ChaseID,S.Scanned_Date,S.Scanned_User_PK,S.LinkedSuspect_PK
			,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider_Name 
		INTO #MemberInfo
		FROM tblMember M 
			INNER JOIN tblSuspect S ON S.Member_PK=M.Member_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
	WHERE S.Suspect_PK=@Suspect

	IF EXISTS(SELECT * FROM #MemberInfo WHERE LinkedSuspect_PK IS NOT NULL)
		SELECT @Suspect4Images = LinkedSuspect_PK FROM #MemberInfo

	SELECT *,@Suspect4Images ImageChartSuspect_PK,(SELECT COUNT(1) FROM tblSuspect WHERE LinkedSuspect_PK=@Suspect) LinkedChases FROM #MemberInfo

	If (@AllMemberChartsInViewer=0)
	BEGIN
		SELECT SD.ScannedData_PK,SD.is_deleted,SDPS.PageStatus_PK CodedStatus,M.Provider_ID,M.Provider_Name,SD.Suspect_PK
		FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN tblScannedData SD WITH (NOLOCK) ON SD.Suspect_PK = S.Suspect_PK
			INNER JOIN #MemberInfo M WITH (NOLOCK) ON 1=1
			LEFT JOIN tblScannedDataPageStatus SDPS WITH (NOLOCK) ON SDPS.ScannedData_PK =  SD.ScannedData_PK AND SDPS.CoderLevel = @level
		WHERE S.Suspect_PK=@Suspect4Images 
			AND (@is_admin=1 OR SD.is_deleted IS NULL OR SD.is_deleted=0)
		ORDER BY DocumentType_PK, SD.ScannedData_PK
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
