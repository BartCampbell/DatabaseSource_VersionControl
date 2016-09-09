SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[c_UpdateAddEncounter] 
	@id int, 
	@department smallint,
	@provider smallint, 
	@specialty smallint,
	@FIN varchar(15), 	
	@member int,
	@dos date, 
	@CPT_EM_Org varchar(max),
    @CPT_Other_Org varchar(max),
    @HCPCS varchar(max),
	@AD varchar(max),
	@Diag varchar(max),
    @CoderNote varchar(MAX),
    @inserted_user_pk smallint,
    @query varchar(250),
    @staff_user_pk smallint,
    @task varchar(250),
    @denial varchar(250),
    @member_name varchar(50),
	@h_id smallint,
    @Admit_Date date,
	@adm_time varchar(5),
	@adm_am varchar(5),
	@Discharge_Date varchar(12),
	@Dis_time varchar(5),
	@Dis_am varchar(5),
	@Case varchar(30),
	@case_status varchar(1),
	@DOB date
AS
BEGIN
	RETRY: -- Label RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @MDResponse AS SMALLINT = 0
		DECLARE @Case_pk AS BIGINT = 0
		IF (@Discharge_Date='') set @Discharge_Date=NULL;

		IF (@query='QUERY')
		BEGIN
			SET @query='';

			--//@adm_time,	@adm_am ,@Dis_time ,@Dis_am ,@Case,	@case_status 
			INSERT INTO tblEncounter([department_pk],[provider_pk],[FIN],[member_pk],[DOS],[CPT_EM_Org],[CPT_Other_Org],[HCPCS],[AD],[Diag],[CoderNote],[inserted_user_pk],[inserted_date],parent_encounter_pk,[h_id],[Case_pk],[specialty])
			SELECT [department_pk],[provider_pk],[FIN],[member_pk],[DOS], @CPT_EM_Org, @CPT_Other_Org, @HCPCS, @AD,@Diag,@CoderNote, @inserted_user_pk,GETDATE(),@id,@h_id,[case_pk],[specialty] FROM tblEncounter WHERE encounter_pk=@id;
				
			SELECT @id=@@IDENTITY;		
			SET @MDResponse = @member
		END
		ELSE IF (@id=0)
		BEGIN
			Select @Case_pk=case_pk from tblcase ca where ca.member_pk= @member and ca.Admit_Date=@Admit_Date and ca.admit_time=@adm_time and ca.admit_am=@adm_am
			IF (@Case_pk=0)
			BEGIN
				INSERT INTO tblcase([member_pk],Admit_Date,Discharge_Date,[admit_time],[admit_am] ,[discharg_time] ,[discharg_am] ,[case_status],[DOB])
				VALUES( @member,@Admit_Date,cast(@Discharge_Date as date),@adm_time,	@adm_am ,@Dis_time ,@Dis_am ,@case_status,@DOB)
				SELECT @Case_pk=@@IDENTITY;
			END
			ELSE
			BEGIN
			UPDATE tblcase set Discharge_Date=cast(@Discharge_Date as date),discharg_time=@Dis_time,discharg_am=@Dis_am,case_status=@case_status where case_pk=@Case_pk;
			END

			INSERT INTO tblEncounter([department_pk],[provider_pk],[FIN],[member_pk],[DOS],[CPT_EM_Org],[CPT_Other_Org],[HCPCS],[AD],[Diag],[CoderNote],[inserted_user_pk],[inserted_date],[h_id],[case_pk],[specialty])
			VALUES(@department, @provider, @FIN, @member, @dos, @CPT_EM_Org, @CPT_Other_Org, @HCPCS, @AD,@Diag,@CoderNote, @inserted_user_pk,GETDATE(),@h_id,@case_pk,@specialty)
			
			SELECT @id=@@IDENTITY;
			
			Update tblMember SET member_name = @member_name,DOB=@DOB WHERE member_pk = @member
		END
		ELSE
		BEGIN
			SET @Case_pk=@Case;
			UPDATE tblcase set Discharge_Date=cast(@Discharge_Date as date),discharg_time=@Dis_time,discharg_am=@Dis_am,case_status=@case_status where case_pk=@Case_pk;
			Update tblEncounter SET [department_pk]=@department,[provider_pk]=@provider,
				[FIN]=@FIN,[member_pk]=@member,[DOS]=@dos,
				[CPT_EM_Org]=@CPT_EM_Org,[CPT_Other_Org]=@CPT_Other_Org,[HCPCS]=@HCPCS,
				[AD]=@AD,[Diag]=@Diag,[CoderNote]=@CoderNote,[inserted_user_pk]=@inserted_user_pk,
				[inserted_date]=GETDATE(),
				[h_id]=@h_id,
				[case_pk] = @Case_pk,
				[specialty] = @specialty	
				WHERE encounter_pk=@id
			
			DELETE FROM tblQuery WHERE Encounter_PK=@id
		
			Update tblMember SET member_name = @member_name WHERE member_pk = @member
		END

		IF (@query<>'' OR @task<>'' OR @denial<>'')
		BEGIN
			INSERT INTO tblQuery(Encounter_PK,tasked_user_pk,query_text,task_text,denial_text,QueryResponse_pk)
			VALUES(@id,@staff_user_pk,@query,@task,@denial,@MDResponse)
		END
		
		--SELECT @id Encounter_PK
		DECLARE @IDs AS varchar(50) = cast(@Case_pk as varchar) +','+cast(@id as varchar);
		select @IDs Encounter_PK
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
