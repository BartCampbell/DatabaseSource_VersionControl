SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[c_getEncounterList] 
	@User int,
	@h_id int
AS
BEGIN
	SELECT E.encounter_pk
      ,department
	  ,case_status
      ,provider_name
      ,[FIN]
      ,M.member_id
      ,M.member_name
      ,[DOS]
	  ,m.DOB
	  ,[Admit_Date]
	  ,[Discharge_Date]
      ,[CPT_EM_Org]
      ,[CPT_Other_Org]
      ,[HCPCS]
      ,[AD]
      ,[Diag]
      ,[CoderNote]
	  ,CASE 
			WHEN IsNull(Q.query_text,'')<>'' THEN 'Q'
			WHEN IsNull(Q.task_text,'')<>'' THEN 'T'
			WHEN IsNull(Q.denial_text,'')<>'' THEN 'D'
			ELSE 'N'
		END encounter_type
		,S.Specialty
		,E.case_pk
  FROM tblEncounter E WITH (NOLOCK)
	INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
	INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
	INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
	left JOIN tblSpecialty S WITH (NOLOCK) ON S.id = E.specialty
	left join tblcase ca with (nolock) on ca.case_pk=E.case_pk
	LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
  WHERE Year(inserted_date)=YEAR(GetDate())
	AND Month(inserted_date)=Month(GetDate())
	AND Day(inserted_date)=Day(GetDate())
	AND inserted_user_pk = @User
	AND e.h_id= @h_id order by inserted_date DESC
END;

GO
