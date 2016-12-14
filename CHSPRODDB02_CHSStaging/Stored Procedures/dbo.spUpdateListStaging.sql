SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[spUpdateListStaging]
AS
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
	 --select * from ChaseListDVStage

     UPDATE s
	SET --H_Client_RK = c.ClientHashKey, 
	ClientName = c.ClientName
	FROM  [CHSStaging].[dbo].[ChaseListDVStage]  s 
	     INNER JOIN CHSDV.dbo.R_Client c ON s.ClientID = c.CentauriClientID


     UPDATE s
	SET s.CentauriProviderID = b.CentuariProviderID
	FROM  [CHSStaging].[dbo].[ChaseListDVStage]  s 
	     INNER JOIN dbo.Wellcare_OEC_112547_003_20161121 b
		 ON b.Chase_ID = s.ChaseID




--select * FROM 		 adv_112547_001.dbo.tblProject
	
	--INSERT INTO CHSDV.dbo.R_OECProject
	--        ( CentauriClientID ,
	--          ProjectID ,
	--          ProjectName ,
	--          StartDate ,
	--          EndDate
	--        )
	--VALUES  ( 112547 , -- CentauriClientID - int
	--          '005' , -- ProjectID - varchar(20)
	--          'Chase List 3' , -- ProjectName - varchar(100)
	--          GETDATE()-7 , -- StartDate - datetime
	--          NULL  -- EndDate - datetime
	--        )


			--SELECT * FROM CHSDV.dbo.R_OECProject


	UPDATE s
	SET s.H_OECProject_RK = r.OECProjectHashKey, s.OECProject_BK = r.CentauriOECProjectID, s.OECProjectID = r.ProjectID, s.OECProjectName = r.ProjectName
		FROM  [CHSStaging].[dbo].[ChaseListDVStage]  s 
	     INNER JOIN CHSDV.dbo.R_OECProject r ON s.ClientID = r.CentauriClientID AND  r.ProjectID='005'


    UPDATE  [CHSStaging].[dbo].[ChaseListDVStage] 
    SET ProviderOfficePhone = REPLACE(REPLACE(REPLACE(REPLACE(ProviderOfficePhone,'-',''),'(',''),')',''),' ',''),
	   ProviderOfficeFax = REPLACE(REPLACE(REPLACE(REPLACE(ProviderOfficeFax,'-',''),'(',''),')',''),' ',''),
	   VendorPhone = REPLACE(REPLACE(REPLACE(REPLACE(VendorPhone,'-',''),'(',''),')',''),' ',''),
	   VendorFax = REPLACE(REPLACE(REPLACE(REPLACE(VendorFax,'-',''),'(',''),')',''),' ',''),
	   MemberDOB = CONVERT(VARCHAR(10),CONVERT(DATE,MemberDOB),112)

	   DECLARE @FileName VARCHAR(100)

	   SET @FileName = 'OEC_112547_003_20161121.txt'
	
	   
	UPDATE  [CHSStaging].[dbo].[ChaseListDVStage]  SET LoadDate= '2016-11-30'
	

	
	    UPDATE  [CHSStaging].[dbo].[ChaseListDVStage] 
    SET
	   H_OEC_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(DOSFromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOSToDate, ''))) ))), 2)),
	   H_Specialty_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(ProviderSpecialty, ''))))), 2)),
	   S_OECDetail_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberHICN, ''))), ':', RTRIM(LTRIM(COALESCE(DiagnosisCode, ''))), ':', RTRIM(LTRIM(COALESCE(ICD9ICD10Ind, ''))), ':', RTRIM(LTRIM(COALESCE(DOSFromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOSToDate, ''))), ':', RTRIM(LTRIM(COALESCE(CONTRACTCODE, ''))), ':', RTRIM(LTRIM(COALESCE(ClaimID, ''))), ':', RTRIM(LTRIM(COALESCE(ChaseID, ''))), ':', RTRIM(LTRIM(COALESCE(MedicalRecordID, ''))), ':', RTRIM(LTRIM(COALESCE(ChasePriority, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderRelationsRep, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderSpecialty, ''))) ))), 2)),
	   S_OECDetail_HashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberHICN, ''))), ':', RTRIM(LTRIM(COALESCE(DiagnosisCode, ''))), ':', RTRIM(LTRIM(COALESCE(ICD9ICD10Ind, ''))), ':', RTRIM(LTRIM(COALESCE(DOSFromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOSToDate, ''))), ':', RTRIM(LTRIM(COALESCE(CONTRACTCODE, ''))), ':', RTRIM(LTRIM(COALESCE(ClaimID, ''))), ':', RTRIM(LTRIM(COALESCE(ChaseID, ''))), ':', RTRIM(LTRIM(COALESCE(MedicalRecordID, ''))), ':', RTRIM(LTRIM(COALESCE(ChasePriority, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderRelationsRep, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderSpecialty, '')))))), 2)),
	   S_MemberDemo_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName,''))),':',RTRIM(LTRIM(COALESCE(LoadDate,''))),':',RTRIM(LTRIM(COALESCE(CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(MemberLastName,''))),':',RTRIM(LTRIM(COALESCE(MemberFirstName,''))),':',RTRIM(LTRIM(COALESCE(MemberDOB,''))),':',RTRIM(LTRIM(COALESCE(MemberGender,'')))  ))),2))  ,

	   S_MemberDemoHashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(MemberLastName,''))),':',RTRIM(LTRIM(COALESCE(MemberFirstName,''))),':',RTRIM(LTRIM(COALESCE(MemberDOB,''))),':',RTRIM(LTRIM(COALESCE(MemberGender,'')))  ))),2)),
	   S_ProviderDemo_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderNPI, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderLastName, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderFirstName, '')))))), 2)),
	   S_ProviderDemoHashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderNPI, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderLastName, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderFirstName, '')))))), 2)),
	   L_MemberOEC_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(DOSFromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOSToDate, '')))))), 2)),
	   L_MemberProvider_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriProviderID, '')))))), 2)),
	   L_OECProviderLocation_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(DOSFromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOSToDate, ''))),':',RTRIM(LTRIM(COALESCE(CentauriProviderID,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeAddress ,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeCity,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeState,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeZIP,'')))))),2)),
	   L_ProviderSpecialty_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderSpecialty, '')))))), 2)),
	   S_MemberHICN_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberHICN, '')))))), 2)),
	   S_MemberHICN_HashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberHICN, '')))))), 2)),
	   OEC_BK = CONVERT(VARCHAR(100),CONCAT(ClientID,OECProject_BK,ProviderID,MemberID,DOSFromDate,DOSToDate)),
	   L_OECProjectOEC_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(DOSFromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOSToDate, ''))) ))), 2)),
	   S_OECProject_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(OECProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProjectName, ''))) ))), 2)),
	   S_OECProject_HashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(OECProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProjectName, ''))) ))), 2)),
	   S_Location_RK_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(ProviderOfficeAddress,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeCity,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeState,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeZIP,'')))))),2)),
	   S_LocationHashDiff_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ProviderOfficeAddress,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeCity,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeState,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeZIP,'')))))),2)),
	   H_Location_RK_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ProviderOfficeAddress,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeCity,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeState,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeZIP,'')))))),2)),
	   S_Location_RK_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(VendorAddress,''))),':',RTRIM(LTRIM(COALESCE(VendorCity,''))),':',RTRIM(LTRIM(COALESCE(VendorState,''))),':',RTRIM(LTRIM(COALESCE(VendorZip,'')))))),2)),
	   S_LocationHashDiff_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(VendorAddress,''))),':',RTRIM(LTRIM(COALESCE(VendorCity,''))),':',RTRIM(LTRIM(COALESCE(VendorState,''))),':',RTRIM(LTRIM(COALESCE(VendorZip,'')))))),2)),
	   H_Location_RK_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(VendorAddress,''))),':',RTRIM(LTRIM(COALESCE(VendorCity,''))),':',RTRIM(LTRIM(COALESCE(VendorState,''))),':',RTRIM(LTRIM(COALESCE(VendorZip,'')))))),2)),
	   S_Contact_RK_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(ProviderOfficePhone,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeFax,'')))))),2)),
	   S_ContactHashDiff_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ProviderOfficePhone,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeFax,'')))))),2)),
	   H_Contact_RK_Provider = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ProviderOfficePhone,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeFax,'')))))),2)),
	   S_Contact_RK_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(VendorPhone,''))),':',RTRIM(LTRIM(COALESCE(VendorFax,'')))))),2)),
	   S_ContactHashDiff_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(VendorPhone,''))),':',RTRIM(LTRIM(COALESCE(VendorFax,'')))))),2)),
	   H_Contact_RK_Vendor = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(VendorPhone,''))),':',RTRIM(LTRIM(COALESCE(VendorFax,'')))))),2)),	   
	   L_OECVendorLocation_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(DOSFromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOSToDate, ''))),':',RTRIM(LTRIM(COALESCE(VendorID,''))),':',RTRIM(LTRIM(COALESCE(VendorAddress ,''))),':',RTRIM(LTRIM(COALESCE(VendorCity,''))),':',RTRIM(LTRIM(COALESCE(VendorState,''))),':',RTRIM(LTRIM(COALESCE(VendorZip,'')))))),2)),
	   L_OECProviderContact_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(DOSFromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOSToDate, ''))),':',RTRIM(LTRIM(COALESCE(CentauriProviderID,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficePhone ,''))),':',RTRIM(LTRIM(COALESCE(ProviderOfficeFax,'')))))),2)),
        L_OECVendorContact_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(ProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(DOSFromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOSToDate, ''))),':',RTRIM(LTRIM(COALESCE(VendorID,''))),':',RTRIM(LTRIM(COALESCE(VendorPhone ,''))),':',RTRIM(LTRIM(COALESCE(VendorFax,'')))))),2)),
	   H_Vendor_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(VendorID, ''))))), 2)),
	   S_Vendor_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(VendorName,'')))))),2)),
	   S_VendorHashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(VendorName, ''))))), 2)),
	   Location_BK_Provider = CONVERT(VARCHAR(500),CONCAT(ProviderOfficeAddress,ProviderOfficeCity,ProviderOfficeState,ProviderOfficeZIP)),
	   Location_BK_Vendor = CONVERT(VARCHAR(500),CONCAT(VendorAddress,VendorCity,VendorState,VendorZip)),
	   Contact_BK_Provider = CONVERT(VARCHAR(500),CONCAT(ProviderOfficePhone,ProviderOfficeFax)),
	   Contact_BK_Vendor = CONVERT(VARCHAR(500),CONCAT(VendorPhone,VendorFax)),
	   S_Network_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(ProviderGroupName,'')))))),2)),
	   S_NetworkHashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(ProviderGroupName, ''))))), 2)),
	   L_OECProviderNetwork_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(ClientID, ''))), ':', RTRIM(LTRIM(COALESCE(OECProject_BK, ''))), ':', RTRIM(LTRIM(COALESCE(CentauriNetworkID, ''))), ':', RTRIM(LTRIM(COALESCE(MemberID, ''))), ':', RTRIM(LTRIM(COALESCE(DOSFromDate, ''))), ':', RTRIM(LTRIM(COALESCE(DOSToDate, ''))),':',RTRIM(LTRIM(COALESCE(CentauriProviderID,''))),':',RTRIM(LTRIM(COALESCE(CentauriNetworkID ,'')))))),2))


GO
