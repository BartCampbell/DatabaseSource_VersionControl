SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sch_linkPrv] 
	@project int,
	@office bigint, 
	@provider bigint, 
	@user int
AS
BEGIN
		DECLARE @ProviderID AS VARCHAR(50)
		DECLARE @ProviderName AS VARCHAR(250)
		DECLARE @ProviderOffice AS BigInt
		SELECT @ProviderID=Provider_ID,@ProviderName=ISNULL(Lastname,'')+ISNULL(', '+Firstname,''),@ProviderOffice=ProviderOffice_PK FROM tblProvider P WITH (NOLOCK) INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK=P.ProviderMaster_PK WHERE Provider_PK=@provider

		UPDATE tblProvider WITH (ROWLOCK) SET ProviderOffice_pk=@office WHERE Provider_PK = @provider

		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date) 
		VALUES(@project, @ProviderOffice, 4,'Removed provider: ('+@ProviderID+') '+@ProviderName,@user,GETDATE())

		--If (@office<>0)
		--BEGIN
			INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date) 
			VALUES(@project, @office, 4,'Added provider: ('+@ProviderID+') '+@ProviderName,@user,GETDATE())

			UPDATE tblProviderOffice SET [Address]='Unknown Address: ('+@ProviderID+') '+@ProviderName WHERE ProviderOffice_pk=@office AND [Address]='NewAddressCreated'
		--END
		/*
		IF NOT EXISTS (SELECT * FROM cacheProviderOffice WITH (NOLOCK) WHERE Project_PK=@project AND ProviderOffice_PK=@office)
			INSERT INTO cacheProviderOffice(Project_PK,ProviderOffice_PK,charts,providers) VALUES(@project,@office,0,0)

		--Update Cache
		UPDATE cPO SET providers=o_provider, charts = o_charts
		FROM cacheProviderOffice cPO WITH (ROWLOCK) 
			Outer Apply (SELECT COUNT(DISTINCT S.Suspect_PK) o_charts, COUNT(DISTINCT S.Provider_PK) o_provider FROM tblSuspect S WITH (NOLOCK)
							INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK WHERE S.Project_PK=cPO.Project_PK AND P.ProviderOffice_PK = cPO.ProviderOffice_PK
			) T
		WHERE cPO.Project_PK=@project AND cPO.ProviderOffice_PK IN (@office,@ProviderOffice)	

		DELETE FROM cacheProviderOffice WITH (ROWLOCK) WHERE charts = 0
			*/
END
GO
