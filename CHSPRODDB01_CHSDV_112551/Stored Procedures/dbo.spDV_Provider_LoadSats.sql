SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/22/2016
-- Description:	Data Vault Provider Load - based on CHSDV.[dbo].[prDV_Provider_LoadSats]
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Provider_LoadSats]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--**S_PROVIDERDEMO LOAD
INSERT INTO [dbo].[S_ProviderDemo]
           ([S_ProviderDemo_RK],[LoadDate],[H_ProviderMaster_RK],[NPI],[TIN],[PIN],[LastName],[FirstName],[LastUpdated],[HashDiff],[RecordSource])
    SELECT
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.NPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.TIN,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PIN,''))),':',
			RTRIM(LTRIM(COALESCE(rw.LastName,''))),':',
			RTRIM(LTRIM(COALESCE(rw.FirstName,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.LastUpdated AS VARCHAR),'')))
			))
			),2)),
	 LoadDate, 
	 ProviderMasterHashKey,
	 [NPI],
	 [TIN],
	 [PIN],
	 [LastName],
	 [FirstName],
	 [LastUpdated],
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.NPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.TIN,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PIN,''))),':',
			RTRIM(LTRIM(COALESCE(rw.LastName,''))),':',
			RTRIM(LTRIM(COALESCE(rw.FirstName,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.LastUpdated AS VARCHAR),'')))
			))
			),2)),
	RecordSource
	FROM CHSStaging.adv.tblProviderMasterStage rw with(nolock)
	WHERE
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.NPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.TIN,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PIN,''))),':',
			RTRIM(LTRIM(COALESCE(rw.LastName,''))),':',
			RTRIM(LTRIM(COALESCE(rw.FirstName,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.LastUpdated AS VARCHAR),'')))
			))
			),2))
	not in (SELECT HashDiff FROM S_ProviderDemo WHERE 
					H_ProviderMaster_RK = rw.ProviderMasterHashKey and RecordEndDate is null )
					AND rw.cci = @CCI
	GROUP BY upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.NPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.TIN,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PIN,''))),':',
			RTRIM(LTRIM(COALESCE(rw.LastName,''))),':',
			RTRIM(LTRIM(COALESCE(rw.FirstName,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.LastUpdated AS VARCHAR),'')))
			))
			),2)),
	 LoadDate, 
	 ProviderMasterHashKey,
	 [NPI],
	 [TIN],
	 [PIN],
	 [LastName],
	 [FirstName],
	 [LastUpdated],
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.NPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.TIN,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PIN,''))),':',
			RTRIM(LTRIM(COALESCE(rw.LastName,''))),':',
			RTRIM(LTRIM(COALESCE(rw.FirstName,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.LastUpdated AS VARCHAR),'')))
			))
			),2)),
	RecordSource

	--RECORD END DATE CLEANUP
		UPDATE dbo.S_ProviderDemo set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_ProviderDemo z
			 Where
			  z.H_ProviderMaster_RK = a.H_ProviderMaster_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_ProviderDemo a
			Where a.RecordEndDate Is Null 


--**S_PROVIDEROffice LOAD
INSERT INTO [dbo].[S_ProviderOfficeDetail] ([S_ProviderOfficeDetail_RK],[LoadDate],[H_ProviderOffice_RK],[EMR_Type],[EMR_Type_PK],[GroupName],[HashDiff],[RecordSource])
      SELECT
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(a.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(a.EMR_Type,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(a.EMR_Type_PK AS VARCHAR),''))),':',
			RTRIM(LTRIM(COALESCE(a.GroupName,'')))
			))
			),2)),
	 a.LoadDate, 
	 a.ProviderOfficeHashKey,
	RTRIM(LTRIM(COALESCE(a.EMR_Type,''))) AS [EMR_Type],
	a.[EMR_Type_PK],
	RTRIM(LTRIM(COALESCE(a.GroupName,''))) AS GroupName,
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(a.EMR_Type,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(a.EMR_Type_PK AS VARCHAR),''))),':',
			RTRIM(LTRIM(COALESCE(a.GroupName,'')))
			))
			),2)),
	a.RecordSource
	FROM [CHSStaging].[adv].[tblProviderOfficeStage] a with(nolock)
                     
	WHERE
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(a.EMR_Type,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(a.EMR_Type_PK AS VARCHAR),''))),':',
			RTRIM(LTRIM(COALESCE(a.GroupName,'')))
			))
			),2))
	not in (SELECT HashDiff FROM S_ProviderOfficeDetail WHERE 
					H_ProviderOffice_RK = a.ProviderOfficeHashKey and RecordEndDate is null )
					AND a.cci = @CCI
	GROUP BY 	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(a.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(a.EMR_Type,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(a.EMR_Type_PK AS VARCHAR),''))),':',
			RTRIM(LTRIM(COALESCE(a.GroupName,'')))
			))
			),2)),
	 a.LoadDate, 
	 a.ProviderOfficeHashKey,
	RTRIM(LTRIM(COALESCE(a.EMR_Type,''))) ,
	a.[EMR_Type_PK],
	RTRIM(LTRIM(COALESCE(a.GroupName,''))) ,
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(a.EMR_Type,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(a.EMR_Type_PK AS VARCHAR),''))),':',
			RTRIM(LTRIM(COALESCE(a.GroupName,'')))
			))
			),2)),
	a.RecordSource
	
	--RECORD END DATE CLEANUP
		UPDATE dbo.S_ProviderOfficeDetail set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_ProviderOfficeDetail z
			 Where
			  z.H_ProviderOffice_RK = a.H_ProviderOffice_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_ProviderOfficeDetail a
			Where a.RecordEndDate Is Null 

--*** Insert Into S_Location
	INSERT INTO [dbo].[S_Location] ([S_Location_RK],[LoadDate],[H_Location_RK],[Address1],[ZIP],[HashDiff],[RecordSource])
		Select
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
						RTRIM(LTRIM(COALESCE(a.[Address],''))), ':',
                        RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))
															
				))
				),2)),
			a.LoadDate,
			  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(
															RTRIM(LTRIM(COALESCE(a.[Address],''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))
															  ))), 2)),
				RTRIM(LTRIM(COALESCE(a.[Address],''))) AS [Address],
				    RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),''))) AS ZipCode_PK,
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(a.[Address],''))), ':',
                        RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))
					))
				),2)),
				a.RecordSource
			FROM [CHSStaging].[adv].[tblProviderOfficeStage] a with(nolock)
		 Where 
			upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
						RTRIM(LTRIM(COALESCE(a.[Address],''))), ':',
                        RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))
					))
				),2)) not in (Select HashDiff from S_Location where RecordEndDate is null)
				AND a.cci = @CCI
		GROUP BY upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
						RTRIM(LTRIM(COALESCE(a.[Address],''))), ':',
                        RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))
															
				))
				),2)),
			a.LoadDate,
			  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(
															RTRIM(LTRIM(COALESCE(a.[Address],''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))
															  ))), 2)),
				RTRIM(LTRIM(COALESCE(a.[Address],''))) ,
				    RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),''))) ,
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(a.[Address],''))), ':',
                        RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))
					))
				),2)),
				a.RecordSource


--RECORD END DATE CLEANUP
		UPDATE dbo.S_Location set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_Location z
			 Where
			  z.H_Location_RK = a.H_Location_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_Location a
			Where a.RecordEndDate Is Null 
			
--**** INSERT S_CONTACT
INSERT INTO [dbo].[S_Contact] ([S_Contact_RK],[LoadDate],[H_Contact_RK],[ContactNumber],[FaxNumber],[EmailAddress],[HashDiff],[RecordSource])
		Select 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.Email_Address,'')))
		))),2)),
		a.LoadDate,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.Email_Address,'')))
		))
		),2)),
		RTRIM(LTRIM(COALESCE(a.ContactNumber,''))) AS ContactNumber,
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))) AS FaxNumber,
				RTRIM(LTRIM(COALESCE(a.Email_Address,''))) AS Email_Address,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.Email_Address,'')))
		))
		),2)),
		a.RecordSource
	 FROM 
		[CHSStaging].[adv].[tblProviderOfficeStage] a with(nolock)
	
		where 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.Email_Address,'')))
		))
		),2))
		not in (Select HashDiff from S_Contact where RecordEndDate is null)
		AND a.cci = @CCI
	GROUP BY
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.Email_Address,'')))
		))
		),2)),
		a.LoadDate,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
	RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.Email_Address,'')))
		))
		),2)),
		RTRIM(LTRIM(COALESCE(a.ContactNumber,''))) ,
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),
				RTRIM(LTRIM(COALESCE(a.Email_Address,''))) ,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.Email_Address,'')))
		))
		),2)),
		a.RecordSource


		
--RECORD END DATE CLEANUP
		UPDATE dbo.S_Contact set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_Contact z
			 Where
			  z.H_Contact_RK = a.H_Contact_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_Contact a
			Where a.RecordEndDate Is Null 


--** Load S_ProviderOfficeSchedule

INSERT INTO [dbo].[S_ProviderOfficeSchedule]
           ([S_ProviderOfficeSchedule_RK]
           ,[LoadDate]
           ,[H_ProviderOfficeSchedule_RK]
           ,[Sch_Start]
           ,[Sch_End]
           ,[Sch_User_PK]
           ,[LastUpdated_Date]
           ,[followup]
           ,[AddInfo]
           ,[sch_type]
           ,[HashDiff]
           ,[RecordSource]
    )
    
	SELECT
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_Start],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_End],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_User_PK],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[followup],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[AddInfo],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[sch_type],'')))
		))
			),2)),
	 LoadDate, 
	 ProviderOfficeScheduleHashKey,
	        [Sch_Start]
           ,[Sch_End]
           ,[Sch_User_PK]
           ,[LastUpdated_Date]
           ,[followup]
           ,[AddInfo]
           ,[sch_type],
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.[Sch_Start],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_End],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_User_PK],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[followup],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[AddInfo],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[sch_type],'')))
		))
			),2)),
	RecordSource
	FROM CHSStaging.adv.tblProviderOfficeScheduleStage rw with(nolock)
	WHERE
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.[Sch_Start],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_End],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_User_PK],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[followup],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[AddInfo],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[sch_type],'')))
		))
			),2))
	not in (SELECT HashDiff FROM S_ProviderOfficeSchedule WHERE 
					H_ProviderOfficeSchedule_RK = rw.ProviderOfficeScheduleHashKey and RecordEndDate is null )
					AND rw.cci = @CCI
	GROUP BY upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_Start],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_End],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_User_PK],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[followup],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[AddInfo],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[sch_type],'')))
		))
			),2)),
	 LoadDate, 
	 ProviderOfficeScheduleHashKey,
	        [Sch_Start]
           ,[Sch_End]
           ,[Sch_User_PK]
           ,[LastUpdated_Date]
           ,[followup]
           ,[AddInfo]
           ,[sch_type],
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.[Sch_Start],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_End],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Sch_User_PK],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[followup],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[AddInfo],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[sch_type],'')))
		))
			),2)),
	RecordSource



	--** Load dbo.S_ProviderOfficeSchedule 

			UPDATE dbo.S_ProviderOfficeSchedule set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_ProviderOfficeSchedule z
			 Where
			  z.H_ProviderOfficeSchedule_RK = a.H_ProviderOfficeSchedule_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_ProviderOfficeSchedule a
			Where a.RecordEndDate Is Null

END



GO
