SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/22/2016
 --Update 09/27/2016 Adding LoadDate to Primary Key PJ
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
	UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
		UPPER(CONCAT(
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
			RTRIM(LTRIM(COALESCE(CAST(rw.ProjectGroup AS VARCHAR), ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LoadDate],
                                                              '')))
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

	 UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
		UPPER(CONCAT(
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
	FROM CHSStaging.adv.tblProjectStage rw WITH(NOLOCK)
	WHERE
	 UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
		UPPER(CONCAT(
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
	NOT IN (SELECT HashDiff FROM S_ProjectDetails WHERE 
					H_Project_RK = rw.ProjectHashKey AND RecordEndDate IS NULL )
					AND rw.cci = @CCI
	GROUP BY 
	UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
		UPPER(CONCAT(
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
			RTRIM(LTRIM(COALESCE(CAST(rw.ProjectGroup AS VARCHAR), ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LoadDate],
                                                              '')))
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
		 UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
		UPPER(CONCAT(
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
		UPDATE dbo.S_ProjectDetails SET
			RecordEndDate = (
			 SELECT 
			  DATEADD(ss,-1,MIN(z.LoadDate))
			 FROM
			 dbo.S_ProjectDetails z
			 WHERE
			  z.H_Project_RK = a.H_Project_RK
			  AND z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_ProjectDetails a
			WHERE a.RecordEndDate IS NULL 



END




GO
