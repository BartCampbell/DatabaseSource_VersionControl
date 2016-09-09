SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- c_getQuery 770
CREATE PROCEDURE [dbo].[c_getQuery] 
	@encounter_pk bigint
AS
BEGIN
	SELECT U.Lastname+', '+U.Firstname TaskedTo, query_text,task_text,response_text,QueryResponse_pk,denial_text,IsCodedPosted
	FROM tblQuery Q WITH (NOLOCK)
		LEFT JOIN tblUser U WITH (NOLOCK) ON tasked_user_pk = User_PK
	WHERE Q.encounter_pk = @encounter_pk
  
	SELECT 
	  E.Inserted_date
	  ,C.Lastname+', '+C.Firstname Coder
	  ,IsNull(QR.QueryResponse,'') Response
	  ,Q.task_text
	  ,U.Lastname+', '+U.Firstname TaskTo
	  ,Q.denial_text      
	FROM tblEncounter E WITH (NOLOCK)
		INNER JOIN tblUser C WITH (NOLOCK) ON C.User_PK = E.inserted_user_pk
		LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
		LEFT JOIN tblQueryResponse QR WITH (NOLOCK) ON QR.QueryResponse_pk = Q.QueryResponse_pk
		LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = Q.tasked_user_pk
	WHERE E.parent_encounter_pk = @encounter_pk
	ORDER BY E.Inserted_date
END


GO
