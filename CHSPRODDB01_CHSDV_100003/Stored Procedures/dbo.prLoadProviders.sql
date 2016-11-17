SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 6/24/2015
-- Description:	Loads Providers in Data Vault from Staging -- exec dbo.prLoadProviders
-- ============================================= 
CREATE PROCEDURE [dbo].[prLoadProviders]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	

--delete from L_CHSClientProvider
--delete from s_ProviderLocation
--delete from s_Provider
--delete from s_ProviderType
--delete from s_ProviderSpecialty
--delete from H_Provider
;WITH mysource as (
    Select NPI, RecordSource from CHSStaging..Provider_Stage
	group by NPI, RecordSource
)
MERGE CHSDW..H_Provider AS mytarget
USING mySource
     ON mysource.NPI = myTarget.NPI and mysource.RecordSource = myTarget.RecordSource
WHEN NOT MATCHED THEN INSERT
    (
        NPI, 
        RecordSource
    )
    VALUES (
        rtrim(ltrim(mysource.NPI)), 
        rtrim(ltrim(mysource.RecordSource))
    );


	


--*********   LOAD S_PROVIDER  ***********************

;WITH mysource as (
	select hub.ProviderID, stg.ProviderLastName, stg.ProviderFirstName,stg.RecordSource from CHSStaging..Provider_Stage stg
	inner join CHSDW..H_Provider hub on hub.NPI = stg.NPI
	group by hub.ProviderID, stg.ProviderLastName, stg.ProviderFirstName,stg.RecordSource
	
	)
MERGE CHSDW..S_Provider AS mytarget
USING mySource
     ON mysource.ProviderID = myTarget.ProviderID and mysource.RecordSource = myTarget.RecordSource
WHEN NOT MATCHED THEN INSERT
    (
        ProviderID,
		LastName,
		FirstName,
        RecordSource
    )
    VALUES (
		rtrim(ltrim(mysource.ProviderID)),
        rtrim(ltrim(mysource.ProviderLastName)), 
		rtrim(ltrim(mysource.ProviderFirstName)),
       rtrim(ltrim(mysource.RecordSource))
    );




--*********   LOAD S_PROVIDERLOCATION  ***********************

;WITH mysource as (
	select hub.ProviderID, stg.Address1, stg.Address2, stg.City, stg.County, stg.state, stg.zipcode, stg.NetworkID, stg.NetworkName,stg.Fax, stg.Phone, stg.RecordSource  from CHSStaging..Provider_Stage stg
	inner join CHSDW..H_Provider hub on hub.NPI = stg.NPI
	group by hub.ProviderID, stg.Address1, stg.Address2, stg.City, stg.County, stg.state, stg.zipcode, stg.NetworkID, stg.NetworkName,stg.Fax, stg.Phone, stg.RecordSource
	
	)
MERGE CHSDW..S_ProviderLocation AS mytarget
USING mySource
     ON mysource.ProviderID = myTarget.ProviderID and mysource.RecordSource = myTarget.RecordSource
WHEN NOT MATCHED THEN INSERT
    (
        ProviderID,
		Address1,
		Address2, 
		City, 
		County, 
		State, 
		ZipCode,
		NetworkID,
		NetworkName,
        RecordSource,
		fax, 
		phone
    )
    VALUES (
	 rtrim(ltrim(mysource.ProviderID)),
        rtrim(ltrim(mysource.Address1)),
	   rtrim(ltrim( mysource.Address2)),
	   rtrim(ltrim( mysource.City)), 
	   rtrim(ltrim( mysource.County)), 
	   rtrim(ltrim( mysource.State)), 
	    rtrim(ltrim(mysource.Zipcode)),
	   rtrim(ltrim( mysource.NetworkID)),
	    rtrim(ltrim(mysource.NetworkName)),
       rtrim(ltrim( mysource.RecordSource)),
	   rtrim(ltrim( mysource.fax)),
	    rtrim(ltrim(mysource.phone))
    );





	--*********   LOAD S_PROVIDERTYPE  ***********************

;WITH mysource as (
	select hub.ProviderID, stg.RecordSource, stg.ProviderTypeCode, stg.ProviderTypeDescription  from CHSStaging..Provider_Stage stg
	inner join CHSDW..H_Provider hub on hub.NPI = stg.NPI
	group by hub.ProviderID, stg.RecordSource, stg.ProviderTypeCode, stg.ProviderTypeDescription
	
	)
MERGE CHSDW..S_ProviderType AS mytarget
USING mySource
     ON mysource.ProviderID = myTarget.ProviderID and mysource.RecordSource = myTarget.RecordSource
WHEN NOT MATCHED THEN INSERT
    (
        ProviderID,
		ProviderTypeCode, 
		ProviderTypeDesc,
        RecordSource
    )
    VALUES (
       rtrim(ltrim(mysource.ProviderID)),
       rtrim(ltrim(mysource.ProviderTypeCode)), 
	   rtrim(ltrim(mysource.ProviderTypeDescription)),
       rtrim(ltrim(mysource.RecordSource))
    );



		--*********   LOAD S_PROVIDERSPECIALTY  ***********************

;WITH mysource as (
	select hub.ProviderID, stg.RecordSource, stg.PrimarySpecialty, stg.SpecialtyTypeCode  from CHSStaging..Provider_Stage stg
	inner join CHSDW..H_Provider hub on hub.NPI = stg.NPI
	group by hub.ProviderID, stg.RecordSource, stg.PrimarySpecialty, stg.SpecialtyTypeCode 
	
	)
MERGE CHSDW..S_ProviderSpecialty AS mytarget
USING mySource
     ON mysource.ProviderID = myTarget.ProviderID and mysource.RecordSource = myTarget.RecordSource
WHEN NOT MATCHED THEN INSERT
    (
        ProviderID,
		SpecialtyDesc, 
		SpecialtyCode,
        RecordSource
    )
    VALUES (
       rtrim(ltrim(mysource.ProviderID)),
       rtrim(ltrim(mysource.PrimarySpecialty)), 
	   rtrim(ltrim(mysource.SpecialtyTypeCode)),
      rtrim(ltrim( mysource.RecordSource))
    );



--*********   LOAD L_CHSClientProvider ***********************

;WITH mysource as (
	select hub.ProviderID, stg.RecordSource, stg.CHSClientID  from CHSStaging..Provider_Stage stg
	inner join CHSDW..H_Provider hub on hub.NPI = stg.NPI
	group by hub.ProviderID, stg.RecordSource, stg.CHSClientID
	
	)
MERGE CHSDW..L_CHSClientProvider AS mytarget
USING mySource
     ON mysource.ProviderID = myTarget.ProviderID and mysource.RecordSource = myTarget.RecordSource
WHEN NOT MATCHED THEN INSERT
    (
        ProviderID,
		CHSClientID, 
		RecordSource
    )
    VALUES (
       rtrim(ltrim(mysource.ProviderID)),
       rtrim(ltrim(mysource.CHSClientID)),
       rtrim(ltrim(mysource.RecordSource))
    );




end
GO
