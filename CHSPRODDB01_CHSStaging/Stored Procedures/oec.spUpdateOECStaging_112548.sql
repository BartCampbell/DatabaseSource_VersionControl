SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	09/01/2016
-- Description:	updates the reference keys for the OEC staging data
-- Usage:			
--		  EXECUTE oec.spUpdateOECStaging_112548
-- =============================================
CREATE PROC [oec].[spUpdateOECStaging_112548]
AS
     SET NOCOUNT ON;
     SET XACT_ABORT ON;

     UPDATE s
	SET H_Client_RK = c.ClientHashKey, ClientName = c.ClientName
	FROM oec.AdvanceOECRaw_112548 s 
	     INNER JOIN CHSDV.dbo.R_Client c ON s.ClientID = c.CentauriClientID
	
	UPDATE s
	SET s.H_OECProject_RK = r.OECProjectHashKey, s.OECProject_BK = r.CentauriOECProjectID, s.OEC_ProjectID = r.ProjectID, s.OEC_ProjectName = r.ProjectName
	FROM oec.AdvanceOECRaw_112548 s 
	     INNER JOIN CHSDV.dbo.R_OECProject r ON s.ClientID = r.CentauriClientID AND dbo.ufn_parsefind(REPLACE(FileName,'_',':'),':',3) = r.ProjectID


    UPDATE oec.AdvanceOECRaw_112548 
    SET ProviderPhone = REPLACE(REPLACE(REPLACE(REPLACE(ProviderPhone,'-',''),'(',''),')',''),' ',''),
	   ProviderFax = REPLACE(REPLACE(REPLACE(REPLACE(ProviderFax,'-',''),'(',''),')',''),' ',''),
	   VendorPhone = REPLACE(REPLACE(REPLACE(REPLACE(VendorPhone,'-',''),'(',''),')',''),' ',''),
	   VendorFax = REPLACE(REPLACE(REPLACE(REPLACE(VendorFax,'-',''),'(',''),')',''),' ',''),
	   MemberDOB = CONVERT(VARCHAR(10),CONVERT(DATE,MemberDOB),112)

	   --SELECT memberdob, CONVERT(VARCHAR(10),CONVERT(DATE,MemberDOB),112) FROM oec.AdvanceOECRaw_112548
    
    UPDATE oec.AdvanceOECRaw_112548
    SET --H_OEC_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(DOS_FromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOS_ToDate, ''))) ))), 2)),
	   H_OEC_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))) ))), 2)),
	   H_Specialty_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(ProviderSpecialty, ''))))), 2)),
	   S_OECDetail_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberHICN, ''))), ':', RTRIM(LTRIM(COALESCE(DiagnosisCode, ''))), ':', RTRIM(LTRIM(COALESCE(ICD9_ICD10_Ind, ''))), ':', RTRIM(LTRIM(COALESCE(DOS_FromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOS_ToDate, ''))), ':', RTRIM(LTRIM(COALESCE(ClaimID, ''))), ':', RTRIM(LTRIM(COALESCE(ChaseID, ''))), ':', RTRIM(LTRIM(COALESCE(MedicalRecordID, ''))), ':', RTRIM(LTRIM(COALESCE(ChasePriority, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderRelationsRep, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderSpecialty, ''))) ))), 2)),
	   S_OECDetail_HashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberHICN, ''))), ':', RTRIM(LTRIM(COALESCE(DiagnosisCode, ''))), ':', RTRIM(LTRIM(COALESCE(ICD9_ICD10_Ind, ''))), ':', RTRIM(LTRIM(COALESCE(DOS_FromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOS_ToDate, ''))), ':', RTRIM(LTRIM(COALESCE(ClaimID, ''))), ':', RTRIM(LTRIM(COALESCE(ChaseID, ''))), ':', RTRIM(LTRIM(COALESCE(MedicalRecordID, ''))), ':', RTRIM(LTRIM(COALESCE(ChasePriority, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderRelationsRep, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderSpecialty, '')))))), 2)),
	   S_MemberDemo_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName,''))),':',RTRIM(LTRIM(COALESCE(LoadDate,''))),':',RTRIM(LTRIM(COALESCE(CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(MemberLastName,''))),':',RTRIM(LTRIM(COALESCE(MemberFirstName,''))),':',RTRIM(LTRIM(COALESCE(MemberDOB,''))),':',RTRIM(LTRIM(COALESCE(MemberGender,'')))  ))),2)),
	   S_MemberDemoHashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(MemberLastName,''))),':',RTRIM(LTRIM(COALESCE(MemberFirstName,''))),':',RTRIM(LTRIM(COALESCE(MemberDOB,''))),':',RTRIM(LTRIM(COALESCE(MemberGender,'')))  ))),2)),
	   S_ProviderDemo_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderNPI, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderLastName, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderFirstName, '')))))), 2)),
	   S_ProviderDemoHashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderNPI, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderLastName, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderFirstName, '')))))), 2)),
	   L_MemberOEC_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, '')))))), 2)),
	   L_MemberProvider_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriProviderID, '')))))), 2)),
	   L_OECProviderLocation_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriProviderID,''))),':',RTRIM(LTRIM(COALESCE(ProviderAddress ,''))),':',RTRIM(LTRIM(COALESCE(ProviderCity,''))),':',RTRIM(LTRIM(COALESCE(ProviderState,''))),':',RTRIM(LTRIM(COALESCE(ProviderZip,'')))))),2)),
	   L_ProviderSpecialty_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderSpecialty, '')))))), 2)),
	   S_MemberHICN_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberHICN, '')))))), 2)),
	   S_MemberHICN_HashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberHICN, '')))))), 2)),
	   OEC_BK = CONVERT(VARCHAR(100),CONCAT(ClientID,OECProject_BK,ProviderID,MemberID)),
	   --OEC_BK = CONVERT(VARCHAR(100),CONCAT(ClientID,OECProject_BK,ProviderID,MemberID,DOS_FromDate,DOS_ToDate)),
	   L_OECProjectOEC_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))) ))), 2)),
	   S_OECProject_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(OEC_ProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(OEC_ProjectName, ''))) ))), 2)),
	   S_OECProject_HashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(OEC_ProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(OEC_ProjectName, ''))) ))), 2)),
	   S_Location_RK_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(ProviderAddress,''))),':',RTRIM(LTRIM(COALESCE(ProviderCity,''))),':',RTRIM(LTRIM(COALESCE(ProviderState,''))),':',RTRIM(LTRIM(COALESCE(ProviderZip,'')))))),2)),
	   S_LocationHashDiff_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ProviderAddress,''))),':',RTRIM(LTRIM(COALESCE(ProviderCity,''))),':',RTRIM(LTRIM(COALESCE(ProviderState,''))),':',RTRIM(LTRIM(COALESCE(ProviderZip,'')))))),2)),
	   H_Location_RK_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ProviderAddress,''))),':',RTRIM(LTRIM(COALESCE(ProviderCity,''))),':',RTRIM(LTRIM(COALESCE(ProviderState,''))),':',RTRIM(LTRIM(COALESCE(ProviderZip,'')))))),2)),
	   S_Location_RK_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(VendorAddress,''))),':',RTRIM(LTRIM(COALESCE(VendorCity,''))),':',RTRIM(LTRIM(COALESCE(VendorState,''))),':',RTRIM(LTRIM(COALESCE(VendorZip,'')))))),2)),
	   S_LocationHashDiff_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(VendorAddress,''))),':',RTRIM(LTRIM(COALESCE(VendorCity,''))),':',RTRIM(LTRIM(COALESCE(VendorState,''))),':',RTRIM(LTRIM(COALESCE(VendorZip,'')))))),2)),
	   H_Location_RK_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(VendorAddress,''))),':',RTRIM(LTRIM(COALESCE(VendorCity,''))),':',RTRIM(LTRIM(COALESCE(VendorState,''))),':',RTRIM(LTRIM(COALESCE(VendorZip,'')))))),2)),
	   S_Contact_RK_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(ProviderPhone,''))),':',RTRIM(LTRIM(COALESCE(ProviderFax,'')))))),2)),
	   S_ContactHashDiff_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ProviderPhone,''))),':',RTRIM(LTRIM(COALESCE(ProviderFax,'')))))),2)),
	   H_Contact_RK_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ProviderPhone,''))),':',RTRIM(LTRIM(COALESCE(ProviderFax,'')))))),2)),
	   S_Contact_RK_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(VendorPhone,''))),':',RTRIM(LTRIM(COALESCE(VendorFax,'')))))),2)),
	   S_ContactHashDiff_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(VendorPhone,''))),':',RTRIM(LTRIM(COALESCE(VendorFax,'')))))),2)),
	   H_Contact_RK_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(VendorPhone,''))),':',RTRIM(LTRIM(COALESCE(VendorFax,'')))))),2)),	   
	   L_OECVendorLocation_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(VendorID,''))),':',RTRIM(LTRIM(COALESCE(VendorAddress ,''))),':',RTRIM(LTRIM(COALESCE(VendorCity,''))),':',RTRIM(LTRIM(COALESCE(VendorState,''))),':',RTRIM(LTRIM(COALESCE(VendorZip,'')))))),2)),
	   L_OECProviderContact_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriProviderID,''))),':',RTRIM(LTRIM(COALESCE(ProviderPhone ,''))),':',RTRIM(LTRIM(COALESCE(ProviderFax,'')))))),2)),
        L_OECVendorContact_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(VendorID,''))),':',RTRIM(LTRIM(COALESCE(VendorPhone ,''))),':',RTRIM(LTRIM(COALESCE(VendorFax,'')))))),2)),
	   H_Vendor_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(VendorID, ''))))), 2)),
	   S_Vendor_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(VendorID, ''))), ':',RTRIM(LTRIM(COALESCE(VendorName,'')))))),2)),
	   S_VendorHashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(VendorID, ''))), ':',RTRIM(LTRIM(COALESCE(VendorName,'')))))),2)),
	   Location_BK_Provider = CONVERT(VARCHAR(500),CONCAT(ProviderAddress,ProviderCity,ProviderState,ProviderZip)),
	   Location_BK_Vendor = CONVERT(VARCHAR(500),CONCAT(VendorAddress,VendorCity,VendorState,VendorZip)),
	   Contact_BK_Provider = CONVERT(VARCHAR(500),CONCAT(ProviderPhone,ProviderFax)),
	   Contact_BK_Vendor = CONVERT(VARCHAR(500),CONCAT(VendorPhone,VendorFax)),
	   S_Network_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(ProviderGroupName,'')))))),2)),
	   S_NetworkHashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(ProviderGroupName, ''))))), 2)),
	   L_OECProviderNetwork_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriNetworkID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriProviderID,''))),':',RTRIM(LTRIM(COALESCE(CentauriNetworkID ,'')))))),2)),
	   L_MemberOECProject_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, '')))))),2))



	   
GO
