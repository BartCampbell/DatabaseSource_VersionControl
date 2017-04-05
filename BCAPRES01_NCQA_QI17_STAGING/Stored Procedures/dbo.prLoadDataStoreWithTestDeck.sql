SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[prLoadDataStoreWithTestDeck]
AS
/*
-- EXECUTE prLoadDataStoreWithTestDeck 
*/

 --drop FKs
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actMember_Claim_FK1' )
	ALTER TABLE dbo.Claim DROP CONSTRAINT actMember_Claim_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actProvider_Claim_FK1' )
	ALTER TABLE dbo.Claim DROP CONSTRAINT actProvider_Claim_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actProvider_Claim_FK2' )
	ALTER TABLE dbo.Claim DROP CONSTRAINT actProvider_Claim_FK2
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actProvider_Claim_FK3' )
	ALTER TABLE dbo.Claim DROP CONSTRAINT actProvider_Claim_FK3
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'FK__Claim__HealthPla__147C05D0' )
	ALTER TABLE dbo.Claim DROP CONSTRAINT FK__Claim__HealthPla__147C05D0
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actClaim_ClaimExtension_FK1' )
	ALTER TABLE dbo.ClaimExtension DROP CONSTRAINT actClaim_ClaimExtension_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actClaim_ClaimLineItem_FK1' )
	ALTER TABLE dbo.ClaimLineItem DROP CONSTRAINT actClaim_ClaimLineItem_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'FK_ClaimLineItemExtension_ClaimLineItem' )
	ALTER TABLE dbo.ClaimLineItemExtension DROP CONSTRAINT FK_ClaimLineItemExtension_ClaimLineItem
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actHealthPlan_Eligibility_FK1' )
	ALTER TABLE dbo.Eligibility DROP CONSTRAINT actHealthPlan_Eligibility_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actMember_Eligibility_FK1' )
	ALTER TABLE dbo.Eligibility DROP CONSTRAINT actMember_Eligibility_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actEligibility_EligibilityExtension_FK1' )
	ALTER TABLE dbo.EligibilityExtension DROP CONSTRAINT actEligibility_EligibilityExtension_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actSubscriber_Member_FK1' )
	ALTER TABLE dbo.Member DROP CONSTRAINT actSubscriber_Member_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actMember_PharmacyClaim_FK1' )
	ALTER TABLE dbo.PharmacyClaim DROP CONSTRAINT actMember_PharmacyClaim_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actPharmacy_PharmacyClaim_FK1' )
	ALTER TABLE dbo.PharmacyClaim DROP CONSTRAINT actPharmacy_PharmacyClaim_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actProvider_PharmacyClaim_FK1' )
	ALTER TABLE dbo.PharmacyClaim DROP CONSTRAINT actProvider_PharmacyClaim_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'FK__PharmacyC__Healt__15702A09' )
	ALTER TABLE dbo.PharmacyClaim DROP CONSTRAINT FK__PharmacyC__Healt__15702A09
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actPharmacyClaim_PharmacyClaimExtension_FK1' )
	ALTER TABLE dbo.PharmacyClaimExtension DROP CONSTRAINT actPharmacyClaim_PharmacyClaimExtension_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actNetwork_Provider_FK1' )
	ALTER TABLE dbo.Provider DROP CONSTRAINT actNetwork_Provider_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actEmployee_Subscriber_FK1' )
	ALTER TABLE dbo.Subscriber DROP CONSTRAINT actEmployee_Subscriber_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actMember_MemberExtension_FK1' )
	ALTER TABLE dbo.MemberExtension DROP CONSTRAINT actMember_MemberExtension_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actSubscriber_SubscriberExtension_FK1' )
	ALTER TABLE dbo.SubscriberExtension DROP CONSTRAINT actSubscriber_SubscriberExtension_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actEmployee_EmployeeExtension_FK1' )
	ALTER TABLE dbo.EmployeeExtension DROP CONSTRAINT actEmployee_EmployeeExtension_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actProvider_ProviderExtension_FK1' )
	ALTER TABLE dbo.ProviderExtension DROP CONSTRAINT actProvider_ProviderExtension_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actPharmacy_PharmacyExtension_FK1' )
	ALTER TABLE dbo.PharmacyExtension DROP CONSTRAINT actPharmacy_PharmacyExtension_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actMember_MemberProvider_FK1' )
	ALTER TABLE dbo.MemberProvider DROP CONSTRAINT actMember_MemberProvider_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actProvider_MemberProvider_FK1' )
	ALTER TABLE dbo.MemberProvider DROP CONSTRAINT actProvider_MemberProvider_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actProvider_ProviderAddress_FK1' )
	ALTER TABLE dbo.ProviderAddress DROP CONSTRAINT actProvider_ProviderAddress_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actProvider_ProviderMedicalGroup_FK1' )
	ALTER TABLE dbo.ProviderMedicalGroup DROP CONSTRAINT actProvider_ProviderMedicalGroup_FK1
IF EXISTS( SELECT * FROM sysobjects WHERE name = 'actProvider_ProviderSpecialty_FK1' )
	ALTER TABLE dbo.ProviderSpecialty DROP CONSTRAINT actProvider_ProviderSpecialty_FK1

DELETE FROM  dbo.ClaimLineItem;
DELETE FROM  dbo.Claim;
DELETE FROM  dbo.PharmacyClaim;
DELETE FROM  dbo.Eligibility;
DELETE FROM  dbo.Member;
DELETE FROM  dbo.Subscriber;
DELETE FROM  dbo.Employee;
DELETE FROM  dbo.ProviderAddress;
DELETE FROM  dbo.Provider;
DELETE FROM  dbo.Pharmacy;
DELETE FROM  dbo.LabResult;
DELETE FROM	 dbo.HealthPlan;



-- rebuild FKs
/****** Object:  ForeignKey [actMember_Claim_FK1]    Script Date: 06/15/2007 09:43:37 ******/
ALTER TABLE [dbo].[Claim]  WITH CHECK ADD  CONSTRAINT [actMember_Claim_FK1] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Member] ([MemberID])

ALTER TABLE [dbo].[Claim] CHECK CONSTRAINT [actMember_Claim_FK1]

/****** Object:  ForeignKey [actProvider_Claim_FK1]    Script Date: 06/15/2007 09:43:37 ******/
ALTER TABLE [dbo].[Claim]  WITH CHECK ADD  CONSTRAINT [actProvider_Claim_FK1] FOREIGN KEY([ReferringProviderID])
REFERENCES [dbo].[Provider] ([ProviderID])

ALTER TABLE [dbo].[Claim] CHECK CONSTRAINT [actProvider_Claim_FK1]

/****** Object:  ForeignKey [actProvider_Claim_FK2]    Script Date: 06/15/2007 09:43:38 ******/
ALTER TABLE [dbo].[Claim]  WITH CHECK ADD  CONSTRAINT [actProvider_Claim_FK2] FOREIGN KEY([ServicingProviderID])
REFERENCES [dbo].[Provider] ([ProviderID])

ALTER TABLE [dbo].[Claim] CHECK CONSTRAINT [actProvider_Claim_FK2]

/****** Object:  ForeignKey [actProvider_Claim_FK2]    Script Date: 06/15/2007 09:43:38 ******/
ALTER TABLE [dbo].[ClaimExtension]  WITH CHECK ADD  CONSTRAINT [actClaim_ClaimExtension_FK1] FOREIGN KEY([ClaimID])
REFERENCES [dbo].[Claim] ([ClaimID])

ALTER TABLE dbo.ClaimExtension CHECK CONSTRAINT actClaim_ClaimExtension_FK1

/****** Object:  ForeignKey [actProvider_Claim_FK3]    Script Date: 06/15/2007 09:43:38 ******/
ALTER TABLE [dbo].[Claim]  WITH CHECK ADD  CONSTRAINT [actProvider_Claim_FK3] FOREIGN KEY([BillingProviderID])
REFERENCES [dbo].[Provider] ([ProviderID])

ALTER TABLE [dbo].[Claim] CHECK CONSTRAINT [actProvider_Claim_FK3]

/****** Object:  ForeignKey [FK__Claim__HealthPla__147C05D0]    Script Date: 06/15/2007 09:43:38 ******/
ALTER TABLE [dbo].[Claim]  WITH CHECK ADD  CONSTRAINT [FK__Claim__HealthPla__147C05D0] FOREIGN KEY([HealthPlanID])
REFERENCES [dbo].[HealthPlan] ([HealthPlanID])

ALTER TABLE [dbo].[Claim] CHECK CONSTRAINT [FK__Claim__HealthPla__147C05D0]

/****** Object:  ForeignKey [actClaim_ClaimLineItem_FK1]    Script Date: 06/15/2007 09:43:54 ******/
ALTER TABLE [dbo].[ClaimLineItem]  WITH CHECK ADD  CONSTRAINT [actClaim_ClaimLineItem_FK1] FOREIGN KEY([ClaimID])
REFERENCES [dbo].[Claim] ([ClaimID])

ALTER TABLE [dbo].[ClaimLineItem] CHECK CONSTRAINT [actClaim_ClaimLineItem_FK1]

/****** Object:  ForeignKey [FK_ClaimLineItemExtension_ClaimLineItem]    Script Date: 06/15/2007 09:43:54 ******/
ALTER TABLE [dbo].[ClaimLineItemExtension]  WITH CHECK ADD  CONSTRAINT [FK_ClaimLineItemExtension_ClaimLineItem] FOREIGN KEY(ClaimLineItemID)
REFERENCES [dbo].[ClaimLineItem] (ClaimLineItemID)

ALTER TABLE dbo.ClaimLineItemExtension CHECK CONSTRAINT FK_ClaimLineItemExtension_ClaimLineItem

/****** Object:  ForeignKey [actHealthPlan_Eligibility_FK1]    Script Date: 06/15/2007 09:43:58 ******/
ALTER TABLE [dbo].[Eligibility]  WITH CHECK ADD  CONSTRAINT [actHealthPlan_Eligibility_FK1] FOREIGN KEY([HealthPlanID])
REFERENCES [dbo].[HealthPlan] ([HealthPlanID])

ALTER TABLE [dbo].[Eligibility] CHECK CONSTRAINT [actHealthPlan_Eligibility_FK1]

/****** Object:  ForeignKey [actMember_Eligibility_FK1]    Script Date: 06/15/2007 09:43:59 ******/
ALTER TABLE [dbo].[Eligibility]  WITH CHECK ADD  CONSTRAINT [actMember_Eligibility_FK1] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Member] ([MemberID])

ALTER TABLE [dbo].[Eligibility] CHECK CONSTRAINT [actMember_Eligibility_FK1]

/****** Object:  ForeignKey [actSubscriber_Member_FK1]    Script Date: 06/15/2007 09:44:32 ******/
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [actSubscriber_Member_FK1] FOREIGN KEY([SubscriberID])
REFERENCES [dbo].[Subscriber] ([SubscriberID])

ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [actSubscriber_Member_FK1]

/****** Object:  ForeignKey [actMember_PharmacyClaim_FK1]    Script Date: 06/15/2007 09:44:56 ******/
ALTER TABLE [dbo].[PharmacyClaim]  WITH CHECK ADD  CONSTRAINT [actMember_PharmacyClaim_FK1] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Member] ([MemberID])

ALTER TABLE [dbo].[PharmacyClaim] CHECK CONSTRAINT [actMember_PharmacyClaim_FK1]

/****** Object:  ForeignKey [actPharmacy_PharmacyClaim_FK1]    Script Date: 06/15/2007 09:44:56 ******/
ALTER TABLE [dbo].[PharmacyClaim]  WITH CHECK ADD  CONSTRAINT [actPharmacy_PharmacyClaim_FK1] FOREIGN KEY([PharmacyID])
REFERENCES [dbo].[Pharmacy] ([PharmacyID])

ALTER TABLE [dbo].[PharmacyClaim] CHECK CONSTRAINT [actPharmacy_PharmacyClaim_FK1]

/****** Object:  ForeignKey [actProvider_PharmacyClaim_FK1]    Script Date: 06/15/2007 09:44:57 ******/
ALTER TABLE [dbo].[PharmacyClaim]  WITH CHECK ADD  CONSTRAINT [actProvider_PharmacyClaim_FK1] FOREIGN KEY([PrescribingProviderID])
REFERENCES [dbo].[Provider] ([ProviderID])

ALTER TABLE [dbo].[PharmacyClaim] CHECK CONSTRAINT [actProvider_PharmacyClaim_FK1]

/****** Object:  ForeignKey [FK__PharmacyC__Healt__15702A09]    Script Date: 06/15/2007 09:44:57 ******/
ALTER TABLE [dbo].[PharmacyClaim]  WITH CHECK ADD  CONSTRAINT [FK__PharmacyC__Healt__15702A09] FOREIGN KEY([HealthPlanID])
REFERENCES [dbo].[HealthPlan] ([HealthPlanID])

ALTER TABLE [dbo].[PharmacyClaim] CHECK CONSTRAINT [FK__PharmacyC__Healt__15702A09]

/****** Object:  ForeignKey [actPharmacyClaim_PharmacyClaimExtension_FK1]    Script Date: 06/15/2007 09:44:57 ******/
ALTER TABLE [dbo].[PharmacyClaimExtension]  WITH CHECK ADD  CONSTRAINT [actPharmacyClaim_PharmacyClaimExtension_FK1] FOREIGN KEY([PharmacyClaimID])
REFERENCES [dbo].[PharmacyClaim] ([PharmacyClaimID])

ALTER TABLE dbo.PharmacyClaimExtension CHECK CONSTRAINT actPharmacyClaim_PharmacyClaimExtension_FK1

/****** Object:  ForeignKey [actNetwork_Provider_FK1]    Script Date: 06/15/2007 09:45:11 ******/
ALTER TABLE [dbo].[Provider]  WITH CHECK ADD  CONSTRAINT [actNetwork_Provider_FK1] FOREIGN KEY([NetworkID])
REFERENCES [dbo].[Network] ([NetworkID])

ALTER TABLE [dbo].[Provider] CHECK CONSTRAINT [actNetwork_Provider_FK1]

/****** Object:  ForeignKey [actEmployee_Subscriber_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[Subscriber]  WITH CHECK ADD  CONSTRAINT [actEmployee_Subscriber_FK1] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employee] ([EmployeeID])

ALTER TABLE [dbo].[Subscriber] CHECK CONSTRAINT [actEmployee_Subscriber_FK1]

/****** Object:  ForeignKey [actEligibility_EligibilityExtension_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[EligibilityExtension]  WITH CHECK ADD  CONSTRAINT [actEligibility_EligibilityExtension_FK1] FOREIGN KEY([EligibilityID])
REFERENCES [dbo].[Eligibility] ([EligibilityID])

ALTER TABLE dbo.EligibilityExtension CHECK CONSTRAINT actEligibility_EligibilityExtension_FK1

/****** Object:  ForeignKey [actMember_MemberExtension_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[MemberExtension]  WITH CHECK ADD  CONSTRAINT [actMember_MemberExtension_FK1] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Member] ([MemberID])

ALTER TABLE dbo.MemberExtension CHECK CONSTRAINT actMember_MemberExtension_FK1
	
/****** Object:  ForeignKey [actSubscriber_SubscriberExtension_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[SubscriberExtension]  WITH CHECK ADD  CONSTRAINT [actSubscriber_SubscriberExtension_FK1] FOREIGN KEY([SubscriberID])
REFERENCES [dbo].[Subscriber] ([SubscriberID])
	
ALTER TABLE dbo.SubscriberExtension CHECK CONSTRAINT actSubscriber_SubscriberExtension_FK1

/****** Object:  ForeignKey [actEmployee_EmployeeExtension_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[EmployeeExtension]  WITH CHECK ADD  CONSTRAINT [actEmployee_EmployeeExtension_FK1] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employee] ([EmployeeID])
	
ALTER TABLE dbo.EmployeeExtension CHECK CONSTRAINT actEmployee_EmployeeExtension_FK1

/****** Object:  ForeignKey [actProvider_ProviderExtension_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[ProviderExtension]  WITH CHECK ADD  CONSTRAINT [actProvider_ProviderExtension_FK1] FOREIGN KEY([ProviderID])
REFERENCES [dbo].[Provider] ([ProviderID])
	
ALTER TABLE dbo.ProviderExtension CHECK CONSTRAINT actProvider_ProviderExtension_FK1

/****** Object:  ForeignKey [actPharmacy_PharmacyExtension_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[PharmacyExtension]  WITH CHECK ADD  CONSTRAINT [actPharmacy_PharmacyExtension_FK1] FOREIGN KEY([PharmacyID])
REFERENCES [dbo].[Pharmacy] ([PharmacyID])
	
ALTER TABLE dbo.PharmacyExtension CHECK CONSTRAINT actPharmacy_PharmacyExtension_FK1

/****** Object:  ForeignKey [actMember_MemberProvider_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[MemberProvider]  WITH CHECK ADD  CONSTRAINT [actMember_MemberProvider_FK1] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Member] ([MemberID])
	
ALTER TABLE dbo.MemberProvider CHECK CONSTRAINT actMember_MemberProvider_FK1

/****** Object:  ForeignKey [actProvider_MemberProvider_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[MemberProvider]  WITH CHECK ADD  CONSTRAINT [actProvider_MemberProvider_FK1] FOREIGN KEY([ProviderID])
REFERENCES [dbo].[Provider] ([ProviderID])
	
ALTER TABLE dbo.MemberProvider CHECK CONSTRAINT actProvider_MemberProvider_FK1

/****** Object:  ForeignKey [actProvider_ProviderAddress_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[ProviderAddress]  WITH CHECK ADD  CONSTRAINT [actProvider_ProviderAddress_FK1] FOREIGN KEY([ProviderID])
REFERENCES [dbo].[Provider] ([ProviderID])
	
ALTER TABLE dbo.ProviderAddress CHECK CONSTRAINT actProvider_ProviderAddress_FK1

/****** Object:  ForeignKey [actProvider_ProviderMedicalGroup_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[ProviderMedicalGroup]  WITH CHECK ADD  CONSTRAINT [actProvider_ProviderMedicalGroup_FK1] FOREIGN KEY([ProviderID])
REFERENCES [dbo].[Provider] ([ProviderID])
	
ALTER TABLE dbo.ProviderMedicalGroup CHECK CONSTRAINT actProvider_ProviderMedicalGroup_FK1

/****** Object:  ForeignKey [actProvider_ProviderSpecialty_FK1]    Script Date: 06/15/2007 09:45:19 ******/
ALTER TABLE [dbo].[ProviderSpecialty]  WITH CHECK ADD  CONSTRAINT [actProvider_ProviderSpecialty_FK1] FOREIGN KEY([ProviderID])
REFERENCES [dbo].[Provider] ([ProviderID])
	
ALTER TABLE dbo.ProviderSpecialty CHECK CONSTRAINT actProvider_ProviderSpecialty_FK1





-- HealthPlan
INSERT INTO dbo.HealthPlan( Client, HealthPlanName ) SELECT 'NCQA', 'NCQA'

DECLARE	@iHealthPlan	int,
	@iProvider	int,
	@iPharmacy	int

SELECT @iHealthPlan = HealthPlanID FROM dbo.HealthPlan WHERE HealthPlanName = 'NCQA'







EXEC alter_index 'pharmacy','D'

-- Pharmacy (Test Deck data doesn't provide this, but we need a placeholder.)
INSERT INTO dbo.Pharmacy
(		Address1, 
		Address2, 
		City, 
		Client, 
		DataSource, 
		DEANumber, 
		Fax, 
		NABPNumber,
		NPI, 
		PharmacyName, 
		Phone, 
		State, 
		ZipCode )
SELECT	distinct
		Address1		= NULL, 
		Address2		= NULL, 
		City			= NULL, 
		Client			= 'NCQA', 
		DataSource		= 'NCQA_QI17_RDSM.dbo.pharm', 
		DEANumber		= NULL, 
		Fax				= NULL, 
		NABPNumber		= NULL, 
		NPI				= NULL, 
		PharmacyName	= 'Unknown', 
		Phone			= NULL, 
		State			= NULL, 
		ZipCode			= NULL 
FROM	NCQA_QI17_RDSM..pharm

EXEC alter_index 'pharmacy','C'


-- build placeholder pharmacy
INSERT INTO dbo.Pharmacy
(		Client, 
		DataSource, 
		NPI, 
		PharmacyName )
SELECT	Client		= 'NCQA', 
	DataSource		= 'NCQA_QI17_RDSM.dbo.pharm', 
	NPI				= 0,
	PharmacyName	= ''



SELECT @iPharmacy = PharmacyID FROM dbo.Pharmacy where NPI = 0







--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: Provider
NAME		FIELD								VALUE	DESCRIPTION
ProvID		Provider ID									Unique Provider ID
PCP			PCP Flag							Y		Indicates if provider is a PCP or not (blank if not necessary for the measure)
												N	
OBGYN		OBGYN Flag							Y		Indicates if provider is a OBGYN or not (blank if not necessary for the measure)
												N	
MHProv		MH Provider Flag					Y		Indicates if provider is a MH provider or not (blank if not necessary for the measure)
												N	
EyeCProv	EyeCare Provider Flag				Y		Indicates if provider is an eye care provider or not (blank if not necessary for the measure)
												N	
Dentist		Dentist Flag						Y		Indicates if provider is a dentist or not (blank if not necessary for the measure)
												N	
Neph		Nephrologist Flag					Y		Indicates if provider is a nephrologist or not (blank if not necessary for the measure)
												N	
CDProv		CD Provider Flag					Y		Indicates if provider is a CD provider or not (blank if not necessary for the measure)
												N	
NPR			NPR Provider Flag					Y		Indicates if provider is a nurse practitioner or not (blank if not necessary for the measure)
												N	
PAS			PAS Provider Flag					Y		Indicates if provider is a Physician Assistant or not (blank if not necessary for the measure)
												N	
ProvPres	Provider Prescribing Privileges		Y		Indicates if provider has prescribing privileges  or not (blank if not necessary for the measure)
												N	
Inp			Inpatient Provider Flag **			Y		Indicates if provider is paid at an inpatient rate or not (blank if not necessary for the measure)
												N	
Out			Outpatient Provider Flag **			Y		Indicates if provider is paid at an outpatient rate or not (blank if not necessary for the measure)
												N	
*/
--**************************************************************************************
--**************************************************************************************

EXEC alter_index 'provider','D'

INSERT INTO dbo.Provider( 
		BoardCertification1, 
		BoardCertification2, 
		Client, 
		DataSource, 
		DateOfBirth,
		DEANumber, 
		EIN, 
		Gender, 
		HedisMeasureID, 
		ihds_prov_id, 
		LicenseNumber, 
		MedicaidID, 
		NameFirst,
		NameLast, 
		NameMiddleInitial, 
		NamePrefix, 
		NameSuffix, 
		NameTitle, 
		NetworkID, 
		NPI, 
		ProviderType,
		SpecialtyCode1, 
		SpecialtyCode2, 
		SSN, 
		CustomerProviderID,
		TaxID, 
		UPIN,
		ProviderPrescribingPrivFlag,
--		ProviderPaidInpatientRateFlag,
--		ProviderPaidOutpatientRateFlag,
		PCPFlag,
		OBGynFlag,
		MentalHealthFlag,
		EyeCareFlag,
		DentistFlag,
		NephrologistFlag,
		CDProviderFlag,
		NursePractFlag,
		PhysicianAsstFlag, 
		ClinicalPharmacistFlag, 
		AnesthesiologistFlag,
		HospitalFlag,
		SkilledNursingFacFlag,
		SurgeonFlag,
		RegisteredNurseFlag,
		DurableMedEquipmentFlag,
		AmbulanceFlag,
		MedicareID)
SELECT 	BoardCertification1	= NULL, 
		BoardCertification2	= NULL, 
		Client				= 'NCQA', 
		DataSource			= 'NCQA_QI17_RDSM.dbo.provider', 
		DateOfBirth			= NULL, 
		DEANumber			= NULL, 
		EIN					= NULL, 
		Gender				= NULL, 
		HedisMeasureID		= left(measureset, 10), 
		ihds_prov_id		= ihds_provider_id, 
		LicenseNumber		= NULL, 
		MedicaidID			= NULL, 
		NameFirst			= NULL, 
		NameLast			= NULL, 
		NameMiddleInitial	= NULL, 
		NamePrefix			= NULL,  
		NameSuffix			= NULL, 
		NameTitle			= NULL, 
		NetworkID			= NULL, 
		NPI					= NULL, 
		ProviderType		= NULL, 
		SpecialtyCode1		= CASE	WHEN 'pcp' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'PCP' )
									WHEN 'obgyn' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'OB/GYN' )
									WHEN 'mhprov' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Mental Health' )
									WHEN 'eyecprov' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Eye Care' )
									WHEN 'dentist' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Dentist' )
									WHEN 'neph' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Nephrologist' )
									WHEN 'cdprov' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'CD' )
									WHEN 'npr' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'NPR' )
									WHEN 'pas' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'PAS' )
									WHEN 'provpres' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Prescriber' )
									WHEN 'inp' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Inpatient' )
									WHEN 'out' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Outpatient' )
								END, 
		SpecialtyCode2		= NULL, 
		SSN					= NULL, 
		CustomerProviderID	= provid,
		TaxID				= provid, 
		UPIN				= NULL, 
		ProviderPrescribingPrivFlag		= provpres, 
--		ProviderPaidInpatientRateFlag	= inp,
--		ProviderPaidOutpatientRateFlag	= out, 
		PCPFlag				= pcp,
		OBGynFlag			= obgyn,
		MentalHealthFlag	= mhprov, 
		EyeCareFlag			= eyecprov,
		DentistFlag			= dentist,
		NephrologistFlag	= neph, 
		CDProviderFlag		= '', 
		NursePractFlag		= npr, 
		PhysicianAsstFlag	= pas , 
		ClinicalPharmacistFlag	= phaprov , 
		AnesthesiologistFlag	= anes ,
		HospitalFlag		= hosp,
		SkilledNursingFacFlag = snf,
		SurgeonFlag = surg,
		RegisteredNurseFlag = rn,
		DurableMedEquipmentFlag = 'N',
		AmbulanceFlag = 'N',
		NULL AS hospid
FROM	NCQA_QI17_RDSM..provider
UNION
SELECT 	BoardCertification1	= NULL, 
		BoardCertification2	= NULL, 
		Client				= 'NCQA', 
		DataSource			= 'NCQA_QI17_RDSM.dbo.providerHAI', 
		DateOfBirth			= NULL, 
		DEANumber			= NULL, 
		EIN					= NULL, 
		Gender				= NULL, 
		HedisMeasureID		= left(measureset, 10), 
		ihds_prov_id		= ihds_provider_id, 
		LicenseNumber		= NULL, 
		MedicaidID			= NULL, 
		NameFirst			= NULL, 
		NameLast			= NULL, 
		NameMiddleInitial	= NULL, 
		NamePrefix			= NULL,  
		NameSuffix			= NULL, 
		NameTitle			= NULL, 
		NetworkID			= NULL, 
		NPI					= NULL, 
		ProviderType		= NULL, 
		SpecialtyCode1		= CASE	WHEN 'pcp' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'PCP' )
									WHEN 'obgyn' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'OB/GYN' )
									WHEN 'mhprov' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Mental Health' )
									WHEN 'eyecprov' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Eye Care' )
									WHEN 'dentist' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Dentist' )
									WHEN 'neph' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Nephrologist' )
									WHEN 'cdprov' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'CD' )
									WHEN 'npr' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'NPR' )
									WHEN 'pas' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'PAS' )
									WHEN 'provpres' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Prescriber' )
									WHEN 'inp' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Inpatient' )
									WHEN 'out' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Outpatient' )
								END, 
		SpecialtyCode2		= NULL, 
		SSN					= NULL, 
		CustomerProviderID	= provid,
		TaxID				= provid, 
		UPIN				= NULL, 
		ProviderPrescribingPrivFlag		= provpres, 
--		ProviderPaidInpatientRateFlag	= inp,
--		ProviderPaidOutpatientRateFlag	= out, 
		PCPFlag				= pcp,
		OBGynFlag			= obgyn,
		MentalHealthFlag	= mhprov, 
		EyeCareFlag			= eyecprov,
		DentistFlag			= dentist,
		NephrologistFlag	= neph, 
		CDProviderFlag		= '', 
		NursePractFlag		= npr, 
		PhysicianAsstFlag	= pas , 
		ClinicalPharmacistFlag	= phaprov , 
		AnesthesiologistFlag	= anes ,
		HospitalFlag		= hosp,
		SkilledNursingFacFlag = snf,
		SurgeonFlag = surg,
		RegisteredNurseFlag = rn,
		DurableMedEquipmentFlag = 'N',
		AmbulanceFlag = 'N',
		MedicareID = hospid
FROM	NCQA_QI17_RDSM..providerHAI;

EXEC alter_index 'provider','C'

UPDATE	p
SET		p.SpecialtyCode2 =	CASE	-- note that PCP can't be specialty2 because of CASE order above
									WHEN 'obgyn' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'OB/GYN' AND p.SpecialtyCode1 <> SpecialtyID )
									WHEN 'mhprov' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Mental Health' AND p.SpecialtyCode1 <> SpecialtyID )
									WHEN 'eyecprov' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Eye Care' AND p.SpecialtyCode1 <> SpecialtyID )
									WHEN 'dentist' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Dentist' AND p.SpecialtyCode1 <> SpecialtyID )
									WHEN 'neph' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Nephrologist' AND p.SpecialtyCode1 <> SpecialtyID )
									WHEN 'cdprov' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'CD' AND p.SpecialtyCode1 <> SpecialtyID )
									WHEN 'npr' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'NPR' AND p.SpecialtyCode1 <> SpecialtyID )
									WHEN 'pas' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'PAS' AND p.SpecialtyCode1 <> SpecialtyID )
									WHEN 'provpres' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Prescriber' AND p.SpecialtyCode1 <> SpecialtyID )
									WHEN 'inp' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Inpatient' AND p.SpecialtyCode1 <> SpecialtyID )
									WHEN 'out' = 'Y' THEN ( SELECT SpecialtyID FROM dbo.Specialty WHERE Description = 'Outpatient' AND p.SpecialtyCode1 <> SpecialtyID )
								END	
FROM	dbo.Provider p
		JOIN NCQA_QI17_RDSM..provider t ON 
			p.ihds_prov_id = t.ihds_provider_id


-- build placeholder provider
INSERT INTO dbo.Provider
(	Client, 
	DataSource, 
	ihds_prov_id )
SELECT	Client		= 'NCQA', 
	DataSource		= 'NCQA_QI17_RDSM.dbo.provider', 
	ihds_prov_id	= 0

SELECT @iProvider = ProviderID FROM dbo.Provider WHERE ihds_prov_id = 0














--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: General Membership 
NAME		FIELD								VALUE		DESCRIPTION
MemID		Member ID										Unique Member ID
Gender		Gender 								M			Male
												F			Female
DOB			Date of Birth						YYYYMMDD	(may be blank)
Lname		Member Last Name								Only used in sampling decks
Fname		Member First Name								Only used in sampling decks
MMidName	Member Middle Initial							Member Middle Initial
SubID		Subscriber or Family ID Number					This ID differentiates between individuals when 
															family members share the subscriber ID 
Add1		Mailing Address 1								First Line of Mailing Address
Add2		Mailing Address 2									econd Line of Mailing Address
City		City		City
State		State											2-character State - see State Abbreviation tab
MZip		Zip												5-digit Zip Code
Mphone		Telephone Number								10-digit Phone Number, no separators
PFirstName	Parent/Caretaker First Name						Parent/Caretaker First Name
PMidName	Parent/Caretaker Middle Initial					Parent/Caretaker Middle Initial
PLastName	Parent/Caretaker Last Name						Parent/Caretaker Last Name
Race		Race								01			White
												02			Black or African American
												03			American Indian and Alaska Native
												04			Asian
												05			Native Hawaiian and Other Pacific Islander
												06			Some Other Race
												07			Two or More Races
												09			Unknown Race
Ethn		Ethnicity							11			Hispanic or Latino
												12			Not Hispanic or Latino
												19			Unknown Ethnicity
Int			Interpreter							0			No, does not want an interpreter
												1			Yes, wants an interpreter
												9			Unknown need for interpreter
Lang		Language							21			English
												22			Spanish
												23			Other Indo-European Language
												24			Asian and Pacific Island Languages 
												28			Other Languages
												29			Spoken Language Unknown

*/
--**************************************************************************************
--**************************************************************************************


EXEC alter_index 'Employee','D'

-- Employee

INSERT INTO dbo.Employee
(		Address1, 
		Address2, 
		City, 
		Client, 
		Company, 
		CustomerEmployeeID,
		DataSource, 
		DateOfBirth, 
		DateHired, 
		DateTerminated, 
		Department, 
		EmployeeType,
		EthnicGroup, 
		Gender, 
		IsSmoker, 
		JobTitle, 
		Location, 
		MaritalStatus, 
		NameFirst,
		NameLast, 
		NameMiddleInitial, 
		Phone, 
		SSN, 
		State, 
		ZipCode,
		HedisMeasureID )
SELECT	DISTINCT
		Address1				= add1, 
		Address2				= add2, 
		City					= city, 
		Client					= 'NCQA', 
		Company					= NULL, 
		CustomerEmployeeID		= memid,
		DataSource				= 'NCQA_QI17_RDSM.dbo.member_gm', 
		DateOfBirth				= case when dob = '' then null else dob end,
		DateHired				= NULL, 
		DateTerminated			= NULL, 
		Department				= NULL, 
		EmployeeType			= NULL,
		EthnicGroup				= ethn,
		Gender					= gender, 
		IsSmoker				= NULL, 
		JobTitle				= NULL, 
		Location				= NULL, 
		MaritalStatus			= NULL, 
		NameFirst				= fname,
		NameLast				= lname,
		NameMiddleInitial		= mmidname, 
		Phone					= mphone, 
		SSN						= NULL,
		State					= state,
		ZipCode					= mzip,
		HedisMeasureID			= left(measureset, 10)
FROM	NCQA_QI17_RDSM..member_gm

EXEC alter_index 'Employee','C'

EXEC alter_index 'Subscriber','D'

-- Subscriber
INSERT INTO dbo.Subscriber
(		Address1, 
		Address2, 
		City, 
		Client, 
		CoverageType, 
		CustomerSubscriberID,
		DataSource, 
		DateEffective, 
		DateTerminated, 
		EmployeeID, 
		SubscriberGroup, 
		State,
		SubscriberSubGroup, 
		ZipCode,
		HedisMeasureID )
SELECT	Address1				= e.Address1, 
		Address2				= e.Address2, 
		City					= e.City, 
		Client					= 'NCQA',  
		CoverageType			= NULL,  
		CustomerSubscriberID	= m.subid, 
		DataSource				= 'NCQA_QI17_RDSM.dbo.member_gm', 
		DateEffective			= NULL,  
		DateTerminated			= NULL,  
		EmployeeID				= e.EmployeeID, 
		SubscriberGroup			= NULL,  
		State					= e.State, 
		SubscriberSubGroup		= NULL, 
		ZipCode					= e.ZipCode, 
		HedisMeasureID			= left(measureset, 10)
FROM	NCQA_QI17_RDSM..member_gm m
		JOIN dbo.Employee e --WITH (INDEX(fk_employee)) 
			ON	
			m.memid = e.CustomerEmployeeID and
			left(m.measureset, 10) = e.HedisMeasureID

EXEC alter_index 'Subscriber','C'

DECLARE @cStandardValue	char( 2 )
SELECT @cStandardValue = StandardValue FROM dbo.xrefRelationshipToSubscriber WHERE ClientID = 'NCQA'


--
--DROP INDEX Member.ixMember_CustomerMemberID
--DROP STATISTICS Member.sp_Member_CustomerMemberID
EXEC alter_index 'member','D'

-- Member
INSERT INTO dbo.Member
(		Address1, 
		Address2, 
		City, 
		Client, 
		CustomerMemberID, 
		DataSource, 
		DateOfBirth,
		Gender, 
		HedisMeasureID, 
		ihds_member_id, 
		NameFirst, 
		NameLast, 
		NameMiddleInitial, 
		NamePrefix,
		NameSuffix, 
		RelationshipToSubscriber, 
		SSN, 
		State, 
		SubscriberID, 
		ZipCode,
		Race,
		Ethnicity,
		MemberLanguage,
		InterpreterFlag,
		RaceEthnicitySource,
		RaceSource,
		EthnicitySource,
		SpokenLanguage,
		SpokenLanguageSource,
		WrittenLanguage,
		WrittenLanguageSource,
		OtherLanguage,
		OtherLanguageSource)
SELECT	Address1					= m.add1, 
		Address2					= m.add2, 
		City						= m.city, 
		Client						= 'NCQA', 
		CustomerMemberID			= m.memid, 
		DataSource					= 'NCQA_QI17_RDSM.dbo.member_gm', 
		DateOfBirth					= case when m.dob = '' then null else m.dob end,
		Gender						= m.gender, 
		HedisMeasureID				= left(m.measureset, 10),  
		ihds_member_id				= m.ihds_member_id, 
		NameFirst					= m.fname, 
		NameLast					= m.lname,  
		NameMiddleInitial			= m.mmidname,  
		NamePrefix					= NULL, 
		NameSuffix					= NULL, 
		RelationshipToSubscriber	= @cStandardValue,  
		SSN							= NULL, 
		State						= m.state,  
		SubscriberID				= s.SubscriberID,  
		ZipCode 					= m.mzip,
		Race 						= m.race,
		Ethnicity 					= m.ethn,
		MemberLanguage 				= NULL,
		InterpreterFlag 			= NULL,
		RaceEthnicitySource			= ISNULL(m.racesource, m.ethnsource),
		RaceSource					= m.racesource,
		EthnicitySource				= m.ethnsource,
		SpokenLanguage				= m.spokenlang,
		SpokenLanguageSource		= m.spokenlangsource,
		WrittenLanguage				= m.writtenlang,
		WrittenLanguageSource		= m.writtenlangsource,
		OtherLanguage				= m.otherlang,
		OtherLanguageSource			= m.otherlangsource
FROM	NCQA_QI17_RDSM..member_gm m
			JOIN dbo.Employee e --WITH (INDEX(fk_employee)) 
			ON	
				m.memid = e.CustomerEmployeeID and
				left(m.measureset, 10) = e.HedisMeasureID
			JOIN dbo.Subscriber s WITH (INDEX(fk_employeeid)) ON 
				e.EmployeeID = s.EmployeeID

--create index ixMember_CustomerMemberID on Member
--(CustomerMemberID)
--
--create statistics sp_Member_CustomerMemberID on Member
--(CustomerMemberID)

EXEC alter_index 'member','C'



--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: Member Elig History

NAME		FIELD								VALUE		DESCRIPTION
MemID		Member ID										Unique Member ID
StartDate	Start Date							YYYYMMDD	Contains the greater of the enrollment date or the notification date (may be blank in some decks)
FinishDate	Disenrollment Date					YYYYMMDD	Date the member disnerolled, If there is a start date and this date is blank that indicates the member is currently enrolled
Dental		Dental Benefit						Y			"Indicates if member has a dental benefit
															(blank for all measures except ADV)"
												N			"Indicates if member has a dental benefit
															(blank for all measures except ADV)"
Drug		Drug Benefit						Y			Indicates if the member has an ambulatory prescription benefit (may be blank)
												N	
MHInpt		Mental Health Benefit - Inpatient	Y			Indicates if the member has an inpatient MH benefit (may be blank)
												N	
MHdn		Mental Health Benefit - Day/Night	Y			"Indicates if the member has a day/night 
															MH benefit (may be blank)"
												N	
Mhamb		Mental Health Benefit - Ambulatory	Y			Indicates if the member has an ambulatory MH benefit (may be blank)
												N	
CDInpt		ChemDep Benefit - Inpatient			Y			Indicates if the member has an inpatient CD benefit (may be blank)
												N	
CDdn		ChemDep Benefit - Day/Night			Y			"Indicates if the member has a day/night 
															CD benefit (may be blank)"
												N	
CDamb		ChemDep Benefit - Ambulatory		Y			Indicates if the member has an ambulatory CD benefit (may be blank)
												N	
Payer		Payer								MDE			Medicaid Dual Eligible HMO
												MD			Medicaid Disabled HMO
												MLI			Medicaid Low Income HMO
												MRB			Medicaid Restricted Benefit HMO
												MR			Medicare Advantage HMO
												MP			Medicare Advantage PPO
												MC			Medicare Cost
												PPO			Commercial PPO
												POS			Commercial POS
												HMO			Commercial HMO
												CHP			Child Health Insurance Program 
PEflag		Health Plan Employee Flag			Y			"Indicates if the member is a health plan 
															employee flag (may be blank) Currently not in use"
												N	
Ind			Indicator							Y			P4P Testing only, contains either the PO or the MCO the member is enrolled in (may be blank)
															N	

*/
--**************************************************************************************
--**************************************************************************************


--DECLARE	@iHealthPlan	int,
--	@iProvider	int,
--	@iPharmacy	int
--
--SELECT @iHealthPlan = HealthPlanID FROM dbo.HealthPlan WHERE HealthPlanName = 'NCQA'

EXEC alter_index 'eligibility','D'

--Eligibility
INSERT INTO dbo.Eligibility
(		Client, 
		DataSource, 
		DateEffective, 
		DateTerminated, 
		HealthPlanID, 
		MemberID,
		ProductType,
		HealthPlanEmployeeFlag,
		CoverageDentalFlag,
		CoveragePharmacyFlag,
		CoverageMHInpatientFlag,
		CoverageMHDayNightFlag,
		CoverageMHAmbulatoryFlag,
		CoverageCDInpatientFlag,
		CoverageCDDayNightFlag,
		CoverageCDAmbulatoryFlag,
		CoverageHospiceFlag,
		HedisMeasureID )
SELECT	'NCQA', 
		'NCQA_QI17_RDSM.dbo.member_en',
		DateEffective	= convert(smalldatetime,StartDate), 
		DateTerminated	= convert(smalldatetime,FinishDate), 
		@iHealthPlan, 
		MemberID		= m.MemberID,
		payer,
		peflag,
		dental,
		drug,
		mhinpt,
		mhdn,
		mhamb,
		cdinpt,
		cddn,
		cdamb,
		hospice,
		left(measureset, 10)
FROM	NCQA_QI17_RDSM..member_en e
			JOIN dbo.Member m WITH (INDEX(fk_ihds_member_id)) ON
				e.ihds_member_id = m.ihds_member_id
where	isdate(StartDate)=1 and isdate(FinishDate)=1

EXEC alter_index 'eligibility','C'

--INSERT INTO dbo.Eligibility( Client, DataSource, DateEffective, DateTerminated, HealthPlanID, MemberID )
--SELECT	'NCQA', 'TestDeck.member_en', e.StartDate, e.FinishDate, @iHealthPlan, m.MemberID
--FROM	WSMA_RDSM.TestDeck.member_en e WITH ( INDEX( ixMemberEN_MemID )) 
--	JOIN dbo.Member m WITH ( INDEX( ixMember_CustomerMemberID )) ON e.memid = m.CustomerMemberID
--return







--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: Pharmacy
NAME		FIELD										VALUE	DESCRIPTION
MemID		Member ID											Unique Member ID
PDaysSup	Days supply of prescription							Indicates the number of days the prescription should last if taken according to the directions
Supply		Supply flag									Y		Indicates if the claim is for a supply or not (may be balnk)
														N	
PrServDate	Service Date								YYYYMMDD	
PDiscIng	Discounted Ingredient Cost (right justified)		No decimal point
PDisR		Discount/Rebate (right justified)			Positive values	No decimal point
PDispFee	Dispense Fee (right justified)						No decimal point
PAdmFee		Administration Fee (right justified)				No decimal point
PMemberCo	Member copay/deductible (right justified)			No decimal point
NDC			NDC Drug Code										Indicates type of drug
Clmstat		Claim status								1		Paid
														2		Denied
mquant		Metric Quantity										Indicates metric quantity dispensed


*/
--**************************************************************************************
--**************************************************************************************


--DECLARE	@iHealthPlan	int,
--	@iProvider	int,
--	@iPharmacy	int
--
--SELECT @iHealthPlan = HealthPlanID FROM dbo.HealthPlan WHERE HealthPlanName = 'NCQA'
--SELECT @iProvider = ProviderID FROM dbo.Provider WHERE ihds_prov_id = 0
--SELECT @iPharmacy = PharmacyID FROM dbo.Pharmacy where NPI = 0

EXEC alter_index 'pharmacyclaim','D'

-- PharmacyClaim
INSERT INTO dbo.PharmacyClaim
(		AdjudicationIndicator, 
		ClaimNumber, 
		Client, 
		CostAverageWholesale, 
		CostCopay,
		CostDeductible, 
		CostDispensingFee, 
		CostIngredient, 
		CostPatientPay, 
		CostPlanPay, 
		CostSalesTax,
		CostTotal, 
		CostUsualCustomary, 
		CostRebate, 
		CostAdministrationFee, 
		DataSource, 
		DateDispensed, 
		DateOrdered, 
		DatePaid, 
		DateValidBegin,
		DateValidEnd,
		DaysSupply,
		DispenseAsWrittenCode, 
		HealthPlanID, 
		HedisMeasureID, 
		ihds_member_id, 
		ihds_prov_id_dispensing,
		ihds_prov_id_ordering, 
		ihds_prov_id_prescribing, 
		IsMailOrder, 
		MemberID, 
		NDC, 
		NDCFormat, 
		PharmacyID,
		PrescribingProviderID, 
		Quantity, 
		QuantityDispensed,
		RefillNumber, 
		RefillQuantity, 
		UnitOfMeasure,
		SupplyFlag,
		ClaimStatus,
		SupplementalDataFlag,
		CVX
		)
SELECT	AdjudicationIndicator		= NULL, 
		ClaimNumber					= NULL, --p.id, --Added to prevent losing scripts that have the same NDC code. See MMA PCS on 11/28/2016 (LCF)
		Client						= 'NCQA', 
		CostAverageWholesale		= NULL,  
		CostCopay					= NULL, --case when isnumeric(PMemberCo)=1 then PMemberCo else 0 end, 
		CostDeductible				= NULL,  
		CostDispensingFee			= NULL, --p.PDispFee,  
		CostIngredient				= NULL, --p.PDiscIng, 
		CostPatientPay				= NULL,  
		CostPlanPay					= NULL,  
		CostSalesTax				= NULL, 
		CostTotal					= NULL,  
		CostUsualCustomary			= NULL,  
		CostRebate					= NULL, --case when isnumeric(pdisr)=1 then pdisr else 0 end, 
		CostAdministrationFee		= NULL, --case when isnumeric(padmfee)=1 then padmfee else 0 end, 
		DataSource					= 'NCQA_QI17_RDSM.dbo.pharm',  
		DateDispensed				= case when prservdate = '' then null else prservdate end,  
		DateOrdered					= NULL,  
		DatePaid					= NULL,  
		DateValidBegin				= NULL,
		DateValidEnd				= NULL,
		DaysSupply					= case when isnumeric(pdayssup)=1 then pdayssup else 0 end, 
		DispenseAsWrittenCode		= NULL,  
		HealthPlanID				= @iHealthPlan,  
		HedisMeasureID				= left(measureset, 10),  
		ihds_member_id				= m.ihds_member_id,  
		ihds_prov_id_dispensing		= NULL, 
		ihds_prov_id_ordering		= NULL,  
		ihds_prov_id_prescribing	= 0,  
		IsMailOrder					= NULL,  
		MemberID					= m.MemberID,  
		NDC							= p.NDC,  
		NDCFormat					= NULL,  
		PharmacyID					= @iPharmacy, 
		PrescribingProviderID		= @iProvider,  
		Quantity					= case when isnumeric(p.mquant)=1 then CONVERT(int, p.mquant) else 0 end,
		QuantityDispensed			= case when isnumeric(p.dquant)=1 then CONVERT(decimal(18,6), p.dquant) else 0 end,
		RefillNumber				= NULL,  
		RefillQuantity				= NULL,  
		UnitOfMeasure				= NULL, 
		SupplyFlag					= NULL, --supply, 
		ClaimStatus					= clmstat ,
		SupplementalDataFlag		= ISNULL(NULLIF(p.suppdata, ''), 'N'),
		CVX							= NULL
FROM	NCQA_QI17_RDSM..pharm p
		JOIN dbo.Member m WITH (INDEX(fk_ihds_member_id)) ON 
			p.ihds_member_id = m.ihds_member_id
--UNION -- Replaced with insert statement.  
		-- UNION was eliminating needed duplicates -- GLG 12/7/2016
INSERT INTO dbo.PharmacyClaim
(		AdjudicationIndicator, 
		ClaimNumber, 
		Client, 
		CostAverageWholesale, 
		CostCopay,
		CostDeductible, 
		CostDispensingFee, 
		CostIngredient, 
		CostPatientPay, 
		CostPlanPay, 
		CostSalesTax,
		CostTotal, 
		CostUsualCustomary, 
		CostRebate, 
		CostAdministrationFee, 
		DataSource, 
		DateDispensed, 
		DateOrdered, 
		DatePaid, 
		DateValidBegin,
		DateValidEnd,
		DaysSupply,
		DispenseAsWrittenCode, 
		HealthPlanID, 
		HedisMeasureID, 
		ihds_member_id, 
		ihds_prov_id_dispensing,
		ihds_prov_id_ordering, 
		ihds_prov_id_prescribing, 
		IsMailOrder, 
		MemberID, 
		NDC, 
		NDCFormat, 
		PharmacyID,
		PrescribingProviderID, 
		Quantity, 
		QuantityDispensed,
		RefillNumber, 
		RefillQuantity, 
		UnitOfMeasure,
		SupplyFlag,
		ClaimStatus,
		SupplementalDataFlag,
		CVX
		)
SELECT	AdjudicationIndicator		= NULL, 
		ClaimNumber					= NULL, --p.id,  --Added to prevent losing scripts that have the same NDC code. See MMA PCS on 11/28/2016 (LCF)
		Client						= 'NCQA', 
		CostAverageWholesale		= NULL,  
		CostCopay					= NULL, --case when isnumeric(PMemberCo)=1 then PMemberCo else 0 end, 
		CostDeductible				= NULL,  
		CostDispensingFee			= NULL, --p.PDispFee,  
		CostIngredient				= NULL, --p.PDiscIng, 
		CostPatientPay				= NULL,  
		CostPlanPay					= NULL,  
		CostSalesTax				= NULL, 
		CostTotal					= NULL,  
		CostUsualCustomary			= NULL,  
		CostRebate					= NULL, --case when isnumeric(pdisr)=1 then pdisr else 0 end, 
		CostAdministrationFee		= NULL, --case when isnumeric(padmfee)=1 then padmfee else 0 end, 
		DataSource					= 'NCQA_QI17_RDSM.dbo.pharmacyclinical',  
		DateDispensed				= case when ddate = '' then null else ddate end,  
		DateOrdered					= case when odate = '' then null else odate end,  
		DatePaid					= NULL,  
		DateValidBegin				= case when startdate = '' then null else startdate end,
		DateValidEnd				= case when edate = '' then null else edate end,
		DaysSupply					= 0, 
		DispenseAsWrittenCode		= NULL,  
		HealthPlanID				= @iHealthPlan,  
		HedisMeasureID				= left(measureset, 10),  
		ihds_member_id				= m.ihds_member_id,  
		ihds_prov_id_dispensing		= NULL, 
		ihds_prov_id_ordering		= NULL,  
		ihds_prov_id_prescribing	= 0,  
		IsMailOrder					= NULL,  
		MemberID					= m.MemberID,  
		NDC							= NULL,  
		NDCFormat					= NULL,  
		PharmacyID					= @iPharmacy, 
		PrescribingProviderID		= @iProvider,  
		Quantity					= 0,
		QuantityDispensed			= 0,
		RefillNumber				= NULL,  
		RefillQuantity				= NULL,  
		UnitOfMeasure				= NULL, 
		SupplyFlag					= NULL, --supply, 
		ClaimStatus					= 2,
		SupplementalDataFlag		= 'N',
		CVX							= CASE WHEN p.oflag = 'C' AND p.rxnorm <> '' THEN LTRIM(RTRIM(p.rxnorm)) END
FROM	NCQA_QI17_RDSM..pharmacyclinical p
		JOIN dbo.Member m WITH (INDEX(fk_ihds_member_id)) ON 
			p.ihds_member_id = m.ihds_member_id

update	PharmacyClaim
set		ClaimNumber = PharmacyClaimID

EXEC alter_index 'pharmacyclaim','C'







--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: Lab
NAME		FIELD				DESCRIPTION
MemID		Member ID			Unique Member ID
CPT Code	Test				CPT Code for LDL or HbA1c (blank values are tested)
LOINC		LOINC Code			Indicates LOINC code for this lab event (dash included)
Value		Value				Value with decimal (blank values are tested)
Date_S		Date of Service		(blank values are tested)
PNInd		Indicator			Positive (used for macro and micro albumen tests only) / Negative  (used for macro and micro albumen tests only)
*/
--**************************************************************************************
--**************************************************************************************

EXEC alter_index 'LabResult','D'

-- LabResult
INSERT INTO dbo.LabResult(
	Client,
	DataSource,
	MemberID,
	CustomerMemberID,
	CustomerOrderingProviderID,
	DateOfService,
	DateServiceBegin,
	DateServiceEnd,
	HCPCSProcedureCode,
	HedisMeasureID,
	ihds_member_id,
	ihds_prov_id_ordering,
	InstanceID,
	LabProviderID,
	LabValue,
	LOINCCode,
	SNOMEDCode,
	OrderNumber,
	PNIndicator,
	SupplementalDataFlag,
	LabStatus,
	ResultType,
	TestType,
	Units
	 )
SELECT	
	Client							= 'NCQA',
	DataSource						= 'NCQA_QI17_RDSM.dbo.lab',
	MemberID						= MemberID,
	CustomerMemberID				= memid,
	CustomerOrderingProviderID		= '',
	DateOfService					= case	when date_s = '' 
											then null 
											when isdate(date_s)=0 
											then null 
											else date_s 
									  end,
	DateServiceBegin				= case	when date_s = '' 
											then null 
											when isdate(date_s)=0 
											then null 
											else date_s 
									  end,
	DateServiceEnd					= case	when date_s = '' 
											then null 
											when isdate(date_s)=0 
											then null 
											else date_s 
									  end,
	HCPCSProcedureCode				= cptcode,
	HedisMeasureID					= left(measureset, 10),
	ihds_member_id					= m.ihds_member_id,
	ihds_prov_id_ordering			= NULL,
	InstanceID						= NULL,
	LabProviderID					= '',
	LabValue						= case	when isnumeric(ltrim(rtrim([value])))=1 
											then convert(decimal(9,4),ltrim(rtrim([value])))
											else null 
									  end,
	LOINCCode						= ltrim(rtrim(loinc)),
	SNOMEDCode						= NULL,
	OrderNumber						= '',
	PNIndicator						= NULL,
	SupplementalDataFlag			= ISNULL(NULLIF(v.suppdata, ''), 'N'),
	LabStatus						= NULL,
	ResultType						= NULL,
	TestType						= NULL,
	Units							= NULL
FROM	NCQA_QI17_RDSM..lab v
	JOIN dbo.Member m WITH (INDEX(fk_ihds_member_id)) ON 
		v.ihds_member_id = m.ihds_member_id
UNION
SELECT	
	Client							= 'NCQA',
	DataSource						= 'NCQA_QI17_RDSM.dbo.lab',
	MemberID						= MemberID,
	CustomerMemberID				= ptid,
	CustomerOrderingProviderID		= '',
	DateOfService					= case	when [date] = '' 
											then null 
											when isdate([date])=0 
											then null 
											else [date]
									  end,
	DateServiceBegin				= case	when [date] = '' 
											then null 
											when isdate([date])=0 
											then null 
											else [date]
									  end,
	DateServiceEnd					= case	when date_e = '' 
											then null 
											when isdate(date_e)=0 
											then null 
											else date_e
									  end,
	HCPCSProcedureCode				= CASE WHEN oflag = 'C' AND ocode <> '' THEN ltrim(rtrim(ocode)) END,
	HedisMeasureID					= left(measureset, 10),
	ihds_member_id					= m.ihds_member_id,
	ihds_prov_id_ordering			= NULL,
	InstanceID						= NULL,
	LabProviderID					= '',
	LabValue						= case	when isnumeric(ltrim(rtrim([value])))=1 
											then convert(decimal(9,4),ltrim(rtrim([value])))
											else null 
									  end,
	LOINCCode						= CASE WHEN oflag = 'L' AND ocode <> '' THEN ltrim(rtrim(ocode)) END,
	SNOMEDCode						= CASE WHEN oflag = 'S' AND ocode <> '' THEN ltrim(rtrim(ocode)) END,
	OrderNumber						= '',
	PNIndicator						= NULL,
	SupplementalDataFlag			= 'Y',
	LabStatus						= [status],
	ResultType						= rvflag,
	TestType						= tflag,
	Units							= units
FROM	NCQA_QI17_RDSM..observation v
	JOIN dbo.Member m WITH (INDEX(fk_ihds_member_id)) ON 
		v.ihds_member_id = m.ihds_member_id

EXEC alter_index 'LabResult','D'












--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: Visit
NAME		FIELD									VALUE		DESCRIPTION
MemID		Member ID											Unique Member ID
Date_S		Date of Service							YYYYMMDD	Date of Service for an ambulatory event, admission date for inpatient events
Date_Adm	Admission Date							YYYYMMDD	Date of admission for inpatient events (blank for ambulatory events)
Date_Disch	Discharge Date							YYYYMMDD	Date of discharge for inpatient events (blank for ambulatory events)
DaysCov		Covered Days										Total number of days covered for a particular admission (same number will appear on every claim line)(will be blank for ambulatory services)
CPT	CPT		Code												CPT-4 procedure code (blank for inpatient services)
--CPTMod_1	CPT Modifier 1							e.g.:50		No decimal point
--CPTMod_2	CPT Modifier 2							e.g.:50		No decimal point
HCPCS		HCPCS code											Valid HCPC codes (blank if measure does not include HCPCs codes)
CPT2		CPT II Code											Valid CDT II codes (blank if measure does not include CDT II codes)
--Diag_I_1	Principal ICD-9 Diagnosis Code						Valid ICD-9 diagnosis codes (blank if measure does not include ICD-9 codes)
--Diag_I_2	Secondary ICD-9 Diagnosis code (2)					Valid ICD-9 diagnosis codes (may be blank)
--Diag_I_3	Secondary ICD-9 Diagnosis code (3)					Valid ICD-9 diagnosis codes (may be blank)
--Diag_I_4	Secondary ICD-9 Diagnosis code (4)					Valid ICD-9 diagnosis codes (may be blank)
--Diag_I_5	Secondary ICD-9 Diagnosis code (5)					Valid ICD-9 diagnosis codes (may be blank)
--Diag_I_6	Secondary ICD-9 Diagnosis code (6)					Valid ICD-9 diagnosis codes (may be blank)
--Diag_I_7	Secondary ICD-9 Diagnosis code (7)					Valid ICD-9 diagnosis codes (may be blank)
--Diag_I_8	Secondary ICD-9 Diagnosis code (8)					Valid ICD-9 diagnosis codes (may be blank)
--Diag_I_9	Secondary ICD-9 Diagnosis code (9)					Valid ICD-9 diagnosis codes (may be blank)
----Diag_I_10	Secondary ICD-9 Diagnosis code (10)					Valid ICD-9 diagnosis codes (may be blank)
--Proc_I_1	Principal ICD-9 Procedure Code						Valid ICD-9 procedure codes (blank if measure does not include ICD-9 codes)
--Proc_I_2	Secondary ICD-9 Procedure code (2)					Valid ICD-9 procedure codes (may be blank)
--Proc_I_3	Secondary ICD-9 Procedure code (3)					Valid ICD-9 procedure codes (may be blank)
--Proc_I_4	Secondary ICD-9 Procedure code (4)					Valid ICD-9 procedure codes (may be blank)
--Proc_I_5	Secondary ICD-9 Procedure code (5)					Valid ICD-9 procedure codes (may be blank)
--Proc_I_6	Secondary ICD-9 Procedure code (6)					Valid ICD-9 procedure codes (may be blank)
DRG			DRG Code											Valid DRG codes (blank if measure does not include DRG codes)
--DRG_Flag	DRG Identifier								C		CMS DRG
--														M		MS DRG
DischStatus	Discharge Status 									Form Locator 22 Values (blank if measure does not require discharge status)
Rev			UB-92 Revenue Code									Valid revenue codes (blank if measure does not require revenue codes)
--BillType	UB-92 Type of Bill Code								Valid type of bill codes (blank if measure does not require type of bill codes)
--OccurCode	UB-92 Occurrence Code								Valid occurrence codes (blank if measure does not require occurrence codes)
--Nbr_times	Number of Times										Quantity of Service Billed
HCFAPOS		CMS Place of Service Code							Valid place of service codes (blank if measure does not require place of service codes)
ClaimStatus	Claim Status								1		Paid
														2		Denied
														Blank	Denied
ProvID		Provider ID											Unique Proivider ID
PCP			PCP Flag									Y		Indicates if provider is a PCP or not (blank if not necessary for the measure)
														N	
OBGYN		OBGYN Flag									Y		Indicates if provider is a OBGYN or not (blank if not necessary for the measure)
														N	
MHProv		MH Provider Flag							Y		Indicates if provider is a MH provider or not (blank if not necessary for the measure)
														N	
EyeCProv	EyeCare Provider Flag						Y		Indicates if provider is an eye care provider or not (blank if not necessary for the measure)
														N	
Dentist		DentistFlag									Y		Indicates if provider is a dentist or not (blank if not necessary for the measure)
														N	
ProvPres	Provider Prescribing Privileges				Y		Indicates if provider has prescribing privileges  or not (blank if not necessary for the measure)
														N	
Neph		Nephrologist Flag							Y		Indicates if provider is a nephrologist or not (blank if not necessary for the measure)
														N	
CDProv		CD Provider Flag							Y		Indicates if provider is a CD provider or not (blank if not necessary for the measure)
														N	
NPRProv		NPR Provider Flag							Y		Indicates if provider is a Nurse Practitioner provider or not (blank if not necessary for the measure)
														N	
PASProv		PAS Provider Flag							Y		Indicates if provider is a Physicians Assistant provider or not (blank if not necessary for the measure)
														N	

*/
--**************************************************************************************
--**************************************************************************************




CREATE TABLE #visit (
	visit_row_id [int] IDENTITY(1,1) NOT NULL,
	[memid] [varchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[date_s] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[date_adm] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[date_disch] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dayscov] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cpt] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cptmod_1] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cptmod_2] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[hcpcs] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cpt2] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_1] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_2] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_3] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_4] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_5] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_6] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_7] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_8] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_9] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_10] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_1] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_2] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_3] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_4] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_5] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_6] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	icd_flag varchar(1)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[drg] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[drg_flag] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dischstatus] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rev] [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[billtype] [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nbr_times] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[hcfapos] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[claimstatus] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[provid] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	suppdata varchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[measureset] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[measure] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ihds_member_id] [int] NULL,
	[ihds_provider_id_servicing] [int] NULL
)


insert into #visit
           ([memid]
           ,[date_s]
           ,[date_adm]
           ,[date_disch]
           ,[dayscov]
           ,[cpt]
           ,[cptmod_1]
           ,[cptmod_2]
           ,[hcpcs]
           ,[cpt2]
           ,[diag_i_1]
           ,[diag_i_2]
           ,[diag_i_3]
           ,[diag_i_4]
           ,[diag_i_5]
           ,[diag_i_6]
           ,[diag_i_7]
           ,[diag_i_8]
           ,[diag_i_9]
           ,[diag_i_10]
           ,[proc_i_1]
           ,[proc_i_2]
           ,[proc_i_3]
           ,[proc_i_4]
           ,[proc_i_5]
           ,[proc_i_6]
		   ,icd_flag
           ,[drg]
           ,[drg_flag]
           ,[dischstatus]
           ,[rev]
           ,[billtype]
           ,[nbr_times]
           ,[hcfapos]
           ,[claimstatus]
           ,[provid]
		   ,suppdata
           ,[measureset]
		   ,[measure]
           ,[ihds_member_id]
           ,[ihds_provider_id_servicing]
		   )
select		[memid]
           ,[date_s]
           ,[date_adm]
           ,[date_disch] =	case	when	date_disch = '' or
											(len(date_disch) = 8 and date_disch between '19000101' and '20790606') 
									then [date_disch] 
									else [date_adm] 
							end
           ,[dayscov]
           ,[cpt]
           ,[cptmod_1]
           ,[cptmod_2]
           ,[hcpcs]
           ,[cpt2]
           ,[diag_i_1]
           ,[diag_i_2]
           ,[diag_i_3]
           ,[diag_i_4]
           ,[diag_i_5]
           ,[diag_i_6]
           ,[diag_i_7]
           ,[diag_i_8]
           ,[diag_i_9]
           ,[diag_i_10]
           ,[proc_i_1]
           ,[proc_i_2]
           ,[proc_i_3]
           ,[proc_i_4]
           ,[proc_i_5]
           ,[proc_i_6]
		   ,icd_flag
           ,[drg]
           ,'M' --[drg_flag]
           ,[dischstatus]
           ,[rev]
           ,[billtype]
           ,[nbr_times]
           ,[hcfapos]
           ,[claimstatus]
           ,[provid]
           ,ISNULL(NULLIF(suppdata, ''), 'N') AS suppdata
		   ,[measureset] 
		   ,measure
           ,[ihds_member_id]
           ,[ihds_provider_id_servicing]
from	NCQA_QI17_RDSM..visit

--delete from Claim
--DECLARE	@iHealthPlan	int,
--	@iProvider	int,
--	@iPharmacy	int
--
--SELECT @iHealthPlan = HealthPlanID FROM dbo.HealthPlan WHERE HealthPlanName = 'NCQA'
--SELECT @iProvider = ProviderID FROM dbo.Provider WHERE ihds_prov_id = 0
--SELECT @iPharmacy = PharmacyID FROM dbo.Pharmacy where NPI = 0


--DROP INDEX Claim.ix_Claim_PayerClaimID
--DROP STATISTICS Claim.sp_Claim_PayerClaimID
--
--DROP INDEX Claim.ix_Claim_MemberID
--DROP STATISTICS Claim.sp_Claim_MemberID
EXEC alter_index 'claim','D'

-- Claim
INSERT INTO dbo.Claim
(		BillingProviderID, 
		BillType, 
		ClaimDisallowReason, 
		ClaimType, 
		ClaimTypeIndicator,
		ClaimStatus,
		Client,
		DataSource, 
		DateClaimPaid, 
		DateServiceBegin, 
		DateServiceEnd, 
		DiagnosisCode1, 
		DiagnosisCode2, 
		DiagnosisCode3,
		DiagnosisCode4, 
		DiagnosisCode5, 
		DiagnosisCode6, 
		DiagnosisCode7, 
		DiagnosisCode8, 
		DiagnosisCode9, 
		DiagnosisCode10,
		DiagnosisRelatedGroup, 
		DiagnosisRelatedGroupType, 
		DischargeStatus, 
		HealthPlanID, 
		HedisMeasureID, 
		ihds_member_id, 
		ihds_prov_id_attending,
		ihds_prov_id_billing, 
		ihds_prov_id_med_group, 
		ihds_prov_id_pcp, 
		ihds_prov_id_referring, 
		ihds_prov_id_servicing,
		ihds_prov_id_vendor, 
		MedicarePaidIndicator, 
		MemberID, 
		PatientStatus, 
		PayerClaimID, 
		PayerClaimIDSuffix,
		PayerID, 
		PlaceOfService, 
		RecordType, 
		ReferringProviderID, 
		ServicingProviderID,
		SurgicalProcedure1,
		SurgicalProcedure2, 
		SurgicalProcedure3, 
		SurgicalProcedure4,
		SurgicalProcedure5,
		SurgicalProcedure6 ,
		ICDCodeType,
		SupplementalDataFlag
)
SELECT	
		BillingProviderID			= NULL, 
		BillType					= v.billtype, 
		ClaimDisallowReason			= NULL, 
		ClaimType					= CASE WHEN p.HospitalFlag IN ('1','Y') OR p.SkilledNursingFacFlag IN ('1','Y') OR NULLIF(v.rev, '') IS NULL THEN 'U' WHEN p.PCPFlag IN ('1','Y') OR p.SurgeonFlag IN ('1','Y') THEN 'H' END, 
		ClaimTypeIndicator			= NULL,
		ClaimStatus					= v.claimstatus,
		Client						= 'NCQA', 
		DataSource					= 'NCQA_QI17_RDSM.dbo.visit',  
		DateClaimPaid				= NULL,  
		DateServiceBegin			= case	--when	date_adm = '' AND date_disch = '' AND date_s = ''
											--THEN	m.DateOfBirth
											WHEN	date_adm = '' 
											then	case	when isdate(date_s)=0 
															then null 
															else date_s 
													end 
											else	date_adm 
									end,  
		DateServiceEnd				= case when date_disch = '' then null else date_disch end,  
		DiagnosisCode1				= v.Diag_I_1,  
		DiagnosisCode2				= v.Diag_I_2,  
		DiagnosisCode3				= v.Diag_I_3, 
		DiagnosisCode4				= v.Diag_I_4,  
		DiagnosisCode5				= v.Diag_I_5,  
		DiagnosisCode6				= v.Diag_I_6,  
		DiagnosisCode7				= v.Diag_I_7, 
		DiagnosisCode8				= v.Diag_I_8,  
		DiagnosisCode9				= v.Diag_I_9, 
		DiagnosisCode10				= v.Diag_I_10, 
		DiagnosisRelatedGroup		= v.DRG, 
		DiagnosisRelatedGroupType	= v.drg_flag, 
		DischargeStatus				= v.DischStatus,  
		HealthPlanID				= @iHealthPlan,  
		HedisMeasureID				= left(measureset, 10),  
		ihds_member_id				= m.ihds_member_id,  
		ihds_prov_id_attending		= NULL, 
		ihds_prov_id_billing		= NULL,  
		ihds_prov_id_med_group		= NULL, 
		ihds_prov_id_pcp			= NULL,  
		ihds_prov_id_referring		= NULL,  
		ihds_prov_id_servicing		= v.ihds_provider_id_servicing, 
		ihds_prov_id_vendor			= NULL,
		MedicarePaidIndicator		= NULL,  
		MemberID					= m.MemberID,  
		PatientStatus				= NULL,  
		PayerClaimID				= visit_row_id,  
		PayerClaimIDSuffix			= NULL, 
		PayerID						= NULL,  
		PlaceOfService				= v.HCFAPOS,  
		RecordType					= NULL,  
		ReferringProviderID			= NULL,  
		ServicingProviderID			= p.ProviderID,
		SurgicalProcedure1			= v.Proc_I_1, 
		SurgicalProcedure2			= v.Proc_I_2,  
		SurgicalProcedure3			= v.Proc_I_3,  
		SurgicalProcedure4			= v.Proc_I_4, 
		SurgicalProcedure5			= v.proc_i_5, 
		SurgicalProcedure6			= v.proc_i_6,
		ICDCodeType					= CONVERT(tinyint, CASE v.icd_flag WHEN '9' THEN 9 WHEN 'X' THEN 10 ELSE 0 END),
		SupplementalDataFlag		= v.suppdata
FROM	#visit v
			JOIN dbo.Member m WITH (INDEX(fk_ihds_member_id)) ON 
				v.ihds_member_id = m.ihds_member_id
			LEFT JOIN dbo.Provider p WITH (INDEX(fk_ihds_prov_id)) ON 
				v.ihds_provider_id_servicing = p.ihds_prov_id




--create index ix_Claim_PayerClaimID on Claim (PayerClaimID)
--create statistics sp_Claim_PayerClaimID on Claim (PayerClaimID)
--
--create index ix_Claim_MemberID on Claim (MemberID)
--create statistics sp_Claim_MemberID on Claim(MemberID)

EXEC alter_index 'claim','C'



--DROP INDEX ClaimLineItem.ix_ClaimLineItem_ClaimID
--DROP STATISTICS ClaimLineItem.sp_ClaimLineItem_ClaimID

EXEC alter_index 'claimLineItem','D'
--delete from ClaimLineItem

INSERT INTO dbo.ClaimLineItem
(		AmountGrossPayment, 
		ClaimID, 
		LineItemNumber, 
		ClaimStatus,
		AmountCOBSavings, 
		AmountCopay, 
		AmountDisallowed,
		AmountMedicarePaid, 
		AmountNetPayment, 
		AmountTotalCharge, 
		AmountWithold, 
		Client, 
		DataSource, 
		DateAdjusted, 
		DatePaid,
		DateServiceBegin, 
		DateServiceEnd, 
		DiagnosisCode, 
		CPTProcedureCode, 
		CPTProcedureCodeModifier1, 
		CPTProcedureCodeModifier2,
		CPTProcedureCodeModifier3, 
		HedisMeasureID, 
		PlaceOfServiceCode, 
		PlaceOfServiceCodeIndicator, 
		RevenueCode, 
		SubNumber,
		TypeOfService, 
		Units,
		CoveredDays,
		CPT_II,
		HCPCSProcedureCode )
SELECT	AmountGrossPayment				= 0, 
		ClaimID							= ClaimID, 
		LineItemNumber					= '', 
		ClaimStatus						= v.claimstatus,
		AmountCOBSavings				= NULL,  
		AmountCopay						= NULL,  
		AmountDisallowed				= NULL, 
		AmountMedicarePaid				= NULL, 
		AmountNetPayment				= NULL,  
		AmountTotalCharge				= NULL,  
		AmountWithold					= NULL,  
		Client							= 'NCQA',  
		DataSource						= 'NCQA_QI17_RDSM.dbo.visit',  
		DateAdjusted					= NULL,  
		DatePaid						= NULL, 
		DateServiceBegin				= case	--WHEN date_adm = '' AND date_disch = '' AND date_s = ''
												--THEN c.DateServiceBegin
												WHEN date_s = ''
												then case when date_adm = '' then null else date_adm end
												when isdate(date_s)=0 
												then null 
												else date_s 
										  end,  
		DateServiceEnd					= case when date_disch = '' then null else date_disch end,  
		DiagnosisCode					= v.Diag_I_1, 
		CPTProcedureCode				= cpt,  
		CPTProcedureCodeModifier1		= cptmod_1,  
		CPTProcedureCodeModifier2		= cptmod_2, 
		CPTProcedureCodeModifier3		= NULL,  
		HedisMeasureID					= left(v.measureset, 10),  
		PlaceOfServiceCode				= NULL,  
		PlaceOfServiceCodeIndicator		= NULL,  
		RevenueCode						= v.rev,  
		SubNumber						= NULL, 
		TypeOfService					= NULL,  
		Units							=	case	when v.nbr_times = '' 
													then null 
													when isnumeric(v.nbr_times)=1 
													then v.nbr_times 
													else null 
											end, 
		CoveredDays						=	case	when v.dayscov = '' 
													then null 
													when isnumeric(v.dayscov)=1 
													then v.dayscov 
													else null 
											end, 
		CPT_II							= cpt2,
		HCPCSProcedureCode				= hcpcs
FROM	#visit v
		inner join Claim c WITH (INDEX(ix_claim_payerclaimid)) on
			v.visit_row_id = c.PayerClaimID


--create index ix_ClaimLineItem_ClaimID on ClaimLineItem (ClaimID)
--create statistics sp_ClaimLineItem_ClaimID on ClaimLineItem (ClaimID)

EXEC alter_index 'claimLineItem','C'










GO
GRANT ALTER ON  [dbo].[prLoadDataStoreWithTestDeck] TO [IMIHEALTH\IMI.SQL.Developers]
GO
GRANT VIEW DEFINITION ON  [dbo].[prLoadDataStoreWithTestDeck] TO [IMIHEALTH\IMI.SQL.Developers]
GO
GRANT EXECUTE ON  [dbo].[prLoadDataStoreWithTestDeck] TO [IMIHEALTH\IMI.SQL.Developers]
GO
