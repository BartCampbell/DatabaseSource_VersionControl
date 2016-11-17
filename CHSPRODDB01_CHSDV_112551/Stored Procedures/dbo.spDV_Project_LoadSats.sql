SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/22/2016
-- Description:	Data Vault Project Load Satelites
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Project_LoadSats]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--**S_ProjectDEMO LOAD
INSERT INTO [dbo].[S_ProjectDetails] ([S_ProjectDetails_RK],[LoadDate],[H_Project_RK],[Project_Name],[IsScan],[IsCode],[Client_PK],[dtInsert],[IsProspective],[IsRetrospective],[IsHEDIS],[ProjectGroup],[ProjectGroup_PK],[HashDiff],[RecordSource])

    SELECT
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Project_Name,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsScan AS VARCHAR),''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsCode AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.Client_PK AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.dtInsert AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsProspective AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsRetrospective AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsHEDIS AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProjectGroup, ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.ProjectGroup AS VARCHAR), '')))
						))
			),2)),
	 LoadDate, 
	 ProjectHashKey,
	 RTRIM(LTRIM(COALESCE(rw.Project_Name,''))) AS ProjectName,
			rw.IsScan,
			rw.IsCode,
			rw.Client_PK,
			rw.dtInsert,
			rw.IsProspective,
			rw.IsRetrospective,
			rw.IsHEDIS,
			RTRIM(LTRIM(COALESCE(rw.ProjectGroup, ''))) AS ProjectGroup,
			rw.ProjectGroup_PK,

	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
		RTRIM(LTRIM(COALESCE(rw.Project_Name,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsScan AS VARCHAR),''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsCode AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.Client_PK AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.dtInsert AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsProspective AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsRetrospective AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsHEDIS AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProjectGroup, ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.ProjectGroup AS VARCHAR), '')))
			))
			),2)),
	RecordSource
	FROM CHSStaging.adv.tblProjectStage rw with(nolock)
	WHERE
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.Project_Name,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsScan AS VARCHAR),''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsCode AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.Client_PK AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.dtInsert AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsProspective AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsRetrospective AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsHEDIS AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProjectGroup, ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.ProjectGroup AS VARCHAR), '')))
			))
			),2))
	not in (SELECT HashDiff FROM S_ProjectDetails WHERE 
					H_Project_RK = rw.ProjectHashKey and RecordEndDate is null )
					AND rw.cci = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Project_Name,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsScan AS VARCHAR),''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsCode AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.Client_PK AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.dtInsert AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsProspective AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsRetrospective AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsHEDIS AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProjectGroup, ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.ProjectGroup AS VARCHAR), '')))
			))
			),2)),
			LoadDate,
	  ProjectHashKey,
 RTRIM(LTRIM(COALESCE(rw.Project_Name,''))) ,
			rw.IsScan,
			rw.IsCode,
			rw.Client_PK,
			rw.dtInsert,
			rw.IsProspective,
			rw.IsRetrospective,
			rw.IsHEDIS,
			RTRIM(LTRIM(COALESCE(rw.ProjectGroup, ''))) ,
			rw.ProjectGroup_PK,
		 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
		RTRIM(LTRIM(COALESCE(rw.Project_Name,''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsScan AS VARCHAR),''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsCode AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.Client_PK AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.dtInsert AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsProspective AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsRetrospective AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.IsHEDIS AS VARCHAR), ''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProjectGroup, ''))),':',
			RTRIM(LTRIM(COALESCE(CAST(rw.ProjectGroup AS VARCHAR), '')))
			))
			),2)),
	RecordSource

	--RECORD END DATE CLEANUP
		UPDATE dbo.S_ProjectDetails set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_ProjectDetails z
			 Where
			  z.H_Project_RK = a.H_Project_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_ProjectDetails a
			Where a.RecordEndDate Is Null 



END



GO
