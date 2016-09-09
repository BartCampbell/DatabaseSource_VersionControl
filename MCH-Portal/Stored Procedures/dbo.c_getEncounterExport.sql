SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- Modify by : Amjad Ali Awan dated 26-02-2015
-- c_getEncounterExport '07-01-2015','07-31-2015',0,0,0,0,0,0,1
CREATE PROCEDURE [dbo].[c_getEncounterExport] 
	@from date,
	@to date,
	@coder smallint,
	@department smallint,
	@physician smallint,
	@FIN varchar(15),
	@extraParam varchar(1),
	@h_id int,
	@dateType int
AS
BEGIN
	SELECT d.* FROM tblDepartment D WITH (NOLOCK) INNER JOIN tblH_Department HD WITH (NOLOCK) ON HD.Department_PK = D.Department_PK and HD.h_id=@h_id  WHERE @department=0 OR D.department_pk=@department ORDER BY d.department
	
	DECLARE @department_pk AS SmallInt
	DECLARE department_cursor CURSOR FOR 
	SELECT d.department_pk FROM tblDepartment D WITH (NOLOCK) INNER JOIN tblH_Department HD WITH (NOLOCK) ON HD.Department_PK = D.Department_PK and HD.h_id=@h_id WHERE @department=0 OR D.department_pk=@department ORDER BY d.department;

	OPEN department_cursor

	FETCH NEXT FROM department_cursor INTO @department_pk

	WHILE @@FETCH_STATUS = 0
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
		AND  E.department_pk=@department_pk
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
			AND  E.department_pk=@department_pk
			AND  E.h_id= @h_id
			AND (@extraParam='' OR (@extraParam='T' AND IsNull(Q.task_text,'')<>'') OR (@extraParam='D' AND IsNull(Q.denial_text,'')<>''))
		END

		FETCH NEXT FROM department_cursor INTO @department_pk
	END
	
	CLOSE department_cursor
	DEALLOCATE department_cursor
END


GO
