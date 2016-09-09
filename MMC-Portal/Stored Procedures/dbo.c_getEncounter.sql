SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[c_getEncounter] 
	@encounter_pk bigint
AS
BEGIN
	SELECT E.encounter_pk
      ,e.department_pk
      ,e.provider_pk
      ,FIN
      ,E.member_pk
      ,M.member_id
      ,M.member_name
      ,DOS
      ,CPT_EM_Org
      ,CPT_Other_Org
      ,HCPCS 
	  ,AD 
	  ,Diag
      ,CoderNote
      ,h_id
      ,Q.query_text
      ,Q.task_text
      ,IsNull(Q.tasked_user_pk,0) tasked_user_pk
      ,Q.denial_text
	  ,Admit_Date
	  ,Discharge_Date
	  ,change
	  ,ca.case_pk Case2
      ,IsNull(case_status,0) case_status
      ,IsNull(admit_time,'') admit_time
      ,IsNull(discharg_time,'') discharg_time
      ,IsNull(admit_am,0) admit_am
      ,IsNull(discharg_am,0) discharg_am
	  ,M.DOB
	  ,e.specialty
	  
  FROM tblEncounter E WITH (NOLOCK)
	INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
	INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
	left join tblcase ca with (nolock) on ca.case_pk=E.case_pk

	LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
  WHERE E.encounter_pk = @encounter_pk
END;
GO
