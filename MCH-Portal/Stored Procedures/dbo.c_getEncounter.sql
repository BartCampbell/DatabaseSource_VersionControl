SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[c_getEncounter] 
	@encounter_pk bigint
AS
BEGIN
	SELECT E.encounter_pk
      ,department_pk
      ,provider_pk
      ,FIN
      ,E.member_pk
      ,M.member_id
      ,M.member_name
      ,DOS
      ,CPT_EM_Org
      ,CPT_Other_Org
      ,DX_Org
      ,CPT_EM_TMI
      ,CPT_Other_TMI
      ,DX_TMI
	  ,CPT_EM_TMI_olc
      ,h_id
      ,change_reason
      ,Q.query_text
      ,Q.task_text
      ,IsNull(Q.tasked_user_pk,0) tasked_user_pk
      ,Q.denial_text
	  ,tpa
	  ,mor
	  ,Admit_Date
	  ,Discharge_Date
	  ,m_id
	  ,m_comments
	  ,change
  FROM tblEncounter E WITH (NOLOCK)
	INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
	LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
  WHERE E.encounter_pk = @encounter_pk
END;

GO
