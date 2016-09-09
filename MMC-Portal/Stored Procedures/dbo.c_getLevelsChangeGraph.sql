SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Amjad Ali Awan>
-- Alter date: <26 Aug 2015>
-- Description:	<Help to Alter all Level change Graph>
-- =============================================
-- c_getLevelsChangeGraph '08/01/2015','10/23/2015',0,0,0,'','',0,0,1
CREATE PROCEDURE [dbo].[c_getLevelsChangeGraph] 
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
	
	DECLARE @FinalQuery as varchar(MAX)
	DECLARE @DateType_Text as varchar(MAX)
	DECLARE @department_Text as varchar(MAX)
	DECLARE @ReportType_Text AS VARCHAR(MAX)
	DECLARE @min_e_pk AS Int
	DECLARE @max_e_pk AS Int

	if (@dateType=0)
	BEGIN
		set @max_e_pk=(select encounter_pk from  [MCH-Portal].dbo.tblEncounter where encounter_pk = ( select max(encounter_pk) from [MCH-Portal].dbo.tblEncounter Where IsNull([CPT_EM_TMI_olc],'')!='' and inserted_date>=@from
		AND inserted_date<dateadd(day,1,@to) ))
		set @min_e_pk=(select encounter_pk from  [MCH-Portal].dbo.tblEncounter where encounter_pk = ( select min(encounter_pk) from [MCH-Portal].dbo.tblEncounter Where IsNull([CPT_EM_TMI_olc],'')!='' and inserted_date>=@from
		AND inserted_date<dateadd(day,1,@to) ))
	END
	ELSE
	BEGIN
		set @max_e_pk=(select encounter_pk from  [MCH-Portal].dbo.tblEncounter where encounter_pk = ( select max(encounter_pk) from [MCH-Portal].dbo.tblEncounter Where IsNull([CPT_EM_TMI_olc],'')!='' and inserted_date>=@from
		AND DOS<dateadd(day,1,@to) ))
		set @min_e_pk=(select encounter_pk from  [MCH-Portal].dbo.tblEncounter where encounter_pk = ( select min(encounter_pk) from [MCH-Portal].dbo.tblEncounter Where IsNull([CPT_EM_TMI_olc],'')!='' and inserted_date>=@from
		AND DOS<dateadd(day,1,@to) ))
	END



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

	if (@department=0)
	BEGIN
	set @department_Text=''
	END
	ELSE
	BEGIN
	set @department_Text='AND  E.department_pk='+CAST(@department AS VARCHAR)
	END
	
	IF (@dateType=0)
	BEGIN
		SET @DateType_Text='inserted_date'
	END
	ELSE
	BEGIN
		SET @DateType_Text='DOS'
	END

	IF (@ReportType=0)
	BEGIN
		SET @ReportType_Text=''
	END
	ELSE
	BEGIN
		SET @ReportType_Text=' AND (ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(CPT_EM_TMI)= 1 and ABS(cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal))='+CAST(@ReportType AS VARCHAR)+') '
		--SET @ReportType_Text=' and (cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal)='+CAST(@ReportType AS VARCHAR)+') '
	END

	set @FinalQuery='SELECT 
		 MAX(provider_name) [Physician Name]
		,count(cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal)) [one]
		,ABS(cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal)) [level]
		FROM tblEncounter E WITH (NOLOCK)
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
		INNER JOIN tblUser C WITH (NOLOCK) ON C.User_PK = E.inserted_user_pk
		LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
		LEFT JOIN tblUser S WITH (NOLOCK) ON S.User_PK = Q.tasked_user_pk
		INNER JOIN #temp_table ONC ON ONC.encounter_pk =E.encounter_pk
		WHERE 
		'+@DateType_Text+'>='''+cast(@from as varchar)+''' 
		AND '+@DateType_Text+'<dateadd(day,1,'''+cast(@to as varchar)+''')
		'+@ReportType_Text+'
		 AND (ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(CPT_EM_TMI)= 1 )
		AND (E.inserted_user_pk='+cast(@coder as varchar)+' OR '+cast(@coder as varchar)+'=0)
		AND (E.provider_pk='+cast(@physician as varchar)+' OR '+cast(@physician as varchar)+'=0)
		AND (E.FIN='+cast(@FIN as varchar)+' OR '+cast(@FIN as varchar)+'='''')
		AND IsNull(E.CPT_EM_TMI_olc,'''')!=''''
		AND ABS(cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal))<5 AND istemp=0
		
		'+@department_Text+' GROUP BY E.provider_pk,abs((cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal))) order by e.provider_pk'
		
		EXEC (@FinalQuery)

		set @FinalQuery='SELECT 
			 MAX(provider_name) [Physician Name]
		FROM tblEncounter E WITH (NOLOCK)
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
		INNER JOIN tblUser C WITH (NOLOCK) ON C.User_PK = E.inserted_user_pk
		LEFT JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
		LEFT JOIN tblUser S WITH (NOLOCK) ON S.User_PK = Q.tasked_user_pk
		INNER JOIN #temp_table ONC ON ONC.encounter_pk =E.encounter_pk
		WHERE 
		'+@DateType_Text+'>='''+cast(@from as varchar)+''' 
		AND '+@DateType_Text+'<dateadd(day,1,'''+cast(@to as varchar)+''')
		'+@ReportType_Text+'
		 AND (ISNUMERIC(CPT_EM_Org)=1 and ISNUMERIC(CPT_EM_TMI)= 1 )
		AND (E.inserted_user_pk='+cast(@coder as varchar)+' OR '+cast(@coder as varchar)+'=0)
		AND (E.provider_pk='+cast(@physician as varchar)+' OR '+cast(@physician as varchar)+'=0)
		AND (E.FIN='+cast(@FIN as varchar)+' OR '+cast(@FIN as varchar)+'='''')
		AND IsNull(E.CPT_EM_TMI_olc,'''')!=''''
		AND ABS(cast(CPT_EM_Org as decimal)-cast(CPT_EM_TMI as decimal))<5 AND istemp=0
		 
		'+@department_Text+' GROUP BY E.provider_pk'
		
		EXEC (@FinalQuery)

		
	
END



GO
