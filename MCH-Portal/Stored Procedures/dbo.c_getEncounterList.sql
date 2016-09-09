SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- c_getEncounterList 1,0
CREATE PROCEDURE [dbo].[c_getEncounterList] 
	@User int,
	@h_id int
AS
BEGIN
	SELECT E.encounter_pk
      ,department
      ,provider_name
      ,[FIN]
      ,M.member_id
      ,M.member_name
      ,[DOS]
      ,[CPT_EM_Org]
      ,[CPT_Other_Org]
      ,[DX_Org]
      ,[CPT_EM_TMI]
      ,[CPT_Other_TMI]
      ,[DX_TMI]
      ,[change_reason]
	  ,CASE 
			WHEN IsNull(Q.query_text,'')<>'' THEN 'Q'
			WHEN IsNull(Q.task_text,'')<>'' THEN 'T'
			WHEN IsNull(Q.denial_text,'')<>'' THEN 'D'
			ELSE 'N'
		END encounter_type
  FROM tblEncounter E WITH (NOLOCK)
	INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
	INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
	INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
	LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
  WHERE Year(inserted_date)=YEAR(GetDate())
	AND Month(inserted_date)=Month(GetDate())
	AND Day(inserted_date)=Day(GetDate())
	AND inserted_user_pk = @User
	AND e.h_id= @h_id order by inserted_date DESC
END


GO
