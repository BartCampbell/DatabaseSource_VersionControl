SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- Modifiy by Amjad Ali Awan -- added @h_id
-- =============================================
-- db_getQueriesAlter 1
CREATE PROCEDURE [dbo].[db_getQueriesAlter] 
	@UserPK INT,
	@h_id INT
AS
BEGIN
	SELECT COUNT(*) Queries
	FROM tblQuery Q WITH (NOLOCK) INNER JOIN tblEncounter E WITH (NOLOCK) ON E.encounter_pk = Q.Encounter_PK
	WHERE E.inserted_user_pk=@UserPK
		AND Q.updated_date < DATEADD(hour,-72,GetDate())
		AND Q.IsCodedPosted=0
		AND Q.query_text <> ''
		AND E.h_id = @h_id
/*		
	SELECT COUNT(*) TasksAssigned
	FROM tblQuery Q INNER JOIN tblEncounter E ON E.encounter_pk = Q.Encounter_PK
	WHERE Q.tasked_user_pk=@UserPK
		AND IsNull(Q.QueryResponse_pk,0)=0		
		AND Q.task_text <> ''
		*/
END


GO
