SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetUserNames]
(
	@IncludeAllOption bit = 1,
	@Source nvarchar(128) = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH UserListBase([UserName], [Source]) AS
	(
		SELECT DISTINCT CreatedUser, 'MedicalRecordComposite' FROM dbo.MedicalRecordComposite WITH(NOLOCK) WHERE CreatedUser IS NOT NULL
		UNION
		SELECT DISTINCT LastChangedUser, 'MedicalRecordComposite' FROM dbo.MedicalRecordComposite WITH(NOLOCK) WHERE LastChangedUser IS NOT NULL
		UNION 
		SELECT DISTINCT CreatedUser, 'PursuitEvent' FROM dbo.PursuitEvent WITH(NOLOCK) WHERE CreatedUser IS NOT NULL
		UNION
		SELECT DISTINCT LastChangedUser, 'PursuitEvent' FROM dbo.PursuitEvent WITH(NOLOCK) WHERE LastChangedUser IS NOT NULL
		UNION 
		SELECT DISTINCT CreatedUser, 'FaxLog' FROM dbo.FaxLog WITH(NOLOCK) WHERE CreatedUser IS NOT NULL
		UNION
		SELECT DISTINCT LastChangedUser, 'FaxLog' FROM dbo.FaxLog WITH(NOLOCK) WHERE LastChangedUser IS NOT NULL
		UNION 
		SELECT DISTINCT CreatedUser, 'Appointment' FROM dbo.Appointment WITH(NOLOCK) WHERE CreatedUser IS NOT NULL
		UNION
		SELECT DISTINCT LastChangedUser, 'Appointment' FROM dbo.Appointment WITH(NOLOCK) WHERE LastChangedUser IS NOT NULL
		UNION 
		SELECT DISTINCT CreatedUser, 'AbstractionReviewSet' FROM dbo.AbstractionReviewSet WITH(NOLOCK) WHERE CreatedUser IS NOT NULL
		UNION
		SELECT DISTINCT LastChangedUser, 'AbstractionReviewSet' FROM dbo.AbstractionReviewSet WITH(NOLOCK) WHERE LastChangedUser IS NOT NULL
		UNION 
		SELECT DISTINCT CreateUser, 'PursuitEventNote' FROM dbo.PursuitEventNote WITH(NOLOCK) WHERE CreateUser IS NOT NULL
		UNION
		SELECT DISTINCT UpdateUser, 'PursuitEventNote' FROM dbo.PursuitEventNote WITH(NOLOCK) WHERE UpdateUser IS NOT NULL
	),
	UserList AS
	(	
		SELECT DISTINCT 
				ULB.UserName AS Descr,
				ULB.UserName AS ID,
				2 AS SortOrder
		FROM	UserListBase AS ULB
		WHERE	((@Source IS NULL) OR (ULB.[Source] = @Source))
		UNION
		SELECT	'(All Users)' AS Descr,
				CONVERT(nvarchar(128), NULL) AS ID,
				1
	)
	SELECT 
			UL.Descr,
			UL.ID
	FROM	UserList AS UL
			CROSS APPLY (SELECT CASE WHEN UL.ID LIKE REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]') THEN 1 ELSE 0 END AS IsGuid) AS t
	WHERE	t.IsGuid = 0 AND
			((@IncludeAllOption = 1) OR (UL.ID IS NOT NULL))
	ORDER BY UL.SortOrder, UL.ID
	OPTION(OPTIMIZE FOR UNKNOWN);
    
END

GO
GRANT EXECUTE ON  [Report].[GetUserNames] TO [Reporting]
GO
