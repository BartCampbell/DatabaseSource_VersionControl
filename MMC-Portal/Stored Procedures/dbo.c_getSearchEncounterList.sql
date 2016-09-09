SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- c_getSearchEncounterList @User=1,@isManager=1,@h_id=1,@fin='',@case='18', @dis_date='',@adm_date='',@case_type=2
CREATE PROCEDURE [dbo].[c_getSearchEncounterList] 
	@User int,
	@isManager int,
	@h_id int,
	@fin varchar(20),
	@case varchar(5),
	@dis_date varchar(12),
	@adm_date varchar(12),
	@case_type int
AS
BEGIN
if(@isManager=0)
BEGIN
	SELECT E.encounter_pk
      ,department
	  ,case_status
      ,provider_name
      ,[FIN]
      ,M.member_id
      ,M.member_name
      ,[DOS]
	  ,M.[DOB]
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
		,ca.case_pk
  FROM tblEncounter E WITH (NOLOCK)
	INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
	INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
	INNER JOIN tblSpecialty S WITH (NOLOCK) ON S.id = E.specialty
	INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
	inner join tblcase ca with (nolock) on ca.case_pk=E.case_pk
	LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
  WHERE inserted_user_pk = @User
	AND ca.case_status=@case_type
	AND (@fin='' or E.FIN=@fin )
	AND (@adm_date='' or ca.Admit_Date=@adm_date )
	AND (@dis_date='' or ca.Discharge_Date=@dis_date )
	AND (@case='' OR ca.case_pk=@case)
	
	order by inserted_date DESC
END
ELSE
BEGIN
SELECT E.encounter_pk
      ,department
	  ,case_status
      ,provider_name
      ,[FIN]
      ,M.member_id
      ,M.member_name
      ,[DOS]
	  ,M.[DOB]
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
		,ca.case_pk
  FROM tblEncounter E WITH (NOLOCK)
	INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
	INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
	INNER JOIN tblSpecialty S WITH (NOLOCK) ON S.id = E.specialty
	INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
	inner join tblcase ca with (nolock) on ca.case_pk=E.case_pk
	LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
  WHERE e.h_id= @h_id 
	AND ca.case_status=@case_type
	AND (@fin='' or E.FIN=@fin )
	AND (@adm_date='' or ca.Admit_Date=@adm_date )
	AND (@dis_date='' or ca.Discharge_Date=@dis_date )
	AND (@case='' OR ca.case_pk=@case)
	
	order by inserted_date DESC
END

END

GO
