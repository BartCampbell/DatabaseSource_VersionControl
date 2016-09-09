SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[c_getEncounterExport] 
	@from date,
	@to date,
	@coder smallint,
	@department smallint,
	@specialty smallint,
	@physician smallint,
	@FIN varchar(15),
	@case varchar(15),
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
		E.encounter_pk [Encounter #]
		,E.case_pk [Case #]
		,CASE 
			WHEN case_status=1 THEN 'Open'
			WHEN case_status=2 THEN 'Close'
			
		END  [Status]
		,Sp.Specialty [Specialty]
		,provider_name [Physician Name]
		  ,[FIN] [PowerChart Fin #]
		  ,M.member_id [MR#]
		  ,M.member_name [PT Name]
		  ,M.DOB [PT DOB]
		  ,DOS [DOS]
		  ,Admit_Date [ADMIT DATE]
		  ,Discharge_Date [DISCHARGE DATE]
		  ,[CPT_EM_Org] [CPT PROCEDURES]
		  
		  ,[AD] [ADMIT DIAGNOSIS]
		  ,[CPT_Other_Org] [PRINCIPAL DIAGNOSIS ]
		   
		  
		  
		  ,[Diag] [ADDITIONAL DIAGNOSIS]
		  ,[HCPCS] [ICD-10-PCS PROCEDURES]
		  ,[CoderNote] [RATIONALE / CODER NOTE]
		  ,inserted_date [Date Coded]
		  ,SUBSTRING(C.Firstname, 1, 1)+ '. '+C.Lastname [Coder ID]
		  ,IsNull(Q.task_text + ' / ' + S.Lastname+', '+S.Firstname,'') [Task]
		  ,IsNull(Q.query_text,'') [Query]
		  ,IsNull(Q.denial_text,'') [Denial]
		  ,department [Department]
		  
		FROM tblEncounter E WITH (NOLOCK)
		INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
		INNER JOIN tblSpecialty Sp WITH (NOLOCK) ON Sp.id = E.specialty
		INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
		INNER JOIN tblUser C WITH (NOLOCK) ON C.User_PK = E.inserted_user_pk
		left JOIN tblcase Ca WITH (NOLOCK) ON Ca.case_pk = E.case_pk
		LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
		LEFT JOIN tblUser S WITH (NOLOCK) ON S.User_PK = Q.tasked_user_pk
		WHERE 
		inserted_date>=@from
		AND inserted_date<dateadd(day,1,@to)
		AND (E.inserted_user_pk=@coder OR @coder=0)
		AND (E.provider_pk=@physician OR @physician=0)
		AND (e.specialty =@specialty OR @specialty=0)
		AND (E.FIN=@FIN OR @FIN='')
		AND (E.encounter_pk= @case OR @case='')
		AND  E.department_pk=@department_pk
		AND  E.h_id= @h_id
		AND (@extraParam='' OR (@extraParam='T' AND IsNull(Q.task_text,'')<>'') OR (@extraParam='D' AND IsNull(Q.denial_text,'')<>''))
		END
		ELSE
		BEGIN
		SELECT 
		E.encounter_pk [Encounter #]
		,E.case_pk [Case #]
		,CASE 
			WHEN case_status=1 THEN 'Open'
			WHEN case_status=2 THEN 'Close'
			
		END  [Status]
		,Sp.Specialty [Specialty]
			,provider_name [Physician Name]
			,[FIN] [PowerChart Fin #]
			,M.member_id [MR#]
		  ,M.member_name [PT Name]
			 ,M.DOB [PT DOB]
		  ,DOS [DOS]
		  ,Admit_Date [ADMIT DATE]
		  ,Discharge_Date [DISCHARGE DATE]
		  ,[CPT_EM_Org] [CPT PROCEDURES]
		  
		  ,[AD] [ADMIT DIAGNOSIS]
		  ,[CPT_Other_Org] [PRINCIPAL DIAGNOSIS ]
		  
		  
		  ,[Diag] [ADDITIONAL DIAGNOSIS]
		  ,[HCPCS] [ICD-10-PCS PROCEDURES]
		  ,[CoderNote] [RATIONALE / CODER NOTE]
			,inserted_date [Date Coded]
			,SUBSTRING(C.Firstname, 1, 1)+ '. '+C.Lastname [Coder ID]
			,IsNull(Q.task_text + ' / ' + S.Lastname+', '+S.Firstname,'') [Task]
			,IsNull(Q.query_text,'') [Query]
			,IsNull(Q.denial_text,'') [Denial]
			,department [Department]
			
		FROM tblEncounter E WITH (NOLOCK)
			INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
			INNER JOIN tblSpecialty Sp WITH (NOLOCK) ON Sp.id = E.specialty
			INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
			INNER JOIN tblUser C WITH (NOLOCK) ON C.User_PK = E.inserted_user_pk
			left JOIN tblcase Ca WITH (NOLOCK) ON Ca.case_pk = E.case_pk
			LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
			LEFT JOIN tblUser S WITH (NOLOCK) ON S.User_PK = Q.tasked_user_pk
		WHERE 
			DOS>=@from
			AND DOS<dateadd(day,1,@to)
			AND (E.inserted_user_pk=@coder OR @coder=0)
			AND (E.provider_pk=@physician OR @physician=0)
			AND (E.specialty =@specialty OR @specialty=0)
			AND (E.FIN=@FIN OR @FIN='')
			AND (E.encounter_pk= @case OR @case='')
			AND  E.department_pk=@department_pk
			AND  E.h_id= @h_id
			AND (@extraParam='' OR (@extraParam='T' AND IsNull(Q.task_text,'')<>'') OR (@extraParam='D' AND IsNull(Q.denial_text,'')<>''))
		END

		FETCH NEXT FROM department_cursor INTO @department_pk
	END
	
	CLOSE department_cursor
	DEALLOCATE department_cursor
END;







GO
