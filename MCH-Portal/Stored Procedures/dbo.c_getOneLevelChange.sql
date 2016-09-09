SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		<Amjad Ali Awan>
-- Create date: <12 Feb 2015>
-- Description:	<Help to create One Level change report>
-- =============================================
-- c_getOneLevelChange '01-1-2014','07-24-2014',0,0,0,'','T',1,1,0
CREATE PROCEDURE [dbo].[c_getOneLevelChange] 
	@from date,
	@to date,
	@coder smallint,
	@department smallint,
	@physician smallint,
	@FIN smallint,
	@extraParam varchar(1),
	@h_id smallint,
	@dateType int,
	@ReportType int
	
AS
BEGIN
	
	DECLARE @DepartmentQuery as varchar(MAX)
	DECLARE @FinalQuery as varchar(MAX)
	DECLARE @DateType_Text as varchar(MAX)
	DECLARE @ReportType_Text AS VARCHAR(MAX)
	DECLARE @min_e_pk AS Int
	DECLARE @max_e_pk AS Int

	---------
	
	----------

	if (@dateType=0)
	BEGIN
		set @max_e_pk=(select encounter_pk from  [MCH-Portal].dbo.tblEncounter where encounter_pk = ( select max(encounter_pk) from [MCH-Portal].dbo.tblEncounter Where (IsNull([CPT_EM_TMI_olc],'')!='' or IsNull(change,0)=2) and inserted_date>=@from
		AND inserted_date<dateadd(day,1,@to) ))
		set @min_e_pk=(select encounter_pk from  [MCH-Portal].dbo.tblEncounter where encounter_pk = ( select min(encounter_pk) from [MCH-Portal].dbo.tblEncounter Where (IsNull([CPT_EM_TMI_olc],'')!='' or IsNull(change,0)=2 ) and inserted_date>=@from
		AND inserted_date<dateadd(day,1,@to) ))
	END
	ELSE
	BEGIN
		set @max_e_pk=(select encounter_pk from  [MCH-Portal].dbo.tblEncounter where encounter_pk = ( select max(encounter_pk) from [MCH-Portal].dbo.tblEncounter Where (IsNull([CPT_EM_TMI_olc],'')!='' or IsNull(change,0)=2 ) and DOS>=@from
		AND DOS<dateadd(day,1,@to) ))
		set @min_e_pk=(select encounter_pk from  [MCH-Portal].dbo.tblEncounter where encounter_pk = ( select min(encounter_pk) from [MCH-Portal].dbo.tblEncounter Where (IsNull([CPT_EM_TMI_olc],'')!='' or IsNull(change,0)=2 ) and DOS>=@from
		AND DOS<dateadd(day,1,@to) ))
	END

	--	select @max_e_pk, @min_e_pk

	SELECT encounter_pk, [1],[10],[26],[30],[44],[52],[60],[61],[62],[63],[64],[65],[66],[67],[68],[71] INTO #temp_table from 
             (
                 select encounter_pk, [oneCheck_pk],oneCheck_score
                 from [MCH-Portal].[dbo].[tblOneLevelData] 
            ) x
           pivot 
            (
                sum(oneCheck_score) 
				for [oneCheck_pk] in ([1],[10],[26],[30],[44],[52],[60],[61],[62],[63],[64],[65],[66],[67],[68],[71])
            ) p where encounter_pk>=@min_e_pk and encounter_pk <=@max_e_pk




DECLARE @department_pk AS SmallInt
	DECLARE department_cursor CURSOR FOR 
	SELECT D.department_pk FROM tblDepartment D WITH (NOLOCK) INNER JOIN tblH_Department HD WITH (NOLOCK) ON HD.Department_PK = D.Department_PK and HD.h_id=@h_id  WHERE @department=0 OR D.department_pk=@department ORDER BY department;
	OPEN department_cursor
	FETCH NEXT FROM department_cursor INTO @department_pk
	
	IF (@dateType=0)
	BEGIN
		SET @DateType_Text='E.inserted_date';
	END
	ELSE
	BEGIN
		SET @DateType_Text='E.DOS'; 
	END

	IF (@ReportType=0)
	BEGIN
		--SET @ReportType_Text=' AND (ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(CPT_EM_TMI)= 1 and ABS(cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal))<5 ) '
		SET @ReportType_Text='AND (ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org]),1))= 1 AND ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2))=1 and ABS(cast(SUBSTRING (CPT_EM_Org,LEN([CPT_EM_Org])-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2) as decimal))<5 ) ' 
	END
	ELSE IF (@ReportType=5)
	BEGIN
		--SET @ReportType_Text=' AND (ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(CPT_EM_TMI)= 1 and ABS(cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal))>4 and change>1 ) '
		SET @ReportType_Text='AND (ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org]),1))= 1  AND ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2))=1 and ABS(cast(SUBSTRING (CPT_EM_Org,LEN([CPT_EM_Org])-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2) as decimal))>4 and change>1  ) ' 
	END
	ELSE 
	BEGIN
		--SET @ReportType_Text=' AND (ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(CPT_EM_TMI)= 1 and ABS(cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal))='+CAST(@ReportType AS VARCHAR)+') '
		SET @ReportType_Text='AND (ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org]),1))= 1  AND ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2))=1  and ABS(cast(SUBSTRING (CPT_EM_Org,LEN([CPT_EM_Org])-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2) as decimal)))='+CAST(@ReportType AS VARCHAR)+' ) ' 
	END

DECLARE @level_change AS varchar(max);

set @DepartmentQuery='	SELECT d.department,ISNULL(TE.count_id,0) total,ISNULL(LE.one,0) ONE,ISNULL(two,0) TWO,ISNULL(three,0) THREE,ISNULL(four,0) FOUR,ISNULL(category,0) CATEGORY FROM tblDepartment D WITH (NOLOCK) 
 INNER JOIN tblH_Department HD WITH (NOLOCK) ON HD.Department_PK = D.Department_PK and HD.h_id='+cast(@h_id as varchar)+'
 left join (SELECT count(department_pk) count_id,max(department_pk) id FROM tblEncounter E WITH (NOLOCK) WHERE 
		'+@DateType_Text+'>='''+cast(@from as varchar)+''' 
		AND '+@DateType_Text+'<dateadd(day,1,'''+cast(@to as varchar)+''') AND (E.inserted_user_pk='+cast(@coder as varchar)+' OR '+cast(@coder as varchar)+'=0)
		AND (E.provider_pk='+cast(@physician as varchar)+' OR '+cast(@physician as varchar)+'=0)
		AND (E.FIN='+cast(@FIN as varchar)+' OR '+cast(@FIN as varchar)+'='''')
		AND  E.h_id='+ cast(@h_id as varchar)+' 
		 Group by department_pk ) as TE on TE.id=D.department_pk
 left join (select max(department_pk) id,sum([One Level]) one ,sum([Two Level]) two,sum([Three Level]) three, sum([Four Level]) four,sum(category) category from (SELECT department_pk,department_pk id 
,CASE WHEN ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org]),1))= 1 and ABS(cast(SUBSTRING (CPT_EM_Org,LEN([CPT_EM_Org])-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2) as decimal))=1 THEN 1
			else 0
			END [One Level]
			,CASE WHEN ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org]),1))= 1 and ABS(cast(SUBSTRING (CPT_EM_Org,LEN([CPT_EM_Org])-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2) as decimal))=2 THEN 1
			else 0
			END [Two Level]
			,CASE WHEN ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org]),1))= 1 and ABS(cast(SUBSTRING (CPT_EM_Org,LEN([CPT_EM_Org])-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2) as decimal))=3 THEN 1
			else 0
			END [Three Level]
			,CASE WHEN ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org]),1))= 1 and ABS(cast(SUBSTRING (CPT_EM_Org,LEN([CPT_EM_Org])-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2) as decimal))=4 THEN 1
			else 0
			END [Four Level]
			,CASE WHEN ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org]),1))= 1 and ABS(cast(SUBSTRING (CPT_EM_Org,LEN([CPT_EM_Org])-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org])-1,2) as decimal))>4 and CHANGE>1 THEN 1
			else 0
			END [category]
			
FROM tblEncounter E  WITH (NOLOCK)  
INNER JOIN #temp_table ONC ON ONC.encounter_pk =E.encounter_pk
WHERE (E.provider_pk='+cast(@physician as varchar)+' OR '+cast(@physician as varchar)+'=0)
		'+@ReportType_Text+'
		AND '+@DateType_Text+'>='''+cast(@from as varchar)+''' 
		AND '+@DateType_Text+'<dateadd(day,1,'''+cast(@to as varchar)+''')
		AND (E.inserted_user_pk='+cast(@coder as varchar)+' OR '+cast(@coder as varchar)+'=0)
		AND (E.FIN='+cast(@FIN as varchar)+' OR '+cast(@FIN as varchar)+'='''')
		 ) e  group by e.department_pk) as LE on LE.id=D.department_pk WHERE '+ CAST(@department AS VARCHAR)+'=0 OR d.department_pk='+CAST(@department AS VARCHAR) +' ORDER BY department';

EXEC (@DepartmentQuery)
--Print (@DepartmentQuery)


	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @FinalQuery='SELECT 
			 E.encounter_pk [Download Link]
			,[text_data] [Overall Comments]
			,isNull([1],0) [HPI x]
			,isNull([10],0) [ROS x]
			,isNull([26],0) [PFSH x]
			,isNull([30],0) [Physical Exam]
			,isNull([44],0) [Number of Diagnosis or Treatment Options]
			,isNull([52],0) [Amount and/or Complexity of Data]
			,CASE 
			WHEN [65] = ''1''  THEN ''Straightforward''
			WHEN [66] = ''2'' THEN ''Low''
			WHEN [67] = ''3'' THEN ''Moderate''
			WHEN [68] = ''4'' THEN ''High''
			ELSE ''''
			END [Overall Medical Decision Making Level]
			,department [Department]
			,provider_name [Physician Name]
			,M.member_id [Medical Record #]
			,[FIN] [PowerChart Fin #]
			,DOS [Date of Service]
			,[CPT_EM_Org] [MCH Orig CPT - E & M]
			,[CPT_EM_TMI] [TMI CPT - E & M]
			,CASE
			WHEN ISNUMERIC(SUBSTRING ([CPT_EM_Org],LEN([CPT_EM_Org] ),1) )=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] ),1) )= 1 AND ABS(cast(SUBSTRING ([CPT_EM_Org],LEN([CPT_EM_Org] )-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] )-1,2) as decimal ))>4 THEN ''0'' 
			WHEN ISNUMERIC(SUBSTRING ([CPT_EM_Org],LEN([CPT_EM_Org] ),1) )=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] ),1) )= 1 AND ABS(cast(SUBSTRING ([CPT_EM_Org],LEN([CPT_EM_Org] )-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] )-1,2) as decimal ))=1 THEN ''1''
			WHEN ISNUMERIC(SUBSTRING ([CPT_EM_Org],LEN([CPT_EM_Org] ),1) )=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] ),1) )= 1 AND ABS(cast(SUBSTRING ([CPT_EM_Org],LEN([CPT_EM_Org] )-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] )-1,2) as decimal ))=2 THEN ''2''
			WHEN ISNUMERIC(SUBSTRING ([CPT_EM_Org],LEN([CPT_EM_Org] ),1) )=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] ),1) )= 1 AND ABS(cast(SUBSTRING ([CPT_EM_Org],LEN([CPT_EM_Org] )-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] )-1,2) as decimal ))=3 THEN ''3''
			WHEN ISNUMERIC(SUBSTRING ([CPT_EM_Org],LEN([CPT_EM_Org] ),1) )=1 and ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] ),1) )= 1 AND ABS(cast(SUBSTRING ([CPT_EM_Org],LEN([CPT_EM_Org] )-1,2) as decimal)-cast(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] )-1,2) as decimal ))=4 THEN ''4''
			ELSE ''ERROR''
			END [Level Status]
			,[CPT_Other_Org] [MCH Orig CPT - Other]
			,[CPT_Other_TMI] [TMI CPT - Other]
			,[DX_Org] [MCH Orig DX]
			,[DX_TMI] [TMI DX]
			,[change_reason] [Reasoning for Action Taken]
			,inserted_date [Date Coded]
			,C.Lastname+'', ''+C.Firstname [Coder ID]
		FROM tblEncounter E WITH (NOLOCK)
		INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
		INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
		INNER JOIN tblUser C WITH (NOLOCK) ON C.User_PK = E.inserted_user_pk
		LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
		LEFT JOIN tblUser S WITH (NOLOCK) ON S.User_PK = Q.tasked_user_pk
		INNER JOIN #temp_table ONC ON ONC.encounter_pk =E.encounter_pk
		left JOIN tblOneLevelText ONCT ON ONCT.encounter_pk =E.encounter_pk		
		WHERE  (E.inserted_user_pk='+cast(@coder as varchar)+' OR '+cast(@coder as varchar)+'=0)' +@ReportType_Text+'
		AND E.department_pk='+CAST(@department_pk AS VARCHAR) + '
		AND '+@DateType_Text+'>='''+cast(@from as varchar)+''' 
		AND '+@DateType_Text+'<dateadd(day,1,'''+cast(@to as varchar)+''')
		AND (E.provider_pk='+cast(@physician as varchar)+' OR '+cast(@physician as varchar)+'=0)
		AND ISNUMERIC(SUBSTRING (CPT_EM_TMI,LEN([CPT_EM_Org] ),1))= 1 
		AND (E.FIN='+cast(@FIN as varchar)+' OR '+cast(@FIN as varchar)+'='''')'
		
		EXEC (@FinalQuery)
		FETCH NEXT FROM department_cursor INTO @department_pk 

		
			--WHEN ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(CPT_EM_TMI)= 1 AND ABS(cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal))>4 AND CHANGE=2 THEN ''CATEGORY CHANGE''
			--WHEN ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(CPT_EM_TMI)= 1 AND ABS(cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal))>4 AND CHANGE=3 THEN ''CATEGORY-LEVEL CHANGE''
		
	END
	


	CLOSE department_cursor
	DEALLOCATE department_cursor
END





GO
