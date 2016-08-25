SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	dc_getMembers 418,27,1,10,'','','',''
CREATE PROCEDURE [dbo].[dc_getMembers] 
	@SearchPK int,
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Search Varchar(150),
	@Sort Varchar(150),
	@Order Varchar(4),
	@member_list smallint,
	@User_PK smallint
AS
BEGIN
	DECLARE @level AS tinyint
	SELECT @level=CoderLevel FROM tblUser WHERE User_PK=@User_PK

	IF (@member_list=0)
	BEGIN
		With tbl AS(
		SELECT ROW_NUMBER() OVER(
			ORDER BY 
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'ID' THEN M.Member_ID WHEN 'NAME' THEN M.Lastname+', '+M.Firstname ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'ID' THEN M.Member_ID WHEN 'NAME' THEN M.Lastname+', '+M.Firstname ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'Scanned' THEN (S.Scanned_User_PK) WHEN 'Coded' THEN (S.Coded_User_PK) WHEN 'CNA' THEN (S.CNA_User_PK) WHEN 'Remaining' THEN (CASE WHEN Scanned_User_PK IS NOT NULL AND Coded_User_PK IS NULL THEN 1 ELSE 0 END) ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'Scanned' THEN (S.Scanned_User_PK) WHEN 'Coded' THEN (S.Coded_User_PK) WHEN 'CNA' THEN (S.CNA_User_PK) WHEN 'Remaining' THEN (CASE WHEN Scanned_User_PK IS NOT NULL AND Coded_User_PK IS NULL THEN 1 ELSE 0 END) ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'DOB' THEN M.DOB WHEN 'LastAccessed' THEN (S.LastAccessed_Date) ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'DOB' THEN M.DOB WHEN 'LastAccessed' THEN (S.LastAccessed_Date) ELSE NULL END END DESC
			) AS RowNumber
				,S.Suspect_PK,M.Member_PK,S.Provider_PK,M.Member_ID,IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,'') Member_Name, M.DOB
				,CASE WHEN Scanned_User_PK IS NULL THEN 0 ELSE 1 END Scanned
				,CASE WHEN Coded_User_PK IS NULL THEN 0 ELSE 1 END Coded
				,CASE WHEN CNA_User_PK IS NOT NULL AND Scanned_User_PK IS NULL THEN 1 ELSE 0 END CNA
				,CASE WHEN Scanned_User_PK IS NOT NULL AND Coded_User_PK IS NULL THEN 1 ELSE 0 END Remaining
				,S.LastAccessed_Date LastAccessed 
				,Coded_Date, U.Lastname+', '+U.Firstname Coded_User
				,Scanned_Date, US.Lastname+', '+US.Firstname Scanned_User
				,CNA_Date, CNA.Lastname+', '+CNA.Firstname CNA_User
			FROM tblMember M WITH (NOLOCK) 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK 
				INNER JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.CoderLevel = @level AND CA.Suspect_PK = S.Suspect_PK AND CA.User_PK=@User_PK 
				LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.Coded_User_PK
				LEFT JOIN tblUser US WITH (NOLOCK) ON US.User_PK = S.Scanned_User_PK
				LEFT JOIN tblUser CNA WITH (NOLOCK) ON CNA.User_PK = S.CNA_User_PK
			WHERE S.Provider_PK=@SearchPK
				AND IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,'') Like @Search+'%'
				AND IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,'') Like @Alpha+'%'
		)

		SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page
	
		SELECT UPPER(LEFT(IsNull(M.Lastname,''),1)) alpha1, UPPER(RIGHT(LEFT(IsNull(M.Lastname,''),2),1)) alpha2,Count(DISTINCT M.Member_PK) records
			FROM tblMember M WITH (NOLOCK) 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK 
				INNER JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.CoderLevel = @level AND CA.Suspect_PK = S.Suspect_PK AND CA.User_PK=@User_PK 
			WHERE S.Provider_PK=@SearchPK
				AND M.Lastname+', '+M.Firstname Like @Search+'%'	
			GROUP BY LEFT(IsNull(M.Lastname,''),1), RIGHT(LEFT(IsNull(M.Lastname,''),2),1)			
			ORDER BY alpha1, alpha2
	END
	ELSE
	BEGIN
		With tbl AS(
		SELECT ROW_NUMBER() OVER(
			ORDER BY 
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'ID' THEN PM.Provider_ID WHEN 'NAME' THEN PM.Lastname+', '+PM.Firstname ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'ID' THEN PM.Provider_ID WHEN 'NAME' THEN PM.Lastname+', '+PM.Firstname ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'Scanned' THEN (S.Scanned_User_PK) WHEN 'Coded' THEN (S.Coded_User_PK) WHEN 'CNA' THEN (S.CNA_User_PK) WHEN 'Remaining' THEN (CASE WHEN Scanned_User_PK IS NOT NULL AND Coded_User_PK IS NULL THEN 1 ELSE 0 END) ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'Scanned' THEN (S.Scanned_User_PK) WHEN 'Coded' THEN (S.Coded_User_PK) WHEN 'CNA' THEN (S.CNA_User_PK) WHEN 'Remaining' THEN (CASE WHEN Scanned_User_PK IS NOT NULL AND Coded_User_PK IS NULL THEN 1 ELSE 0 END) ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'LastAccessed' THEN (S.LastAccessed_Date) ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'LastAccessed' THEN (S.LastAccessed_Date) ELSE NULL END END DESC
			) AS RowNumber
				,S.Suspect_PK,S.Member_PK,S.Provider_PK,PM.Provider_ID,IsNull(PM.Lastname,'')+IsNull(', '+PM.Firstname,'') Provider_Name
				,CASE WHEN Scanned_User_PK IS NULL THEN 0 ELSE 1 END Scanned
				,CASE WHEN Coded_User_PK IS NULL THEN 0 ELSE 1 END Coded
				,CASE WHEN CNA_User_PK IS NOT NULL AND Scanned_User_PK IS NULL THEN 1 ELSE 0 END CNA
				,CASE WHEN Scanned_User_PK IS NOT NULL AND Coded_User_PK IS NULL THEN 1 ELSE 0 END Remaining
				,S.LastAccessed_Date LastAccessed 
				,Coded_Date, U.Lastname+', '+U.Firstname Coded_User
				,Scanned_Date, US.Lastname+', '+US.Firstname Scanned_User
				,CNA_Date, CNA.Lastname+', '+CNA.Firstname CNA_User
			FROM tblProvider P WITH (NOLOCK) 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK 
				INNER JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.CoderLevel = @level AND CA.Suspect_PK = S.Suspect_PK AND CA.User_PK=@User_PK 
				LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.Coded_User_PK
				LEFT JOIN tblUser US WITH (NOLOCK) ON US.User_PK = S.Scanned_User_PK
				LEFT JOIN tblUser CNA WITH (NOLOCK) ON CNA.User_PK = S.CNA_User_PK
			WHERE S.Member_PK=@SearchPK
				AND IsNull(PM.Lastname,'')+IsNull(', '+PM.Firstname,'') Like @Search+'%'
				AND IsNull(pM.Lastname,'')+IsNull(', '+PM.Firstname,'') Like @Alpha+'%'
		)

		SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page
	
		SELECT UPPER(LEFT(IsNull(M.Lastname,''),1)) alpha1, UPPER(RIGHT(LEFT(IsNull(M.Lastname,''),2),1)) alpha2,Count(DISTINCT M.Member_PK) records
			FROM tblMember M WITH (NOLOCK) 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK 
				INNER JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.CoderLevel = @level AND CA.Suspect_PK = S.Suspect_PK AND CA.User_PK=@User_PK 
			WHERE S.Member_PK=@SearchPK
				AND M.Lastname+', '+M.Firstname Like @Search+'%'	
			GROUP BY LEFT(IsNull(M.Lastname,''),1), RIGHT(LEFT(IsNull(M.Lastname,''),2),1)			
			ORDER BY alpha1, alpha2
	END
END
GO
