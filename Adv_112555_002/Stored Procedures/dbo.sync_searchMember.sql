SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sync_searchMember 1,'AS'
CREATE PROCEDURE [dbo].[sync_searchMember]
	@User int,
	@member varchar(100)
AS
BEGIN
	DECLARE @IsScheduler AS BIT = 1
	--SELECT @IsScheduler=1 FROM tblUser WHERE User_PK=@User AND (IsNull(IsScheduler,0)=1 OR IsNull(IsScanTechSV,0)=1)

	SELECT TOP 0 S.Suspect_PK,S.Member_PK,S.Provider_PK INTO #tmp FROM tblSuspect S WITH (NOLOCK)

	SET IDENTITY_INSERT #tmp ON
	if (@IsScheduler=1)
	BEGIN
		INSERT INTO #tmp(Suspect_PK,Member_PK,Provider_PK)
		SELECT DISTINCT S.Suspect_PK,S.Member_PK,S.Provider_PK 
		FROM tblProvider P WITH (NOLOCK)
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
		WHERE M.Member_ID+' '+M.Lastname+', '+IsNull(M.Firstname,'') Like '%' + @member + '%'
	END
	ELSE
	BEGIN
		INSERT INTO #tmp(Suspect_PK,Member_PK,Provider_PK)
		SELECT DISTINCT S.Suspect_PK,S.Member_PK,S.Provider_PK
		FROM tblProvider P WITH (NOLOCK)
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
				INNER JOIN tblProviderOfficeSchedule POS WITH (NOLOCK) ON POS.ProviderOffice_PK=P.ProviderOffice_PK AND POS.Sch_User_PK=@User 
		WHERE M.Member_ID+' '+M.Lastname+', '+IsNull(M.Firstname,'') Like '%' + @member + '%'
	END
	SET IDENTITY_INSERT #tmp OFF
	
	SELECT DISTINCT P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname FROM tblProvider P WITH (NOLOCK) INNEr JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK INNER JOIN #tmp T ON T.Provider_PK=P.Provider_PK
	SELECT DISTINCT M.Member_PK,M.Member_ID,M.Lastname,M.Firstname,M.DOB FROM tblMember M WITH (NOLOCK) INNER JOIN #tmp T ON T.Member_PK=M.Member_PK
	SELECT DISTINCT 0 Provider_PK,0 Member_PK,0 Suspect_PK,0 IsScanned,0 IsCNA,GETDATE() Scanned_Date,GETDATE() CNA_Date,0 Project_PK,0 IsInvoiced, ' ' DOSs
	UNION
	SELECT DISTINCT S.Provider_PK,S.Member_PK,S.Suspect_PK,S.IsScanned,S.IsCNA,S.Scanned_Date,S.CNA_Date,S.Project_PK,IsNull(IsInvoiced,0) IsInvoiced
		,dbo.tmi_udf_GetSuspectDOSs(S.Suspect_PK) DOSs
		FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN #tmp T ON T.Suspect_PK=S.Suspect_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON T.Provider_PK=P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
END
GO
