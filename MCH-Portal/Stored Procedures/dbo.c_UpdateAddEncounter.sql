SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[c_UpdateAddEncounter] 
	@id int, 
	@department smallint,
	@provider smallint, 
	@FIN varchar(15), 	
	@member int,
	@dos date, 
	@CPT_EM_Org varchar(max),
    @CPT_Other_Org varchar(max),
    @DX_Org varchar(max),
    @CPT_EM_TMI varchar(max),
    @CPT_Other_TMI varchar(max),
    @DX_TMI varchar(max),
    @change_reason varchar(max),
    @inserted_user_pk smallint,
    @query varchar(250),
    @staff_user_pk smallint,
    @task varchar(250),
    @denial varchar(250),
    @member_name varchar(50),
	@CPT_EM_TMI_olc varchar(MAX),
    @h_id smallint,
    @sInsert varchar(MAX),
	@tpa smallint,
	@mor smallint,
	@Admit_Date date,
	@Discharge_Date date,
	@m_id int,
	@m_comments varchar(max),
	@change smallint
AS
BEGIN
	RETRY: -- Label RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @MDResponse AS SMALLINT = 0
		IF (@query='QUERY')
		BEGIN
			SET @query='';
			INSERT INTO tblEncounter([department_pk],[provider_pk],[FIN],[member_pk],[DOS],[CPT_EM_Org],[CPT_Other_Org],[DX_Org],[CPT_EM_TMI],[CPT_Other_TMI],[DX_TMI],[change_reason],[inserted_user_pk],[inserted_date],parent_encounter_pk,[CPT_EM_TMI_olc],[h_id],[tpa],[mor],[Admit_Date],[Discharge_Date],[change])
			SELECT [department_pk],[provider_pk],[FIN],[member_pk],[DOS], @CPT_EM_Org, @CPT_Other_Org, @DX_Org, @CPT_EM_TMI, @CPT_Other_TMI, @DX_TMI, @change_reason, @inserted_user_pk,GETDATE(),@id,@CPT_EM_TMI_olc,@h_id,@tpa,@mor,@Admit_Date,@Discharge_Date,@change FROM tblEncounter WHERE encounter_pk=@id;
				
			SELECT @id=@@IDENTITY;		
			SET @MDResponse = @member
		END
		ELSE IF (@id=0)
		BEGIN
			INSERT INTO tblEncounter([department_pk],[provider_pk],[FIN],[member_pk],[DOS],[CPT_EM_Org],[CPT_Other_Org],[DX_Org],[CPT_EM_TMI],[CPT_Other_TMI],[DX_TMI],[change_reason],[inserted_user_pk],[inserted_date],[CPT_EM_TMI_olc],[h_id],[tpa],[mor],Admit_Date,Discharge_Date,m_id,m_comments,[change])
			VALUES(@department, @provider, @FIN, @member, @dos, @CPT_EM_Org, @CPT_Other_Org, @DX_Org, @CPT_EM_TMI, @CPT_Other_TMI, @DX_TMI, @change_reason, @inserted_user_pk,GETDATE(),@CPT_EM_TMI_olc,@h_id,@tpa,@mor,@Admit_Date,@Discharge_Date,@m_id,@m_comments,@change)
			
			SELECT @id=@@IDENTITY;
			
			Update tblMember SET member_name = @member_name WHERE member_pk = @member
		END
		ELSE
		BEGIN
			Update tblEncounter SET [department_pk]=@department,[provider_pk]=@provider,
				[FIN]=@FIN,[member_pk]=@member,[DOS]=@dos,
				[CPT_EM_Org]=@CPT_EM_Org,[CPT_Other_Org]=@CPT_Other_Org,[DX_Org]=@DX_Org,
				[CPT_EM_TMI]=@CPT_EM_TMI,[CPT_Other_TMI]=@CPT_Other_TMI,[DX_TMI]=@DX_TMI,
				[change_reason]=@change_reason,[inserted_user_pk]=@inserted_user_pk,
				[inserted_date]=GETDATE(),CPT_EM_TMI_olc=@CPT_EM_TMI_olc,
				[h_id]=@h_id,
				[tpa]=@tpa,
				[mor]=@mor,
				Admit_Date=@Admit_date,
				Discharge_Date=@Discharge_Date,
				m_id=@m_id,
				m_comments=@m_comments,
				[change]=@change
				WHERE encounter_pk=@id
			
			DELETE FROM tblQuery WHERE Encounter_PK=@id
			DELETE FROM tblOneLevelData WHERE encounter_pk=@id
			DELETE FROM tblOneLevelText WHERE encounter_pk=@id
			Update tblMember SET member_name = @member_name WHERE member_pk = @member
		END

		IF (@query<>'' OR @task<>'' OR @denial<>'')
		BEGIN
			INSERT INTO tblQuery(Encounter_PK,tasked_user_pk,query_text,task_text,denial_text,QueryResponse_pk)
			VALUES(@id,@staff_user_pk,@query,@task,@denial,@MDResponse)
		END
		if(@sInsert<>'')
		BEGIN
		SET @sInsert=replace(@sInsert,'#EPK#',@id);
		EXEC(@sInsert);
		END
		SELECT @id Encounter_PK
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT 'Rollback Transaction'
		ROLLBACK TRANSACTION
		IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
		BEGIN
			WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
			GOTO RETRY -- Go to Label RETRY
		END
	END CATCH
END;
GO
