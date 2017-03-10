SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[prTruncateUserData]
AS 

UPDATE	dbo.Pursuit 
SET		AbstractorID = NULL,
		AbstractionDate = NULL,
		AppointmentID = NULL,
		ReviewerID = NULL,
		NoteID = NULL,
		AttachmentID = NULL,
		PursuitCategory = NULL;

UPDATE	dbo.PursuitEvent 
SET		SampleVoidFlag = 0,
		SampleVoidReasonCode = NULL,
		AbstractionStatusID = 1,
		PursuitEventStatus = '1',
		ChartStatusValueID = NULL,
		ChartStatus = NULL,
		NoDataFoundReason = NULL,
		MedicalRecordNumber = NULL,
		LastChangedDate = CreatedDate,
		CreatedUser = '(system)',
		LastChangedUser = '(system)';

UPDATE  dbo.Member
SET		DateOfBirth = OriginalDateOfBirth,
		Gender = OriginalGender,
		LastChangedDate = CreatedDate,
		CreatedUser = '(system)',
		LastChangedUser = '(system)';

UPDATE	dbo.ProviderSite
SET		Address1 = OriginalAddress1,
		Address2 = OriginalAddress2,
		City = OriginalCity,
		[State] = OriginalState,
		Zip = OriginalZip,
		Phone = OriginalPhone,
		Fax = OriginalFax,
		Contact = OriginalContact,
		County = OriginalCounty,
		LastChangedDate = CreatedDate,
		CreatedUser = '(system)',
		LastChangedUser = '(system)';

TRUNCATE TABLE dbo.PAMeasureIntake
TRUNCATE TABLE [dbo].[MedicalRecordABABMI];
TRUNCATE TABLE [dbo].[MedicalRecordABAExcl];
TRUNCATE TABLE [dbo].[MedicalRecordAWC];
TRUNCATE TABLE [dbo].[MedicalRecordBCS];
TRUNCATE TABLE [dbo].[MedicalRecordCBPConf];
TRUNCATE TABLE [dbo].[MedicalRecordCBPDiabetes];
TRUNCATE TABLE [dbo].[MedicalRecordCBPExclusion];
TRUNCATE TABLE [dbo].[MedicalRecordCBPReading];
TRUNCATE TABLE [dbo].[MedicalRecordCCS];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_Aspirin];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_BloodPressure];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_Exclusion];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_EyeExam];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_HbA1c];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_HbA1cExclusion];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_Influenza];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_LDLC];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_Nephropathy];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_Pneumococcal];
TRUNCATE TABLE [dbo].[MedicalRecordCDC_Smoking];
TRUNCATE TABLE [dbo].[MedicalRecordCIS];
TRUNCATE TABLE [dbo].[MedicalRecordCMC];
TRUNCATE TABLE [dbo].[MedicalRecordCOACarePlan];
TRUNCATE TABLE [dbo].[MedicalRecordCOAFunctAsmt];
TRUNCATE TABLE [dbo].[MedicalRecordCOAMedRev];
TRUNCATE TABLE [dbo].[MedicalRecordCOAPain];
TRUNCATE TABLE [dbo].[MedicalRecordCOL];
TRUNCATE TABLE [dbo].[MedicalRecordFPCGA];
TRUNCATE TABLE [dbo].[MedicalRecordFPCPre];
TRUNCATE TABLE [dbo].[MedicalRecordHIV4];
TRUNCATE TABLE [dbo].[MedicalRecordHPV];
TRUNCATE TABLE [dbo].[MedicalRecordIMA];
TRUNCATE TABLE [dbo].[MedicalRecordLSC];
TRUNCATE TABLE [dbo].[MedicalRecordMRFAScreening];
TRUNCATE TABLE [dbo].[MedicalRecordMRP];
TRUNCATE TABLE [dbo].[MedicalRecordPADOD];
TRUNCATE TABLE [dbo].[MedicalRecordPDSPostpartum];
TRUNCATE TABLE [dbo].[MedicalRecordPDSPrenatal];
TRUNCATE TABLE [dbo].[MedicalRecordPPC];
TRUNCATE TABLE [dbo].[MedicalRecordPSSScreening];
TRUNCATE TABLE [dbo].[MedicalRecordRISKDiag];
TRUNCATE TABLE [dbo].[MedicalRecordW15];
TRUNCATE TABLE [dbo].[MedicalRecordW34];
TRUNCATE TABLE [dbo].[MedicalRecordWCCActive];
TRUNCATE TABLE [dbo].[MedicalRecordWCCAPCDEP];
TRUNCATE TABLE [dbo].[MedicalRecordWCCAPCSA];
TRUNCATE TABLE [dbo].[MedicalRecordWCCAPCSMOK];
TRUNCATE TABLE [dbo].[MedicalRecordWCCAPCSUBS];
TRUNCATE TABLE [dbo].[MedicalRecordWCCBMI];
TRUNCATE TABLE [dbo].[MedicalRecordWCCExcl];
TRUNCATE TABLE [dbo].[MedicalRecordWCCNutri];
TRUNCATE TABLE [dbo].[MedicalRecordWOP];
TRUNCATE TABLE AbstractionOverRead
TRUNCATE TABLE AbstractionReviewDetail
DELETE  FROM AbstractionReview
DELETE	FROM dbo.AbstractionReviewSetConfiguration
DELETE	FROM dbo.AbstractionReviewSet
DELETE	FROM dbo.ProviderSiteAppointment
DELETE  FROM Appointment
TRUNCATE TABLE dbo.PursuitEventDataEntryStatus
TRUNCATE TABLE PursuitEventChartImage
TRUNCATE TABLE PursuitEventLog
TRUNCATE TABLE PursuitEventNote
TRUNCATE TABLE dbo.PursuitEventStatusLog
TRUNCATE TABLE dbo.PursuitEventSupplementalInformation
DELETE	FROM dbo.FaxLogSubmissions
DELETE	FROM dbo.FaxLogPursuits
DELETE	FROM dbo.FaxLog
GO
