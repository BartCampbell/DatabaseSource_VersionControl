SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_getOfficeProviderMember @User=1,@Office=107 
CREATE PROCEDURE [dbo].[sch_getOfficeProviderMember]  
	@User int, 
	@Office bigint 
AS 
BEGIN 
	-- PROJECT/Channel SELECTION 
	CREATE TABLE #tmpProject (Project_PK INT) 
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK) 
 
	CREATE TABLE #tmpChannel (Channel_PK INT) 
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK) 
 
	IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins 
	BEGIN 
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblChannel  
	END 
	ELSE 
	BEGIN 
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblUserProject WHERE User_PK=@User 
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblUserChannel WHERE User_PK=@User 
	END		  
	-- PROJECT/Channel SELECTION 
 
	SELECT DISTINCT PO.Address,ZC.ZipCode,ZC.City,ZC.County,ZC.State,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber,PO.LocationID 
	FROM tblProviderOffice PO 
		LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK 
	WHERE PO.ProviderOffice_PK = @Office	 
	/*   
	--To List All Provider of each Members 
	SELECT DISTINCT M.Member_ID,M.Lastname+IsNull(', '+M.FirstName,'') Member,M.DOB,Count(DISTINCT Suspect_PK) Charts  
	FROM tblMember M 
		INNER JOIN tblSuspect S ON S.Member_PK = M.Member_PK 
		INNER JOIN tblProvider P ON S.Provider_PK = P.Provider_PK 
	WHERE P.ProviderOffice_PK = @Office	AND S.Project_PK=@Project AND S.IsScanned=0 AND S.IsCNA=0 
	GROUP BY M.Member_ID,M.Lastname,M.FirstName,M.DOB 
	ORDER BY Member 
 
	SELECT DISTINCT M.Member_ID,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.FirstName,'') Provider 
	FROM tblProvider P  
		INNER JOIN tblSuspect S ON P.Provider_PK = S.Provider_PK 
		INNER JOIN tblMember M ON M.Member_PK = S.Member_PK 
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK 
	WHERE P.ProviderOffice_PK = @Office	AND S.Project_PK=@Project AND S.IsScanned=0 AND S.IsCNA=0 
	ORDER BY Provider 
	*/ 
	--To List All Members of each Provider 
	SELECT DISTINCT P.Provider_PK,PM.Provider_ID [Provider ID],PM.Lastname+', '+PM.FirstName Provider,Count(DISTINCT Suspect_PK) Charts  
	FROM tblProvider P 
		INNER JOIN tblSuspect S ON P.Provider_PK = S.Provider_PK 
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK 
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK 
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK 
	WHERE P.ProviderOffice_PK = @Office	AND S.IsScanned=0 AND S.IsCNA=0 --AND S.Project_PK=@Project 
	GROUP BY P.Provider_PK,PM.Provider_ID,PM.Lastname+', '+PM.FirstName 
	ORDER BY Provider 
 
	SELECT DISTINCT P.Provider_PK, M.Member_ID,M.Lastname+', '+M.FirstName Member,M.DOB,Suspect_PK, dbo.tmi_udf_GetSuspectDOSs(S.Suspect_PK) DOSs 
		,S.ChaseID [Chase ID],M.Eff_Date [Effective Date],S.Project_PK 
	FROM tblProvider P  
		INNER JOIN tblSuspect S ON P.Provider_PK = S.Provider_PK 
		INNER JOIN tblMember M ON M.Member_PK = S.Member_PK 
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK 
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK 
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK 
	WHERE P.ProviderOffice_PK = @Office	AND S.IsScanned=0 AND S.IsCNA=0 --AND S.Project_PK=@Project 
	ORDER BY P.Provider_PK,Member 
	 
	SELECT MAX(Sch_Start) Sch_Start FROM tblProviderOfficeSchedule  
		WHERE Sch_Start>GetDate() 
		AND ProviderOffice_PK = @Office 
END 
GO
