SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- Updated by Amjad Ali Awan on 2 Jan 2015.
-- added Physicain and Fin
-- Updated by Amjad Ali Awan on 26 Feb 2015.


-- ==============================================
-- c_getQueryExport '07/01/2015','08/24/2015',0,1,0,'',0,0
CREATE PROCEDURE [dbo].[c_getQueryExport] 
	@from date,
	@to date,
	@coder smallint,
	@department smallint,
	@specialty smallint,
	@physician smallint,
	@FIN varchar(15),
	@case varchar(15),
	@h_id int,
	@dateType int
AS
BEGIN
DECLARE @department_pk AS SmallInt
	 
	
	if(@dateType=0)
	BEGIN
	SELECT D.department,D.department_pk,COUNT(Q.Encounter_PK) OpenQueries FROM tblDepartment D WITH (NOLOCK) 
		LEFT JOIN tblEncounter E WITH (NOLOCK) ON D.department_pk = E.department_pk
		LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk AND IsNull(Q.QueryResponse_pk,0)=0
			AND inserted_date >= @from 
			AND inserted_date <dateadd(day,1,@to)
			AND E.h_id = @h_id 
	WHERE (@department=0 OR D.department_pk=@department)
	GROUP BY D.department,D.department_pk
	ORDER BY D.department
	
	
	
	DECLARE department_cursor CURSOR FOR 
	SELECT department_pk FROM tblDepartment WITH (NOLOCK) WHERE (@department=0 OR department_pk=@department) ORDER BY department;

	OPEN department_cursor

	FETCH NEXT FROM department_cursor INTO @department_pk

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT 
			e.encounter_pk [Case #]		
		  ,D.department [Practice/Department]
		  ,Sp.Specialty [Specialty]
		  ,provider_name [Physician Name]
		  ,[FIN] [Fin Number]		
		  ,M.member_id [Medical Record Number]
		  ,DOS [DOS]
		  ,inserted_date [Date Query Sent]
		  ,IsNull(QR.QueryResponse,'Pending') [Query Status]
		  ,Q.query_text [Reason for Query   (Include CPT/DX codes etc..)]
		  ,Q.response_text [MD Query Response]
		  ,Q.updated_date [Response Date]
		  ,Q.task_text [HIM/Independent Reviewer comments]
		FROM tblEncounter E WITH (NOLOCK)
		INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
		INNER JOIN tblSpecialty Sp WITH (NOLOCK) ON Sp.id=P.Specialty_pk
		INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
		--INNER JOIN tblUser C ON C.User_PK = E.inserted_user_pk
		INNER JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
		--INNER JOIN tblUser S ON S.User_PK = Q.tasked_user_pk
		LEFT JOIN tblQueryResponse QR WITH (NOLOCK) ON QR.QueryResponse_pk = Q.QueryResponse_pk
		WHERE inserted_date>=@from
		AND inserted_date<dateadd(day,1,@to)
		AND E.department_pk=@department_pk
		AND E.h_id = @h_id
		AND (E.inserted_user_pk=@coder OR @coder=0)
		AND (E.provider_pk=@physician OR @physician=0)
		AND (P.Specialty_pk =@specialty OR @specialty=0)
		AND (E.encounter_pk=@case OR @case='')
		AND (E.FIN=@FIN OR @FIN='')
		AND Q.query_text<>''
		
		FETCH NEXT FROM department_cursor INTO @department_pk
	END
	
	CLOSE department_cursor
	DEALLOCATE department_cursor
	END
	ELSE
	BEGIN
	SELECT D.department,D.department_pk,COUNT(Q.Encounter_PK) OpenQueries FROM tblDepartment D WITH (NOLOCK) 
		LEFT JOIN tblEncounter E WITH (NOLOCK) ON D.department_pk = E.department_pk
		LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk AND IsNull(Q.QueryResponse_pk,0)=0
			AND DOS >= @from 
			AND DOS <dateadd(day,1,@to)
			AND E.h_id = @h_id 
			WHERE (@department=0 OR D.department_pk=@department)
	GROUP BY D.department,D.department_pk
	ORDER BY D.department
	
	
	
	DECLARE department_cursor CURSOR FOR
	SELECT department_pk FROM tblDepartment WITH (NOLOCK) WHERE (@department=0 OR department_pk=@department) ORDER BY department;

	OPEN department_cursor

	FETCH NEXT FROM department_cursor INTO @department_pk

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT 
		e.encounter_pk [Case #]		
		  ,D.department [Practice/Department]
		  ,Sp.Specialty [Specialty]
		  ,provider_name [Physician Name]
		  ,[FIN] [Fin Number]		
		  ,M.member_id [Medical Record Number]
		  ,DOS [DOS]
		  ,inserted_date [Date Query Sent]
		  ,IsNull(QR.QueryResponse,'Pending') [Query Status]
		  ,Q.query_text [Reason for Query   (Include CPT/DX codes etc..)]
		  ,Q.response_text [MD Query Response]
		  ,Q.updated_date [Response Date]
		 
		  ,Q.task_text [HIM/Independent Reviewer comments]
		FROM tblEncounter E WITH (NOLOCK)
		INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
		INNER JOIN tblSpecialty Sp WITH (NOLOCK) ON Sp.id=P.Specialty_pk
		INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
		--INNER JOIN tblUser C ON C.User_PK = E.inserted_user_pk
		INNER JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
		--INNER JOIN tblUser S ON S.User_PK = Q.tasked_user_pk
		LEFT JOIN tblQueryResponse QR WITH (NOLOCK) ON QR.QueryResponse_pk = Q.QueryResponse_pk
		WHERE DOS>=@from
		AND DOS<dateadd(day,1,@to)
		AND E.department_pk=@department_pk
		AND E.h_id = @h_id
		AND (E.inserted_user_pk=@coder OR @coder=0)
		AND (E.provider_pk=@physician OR @physician=0)
		AND (P.Specialty_pk =@specialty OR @specialty=0)
		AND (E.encounter_pk=@case OR @case='')
		AND (E.FIN=@FIN OR @FIN='')
		AND Q.query_text<>''
		
		FETCH NEXT FROM department_cursor INTO @department_pk
	END
	CLOSE department_cursor
	DEALLOCATE department_cursor
	END
	

END




GO
