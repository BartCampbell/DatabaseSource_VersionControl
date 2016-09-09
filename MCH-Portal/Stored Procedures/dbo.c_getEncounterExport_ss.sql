SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Ali
-- Alter date: Aug-25-2016
-- Description:	Complete list on single sheet
-- c_getEncounterExport_ss '07-01-2016','07-31-2016',0,0,'','',1,0
CREATE PROCEDURE [dbo].[c_getEncounterExport_ss] 
	@from date,
	@to date,
	@coder smallint,
	@physician smallint,
	@FIN varchar(15),
	@extraParam varchar(1),
	@h_id int,
	@dateType int
AS
BEGIN
		IF (@dateType='0')
		BEGIN
		SELECT 
			provider_name [Physician Name]
		  ,[FIN] [PowerChart Fin #]
		  ,M.member_id [Medical Record #]
		  ,DOS [Date of Service]
		  ,[CPT_EM_Org] [MCH Orig CPT - E & M]
		  ,[CPT_Other_Org] [MCH Orig CPT - Other]
		  ,[DX_Org] [MCH Orig DX]
		  ,department [Department]
		  ,[CPT_EM_TMI] [TMI CPT - E & M]
		  ,[CPT_Other_TMI] [TMI CPT - Other]
		  ,[DX_TMI] [TMI DX]
		  ,[change_reason] [Reasoning for Action Taken]
		  ,inserted_date [Date Coded]
		  ,C.Lastname+', '+C.Firstname [Coder ID]
		  ,IsNull(Q.task_text + ' / ' + S.Lastname+', '+S.Firstname,'') [Task]
		  ,IsNull(Q.query_text,'') [Query]
		  ,IsNull(Q.denial_text,'') [Denial]
		FROM tblEncounter E WITH (NOLOCK)
		INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
		INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
		INNER JOIN tblUser C WITH (NOLOCK) ON C.User_PK = E.inserted_user_pk
		LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
		LEFT JOIN tblUser S WITH (NOLOCK) ON S.User_PK = Q.tasked_user_pk
		WHERE 
		inserted_date>=@from
		AND inserted_date<dateadd(day,1,@to)
		AND (E.inserted_user_pk=@coder OR @coder=0)
		AND (E.provider_pk=@physician OR @physician=0)
		AND (E.FIN=@FIN OR @FIN='')
		AND  E.h_id= @h_id
		AND (@extraParam='' OR (@extraParam='T' AND IsNull(Q.task_text,'')<>'') OR (@extraParam='D' AND IsNull(Q.denial_text,'')<>''))
		END
		ELSE
		BEGIN
		SELECT 
			provider_name [Physician Name]
			,[FIN] [PowerChart Fin #]
			,M.member_id [Medical Record #]
			,DOS [Date of Service]
			,[CPT_EM_Org] [MCH Orig CPT - E & M]
			,[CPT_Other_Org] [MCH Orig CPT - Other]
			,[DX_Org] [MCH Orig DX]
			,department [Department]
			,[CPT_EM_TMI] [TMI CPT - E & M]
			,[CPT_Other_TMI] [TMI CPT - Other]
			,[DX_TMI] [TMI DX]
			,[change_reason] [Reasoning for Action Taken]
			,inserted_date [Date Coded]
			,C.Lastname+', '+C.Firstname [Coder ID]
			,IsNull(Q.task_text + ' / ' + S.Lastname+', '+S.Firstname,'') [Task]
			,IsNull(Q.query_text,'') [Query]
			,IsNull(Q.denial_text,'') [Denial]
		FROM tblEncounter E WITH (NOLOCK)
			INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
			INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
			INNER JOIN tblUser C WITH (NOLOCK) ON C.User_PK = E.inserted_user_pk
			LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
			LEFT JOIN tblUser S WITH (NOLOCK) ON S.User_PK = Q.tasked_user_pk
		WHERE 
			DOS>=@from
			AND DOS<dateadd(day,1,@to)
			AND (E.inserted_user_pk=@coder OR @coder=0)
			AND (E.provider_pk=@physician OR @physician=0)
			AND (E.FIN=@FIN OR @FIN='')
			AND  E.h_id= @h_id
			AND (@extraParam='' OR (@extraParam='T' AND IsNull(Q.task_text,'')<>'') OR (@extraParam='D' AND IsNull(Q.denial_text,'')<>''))
		END
END



GO
