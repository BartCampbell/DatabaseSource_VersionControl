SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/4/2015
-- Description:	Add and update provider information to obtain correct Provider ID
-- =============================================
CREATE PROCEDURE [dbo].[prMergeProviders]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	;WITH mysource as (
    Select ProviderTypeDescription, ProviderTypeCode, ProviderLastName, ProviderFirstName, PrimarySpecialty, SpecialtyTypeCode, NPI
	from CHSStaging..Provider_Stage_Raw where NPI <> 'NULL'
	group by NPI, ProviderTypeDescription, ProviderTypeCode, ProviderLastName, ProviderFirstName, PrimarySpecialty, SpecialtyTypeCode
	
)
MERGE CHSStaging..Provider_Stage AS t
USING mySource s
     ON s.NPI = t.NPI
WHEN NOT MATCHED THEN INSERT
    (
       ProviderTypeDescription, ProviderTypeCode, ProviderLastName, ProviderFirstName, PrimarySpecialty, SpecialtyTypeCode, NPI
    )
    VALUES (
        rtrim(ltrim(s.ProviderTypeDescription)), 
        rtrim(ltrim(s.ProviderTypeCode)),
		rtrim(ltrim(s.ProviderLastName)), 
        rtrim(ltrim(s.ProviderFirstName)),
		rtrim(ltrim(s.PrimarySpecialty)), 
        rtrim(ltrim(s.SpecialtyTypeCode)),
		rtrim(ltrim(s.NPI))
      )
	  
WHEN MATCHED 
    THEN UPDATE SET t.ProviderTypeDescription = s.ProviderTypeDescription
	,t.ProviderTypeCode=s.ProviderTypeCode
	,t.ProviderLastName=s.ProviderLastName
	,t.ProviderFirstName=s.ProviderFirstName
	,t.PrimarySpecialty=s.PrimarySpecialty
	,t.SpecialtyTypeCode=s.SpecialtyTypeCode
	,t.IsActive = 1

WHEN NOT MATCHED BY SOURCE 
 then update set t.IsActive = 0
	;

END
GO
