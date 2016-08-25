SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	rca_getChart 1
CREATE PROCEDURE [dbo].[rca_getChart] 
	@level smallint
AS
BEGIN
	SELECT TOP 1000 ROW_NUMBER() OVER(ORDER BY M.Lastname) AS RowNumber
			,S.Suspect_PK Suspect_PK,M.Member_PK,M.Member_ID,IsNull(M.Lastname,'')+IsNull(', '+M.Firstname,'') Member_Name, M.DOB
			,S.LastAccessed_Date LastAccessed
			,CASE WHEN IsNull(SLC.ReceivedAdditionalPages,0)=0 THEN 0 ELSE 1 END ReceivedAdditionalPages			
			,IsNull(U.Lastname,'')+IsNull(', '+U.Firstname,'') Coder
		FROM tblMember M WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			INNER JOIN tblSuspectLevelCoded SLC WITH (NOLOCK) ON SLC.CoderLevel = @level AND SLC.Suspect_PK = S.Suspect_PK
			LEFT JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.CoderLevel = @level AND CA.Suspect_PK = S.Suspect_PK
			LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = CA.User_PK			
		WHERE SLC.IsCompleted=0
END
GO
