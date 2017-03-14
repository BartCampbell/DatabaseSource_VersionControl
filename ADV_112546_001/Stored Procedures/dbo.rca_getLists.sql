SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- rca_getLists 1,1
CREATE PROCEDURE [dbo].[rca_getLists]
	@level int,
	@only_coders int,
	@IsBlindCoding tinyint
AS
BEGIN
	SELECT U.User_PK,U.Lastname+', '+U.Firstname Fullname,Count(DISTINCT CA.Suspect_PK)-COUNT(DISTINCT SLC.Suspect_PK) Assignments 
	FROM tblUser U WITH (NOLOCK) 
		LEFT JOIN tblCoderAssignment CA WITH (NOLOCK) ON U.User_PK = CA.User_PK AND CA.CoderLevel=@level
		LEFT JOIN tblSuspectLevelCoded SLC WITH (NOLOCK) ON SLC.Suspect_PK=CA.Suspect_PK AND SLC.CoderLevel=@level AND SLC.IsCompleted=1
	WHERE U.IsReviewer=1 AND U.CoderLevel=@level 
	GROUP BY U.User_PK,U.Lastname,U.Firstname
	ORDER BY Fullname

	if (@only_coders=1)
		return;

	SELECT DISTINCT ChartPriority FROM tblSuspect WHERE ChartPriority IS NOT NULL ORDER BY ChartPriority

	--SELECT DISTINCT Project_Name,Project_PK FROM tblProject WHERE IsRetrospective=1 ORDER BY Project_Name

	--SELECT DISTINCT ProjectGroup,ProjectGroup_PK FROM tblProject WHERE IsRetrospective=1 ORDER BY ProjectGroup

	exec rca_getStatsAssign @level=1,@only_incomplete=0,@pages=1,@less_more='',@priority='',@Projects='0',@ProjectGroup='0',@charts2Assign=0,@coders='',@IsBlindCoding=@IsBlindCoding
END
GO
