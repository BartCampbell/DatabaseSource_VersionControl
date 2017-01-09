SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	dc_getProviders 1,1,25,'','','Coded','DESC',0,1
CREATE PROCEDURE [dbo].[dc_getProviders] 
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Search Varchar(150),
	@Sort Varchar(150),
	@Order Varchar(4),
	@User_PK smallint,
	@member_list smallint,
	@only_remaining_incomplete smallint
AS
BEGIN
	DECLARE @level AS tinyint
	SELECT @level=CoderLevel FROM tblUser WHERE User_PK=@User_PK

	IF (@member_list=0)
	BEGIN
		With tbl AS(
		SELECT ROW_NUMBER() OVER(
			ORDER BY 
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'ID' THEN PM.Provider_ID WHEN 'NAME' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'ID' THEN PM.Provider_ID WHEN 'NAME' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'Charts' THEN Count(S.Member_PK) WHEN 'Scanned' THEN Count(S.Scanned_User_PK) WHEN 'Coded' THEN SUM(CASE WHEN SLC.IsCompleted=1 THEN 1 ELSE 0 END) WHEN 'CNA' THEN Count(S.CNA_User_PK) WHEN 'Remaining' THEN SUM(CASE WHEN Scanned_User_PK IS NOT NULL AND IsNull(SLC.IsCompleted,0)=0 THEN 1 ELSE 0 END) ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'Charts' THEN Count(S.Member_PK) WHEN 'Scanned' THEN Count(S.Scanned_User_PK) WHEN 'Coded' THEN SUM(CASE WHEN SLC.IsCompleted=1 THEN 1 ELSE 0 END) WHEN 'CNA' THEN Count(S.CNA_User_PK) WHEN 'Remaining' THEN SUM(CASE WHEN Scanned_User_PK IS NOT NULL AND IsNull(SLC.IsCompleted,0)=0 THEN 1 ELSE 0 END) ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'LastAccessed' THEN MAX(S.LastAccessed_Date) ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'LastAccessed' THEN MAX(S.LastAccessed_Date) ELSE NULL END END DESC
			) AS RowNumber
				,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider_Name
				,Count(S.Member_PK) Charts
				,Count(S.Scanned_User_PK) Scanned
				,SUM(CASE WHEN SLC.IsCompleted=1 THEN 1 ELSE 0 END) Coded
				,SUM(CASE WHEN CNA_User_PK IS NOT NULL AND Scanned_User_PK IS NULL THEN 1 ELSE 0 END) CNA
				,SUM(CASE WHEN Scanned_User_PK IS NOT NULL AND IsNull(SLC.IsCompleted,0)=0 THEN 1 ELSE 0 END) Remaining
				,MAX(S.LastAccessed_Date) LastAccessed 
			FROM tblProvider P WITH (NOLOCK) 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.CoderLevel = @level AND CA.Suspect_PK = S.Suspect_PK AND CA.User_PK=@User_PK
				LEFT JOIN tblSuspectLevelCoded SLC WITH (NOLOCK) ON SLC.CoderLevel = @level AND SLC.Suspect_PK = S.Suspect_PK
			WHERE (
					@only_remaining_incomplete=0
					OR (@only_remaining_incomplete=1 AND SLC.Suspect_PK IS NULL)
					OR (@only_remaining_incomplete=2 AND SLC.IsCompleted=0)
					)
				AND PM.Provider_ID+PM.Lastname+IsNull(', '+PM.Firstname,'') Like '%'+@Search+'%'
				AND PM.Lastname+IsNull(', '+PM.Firstname,'') Like @Alpha+'%'
			GROUP BY P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname
		)
	
		SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
		SELECT UPPER(LEFT(PM.Lastname,1)) alpha1, UPPER(RIGHT(LEFT(PM.Lastname,2),1)) alpha2,Count(DISTINCT P.Provider_PK) records
			FROM tblProvider P WITH (NOLOCK) 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.CoderLevel = @level AND CA.Suspect_PK = S.Suspect_PK AND CA.User_PK=@User_PK
				LEFT JOIN tblSuspectLevelCoded SLC WITH (NOLOCK) ON SLC.CoderLevel = @level AND SLC.Suspect_PK = S.Suspect_PK
			WHERE (
					@only_remaining_incomplete=0
					OR (@only_remaining_incomplete=1 AND SLC.Suspect_PK IS NULL)
					OR (@only_remaining_incomplete=2 AND SLC.IsCompleted=0)
					)
				AND PM.Provider_ID+PM.Lastname+IsNull(', '+PM.Firstname,'') Like '%'+@Search+'%'	
			GROUP BY LEFT(PM.Lastname,1), RIGHT(LEFT(PM.Lastname,2),1)			
			ORDER BY alpha1, alpha2
	END
	ELSE
	BEGIN
		With tbl AS(
		SELECT ROW_NUMBER() OVER(
			ORDER BY 
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'ID' THEN M.Member_ID WHEN 'NAME' THEN IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,'') ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'ID' THEN M.Member_ID WHEN 'NAME' THEN IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,'') ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'Charts' THEN COUNT(S.Suspect_PK) WHEN 'Scanned' THEN MAX(CASE WHEN Scanned_User_PK IS NULL THEN 0 ELSE 1 END) WHEN 'Coded' THEN MAX(CASE WHEN SLC.IsCompleted=1 THEN 1 ELSE 0 END) WHEN 'CNA' THEN MAX(CASE WHEN CNA_User_PK IS NOT NULL AND Scanned_User_PK IS NULL THEN 1 ELSE 0 END) WHEN 'Remaining' THEN MAX(CASE WHEN Scanned_User_PK IS NOT NULL AND IsNull(SLC.IsCompleted,0)=0 THEN 1 ELSE 0 END) ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'Charts' THEN COUNT(S.Suspect_PK) WHEN 'Scanned' THEN MAX(CASE WHEN Scanned_User_PK IS NULL THEN 0 ELSE 1 END) WHEN 'Coded' THEN MAX(CASE WHEN SLC.IsCompleted=1 THEN 1 ELSE 0 END) WHEN 'CNA' THEN MAX(CASE WHEN CNA_User_PK IS NOT NULL AND Scanned_User_PK IS NULL THEN 1 ELSE 0 END) WHEN 'Remaining' THEN MAX(CASE WHEN Scanned_User_PK IS NOT NULL AND IsNull(SLC.IsCompleted,0)=0 THEN 1 ELSE 0 END) ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'DOB' THEN M.DOB WHEN 'LastAccessed' THEN MAX(S.LastAccessed_Date) ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'DOB' THEN M.DOB WHEN 'LastAccessed' THEN MAX(S.LastAccessed_Date) ELSE NULL END END DESC
			) AS RowNumber
				,MAX(S.Suspect_PK) Suspect_PK,M.Member_PK,M.Member_ID,IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,'') Member_Name, M.DOB
				,MAX(CASE WHEN Scanned_User_PK IS NULL THEN 0 ELSE 1 END) Scanned
				,MAX(CASE WHEN SLC.IsCompleted=1 THEN 1 ELSE 0 END) Coded
				,MAX(CASE WHEN CNA_User_PK IS NOT NULL AND Scanned_User_PK IS NULL THEN 1 ELSE 0 END) CNA
				,MAX(CASE WHEN Scanned_User_PK IS NOT NULL AND IsNull(SLC.IsCompleted,0)=0 THEN 1 ELSE 0 END) Remaining
				,MAX(S.LastAccessed_Date) LastAccessed
				,MAX(CASE WHEN IsNull(SLC.ReceivedAdditionalPages,0)=0 THEN 0 ELSE 1 END) ReceivedAdditionalPages
				
				,COUNT(S.Suspect_PK) ChartsCount
				,SUM(CASE WHEN Scanned_User_PK IS NULL THEN 0 ELSE 1 END) ScannedCount
				,SUM(CASE WHEN SLC.IsCompleted=1 THEN 1 ELSE 0 END) CodedCount
				,SUM(CASE WHEN CNA_User_PK IS NOT NULL AND Scanned_User_PK IS NULL THEN 1 ELSE 0 END) CNACount
				,SUM(CASE WHEN Scanned_User_PK IS NOT NULL AND IsNull(SLC.IsCompleted,0)=0 THEN 1 ELSE 0 END) RemainingCount
			FROM tblMember M WITH (NOLOCK) 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK
				INNER JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.CoderLevel = @level AND CA.Suspect_PK = S.Suspect_PK AND CA.User_PK=@User_PK 
				LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.Coded_User_PK
				LEFT JOIN tblUser US WITH (NOLOCK) ON US.User_PK = S.Scanned_User_PK
				LEFT JOIN tblUser CNA WITH (NOLOCK) ON CNA.User_PK = S.CNA_User_PK
				LEFT JOIN tblSuspectLevelCoded SLC WITH (NOLOCK) ON SLC.CoderLevel = @level AND SLC.Suspect_PK = S.Suspect_PK
			WHERE (
					@only_remaining_incomplete=0
					OR (@only_remaining_incomplete=1 AND SLC.Suspect_PK IS NULL)
					OR (@only_remaining_incomplete=2 AND SLC.IsCompleted=0)
					)
				AND M.Member_ID+IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,'') Like '%'+@Search+'%'
				AND IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,'') Like @Alpha+'%'
			GROUP BY M.Member_PK,M.Member_ID,IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,''), M.DOB
		)

		SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page
	
		SELECT UPPER(LEFT(IsNull(M.Lastname,''),1)) alpha1, UPPER(RIGHT(LEFT(IsNull(M.Lastname,''),2),1)) alpha2,Count(DISTINCT M.Member_PK) records
			FROM tblMember M WITH (NOLOCK) 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK 
				INNER JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.CoderLevel = @level AND CA.Suspect_PK = S.Suspect_PK AND CA.User_PK=@User_PK 
				LEFT JOIN tblSuspectLevelCoded SLC WITH (NOLOCK) ON SLC.CoderLevel = @level AND SLC.Suspect_PK = S.Suspect_PK
			WHERE (
					@only_remaining_incomplete=0
					OR (@only_remaining_incomplete=1 AND SLC.Suspect_PK IS NULL)
					OR (@only_remaining_incomplete=2 AND SLC.IsCompleted=0)
					)
				AND M.Member_ID+IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,'') Like '%'+@Search+'%'	
			GROUP BY LEFT(IsNull(M.Lastname,''),1), RIGHT(LEFT(IsNull(M.Lastname,''),2),1)			
			ORDER BY alpha1, alpha2
	END
END
GO
