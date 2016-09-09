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
-- c_getRICC '1-1-2015','06-06-2015',0,0,0,0,0,0,0
CREATE PROCEDURE [dbo].[c_getRICC] 
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
	SELECT * FROM tblDepartment WITH (NOLOCK) WHERE @department=0 OR department_pk=@department ORDER BY department
	
	DECLARE @department_pk AS SmallInt
	DECLARE department_cursor CURSOR FOR 
	SELECT department_pk FROM tblDepartment WITH (NOLOCK) WHERE @department=0 OR department_pk=@department ORDER BY department;

	OPEN department_cursor

	FETCH NEXT FROM department_cursor INTO @department_pk
	if(@dateType=0)
	BEGIN
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT 
			provider_name [Physician Name]
		  ,[FIN] [PowerChart Fin #]
		  ,M.member_id [Medical Record #]
		  ,DOS [Date of Service]
		  ,department [Department]
		  ,Q.task_text [Task]
		  ,inserted_date [Date Coded]
		  ,C.Lastname+', '+C.Firstname [Coder ID]
		  
		FROM tblEncounter E WITH (NOLOCK)
		INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
		INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
		INNER JOIN tblUser C WITH (NOLOCK) ON C.User_PK = E.inserted_user_pk
		LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
		
		WHERE inserted_date>=@from
		AND inserted_date<dateadd(day,1,@to)
		AND (E.inserted_user_pk=@coder OR @coder=0)
		AND (E.provider_pk=@physician OR @physician=0)
		AND (E.FIN=@FIN OR @FIN='')
		AND  E.department_pk=@department_pk
		AND  E.h_id= @h_id
		AND  (E.tpa= 1 or e.mor=1)
		
		
		FETCH NEXT FROM department_cursor INTO @department_pk
	END
	END
	ELSE
	BEGIN
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT 
			provider_name [Physician Name]
		  ,[FIN] [PowerChart Fin #]
		  ,M.member_id [Medical Record #]
		  ,DOS [Date of Service]
		  ,department [Department]
		  ,Q.task_text [Task]
		  ,inserted_date [Date Coded]
		  ,C.Lastname+', '+C.Firstname [Coder ID]
		  
		FROM tblEncounter E WITH (NOLOCK)
		INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
		INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
		INNER JOIN tblUser C WITH (NOLOCK) ON C.User_PK = E.inserted_user_pk
		LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
		
		WHERE inserted_date>=@from
		AND inserted_date<dateadd(day,1,@to)
		AND (E.inserted_user_pk=@coder OR @coder=0)
		AND (E.provider_pk=@physician OR @physician=0)
		AND (E.FIN=@FIN OR @FIN='')
		AND  E.department_pk=@department_pk
		AND  E.h_id= @h_id
		AND  (E.tpa= 1 or e.mor=1)
		
		
		FETCH NEXT FROM department_cursor INTO @department_pk
	END
	END
	CLOSE department_cursor
	DEALLOCATE department_cursor
END


GO
