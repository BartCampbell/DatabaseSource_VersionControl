SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	08/15/2016
-- Description:	updates the reference keys for the OEC staging data
-- Usage:			
--		  EXECUTE oec.spUpdateClaimDetail_112548
-- =============================================
CREATE PROC [oec].[spUpdateClaimDetail_112548] 
    @FileName VARCHAR(255),
    @ProjectID VARCHAR(20)
AS
     DECLARE @CurrentDate DATETIME = GETDATE(); 

	SET NOCOUNT ON;

	   UPDATE s 
	   SET H_OEC_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Client_ID, ''))), ':', RTRIM(LTRIM(COALESCE(p.CentauriOECProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_NPI, ''))), ':', RTRIM(LTRIM(COALESCE(Member_ID, ''))) ))), 2)),
		  OEC_BK = CONVERT(VARCHAR(100),CONCAT(Client_ID,p.CentauriOECProjectID,Provider_NPI,Member_ID)),
		  S_OECClaimDetail_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(Client_ID, ''))), ':', RTRIM(LTRIM(COALESCE(p.CentauriOECProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(Chase_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Member_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Claim_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Line, ''))), ':', RTRIM(LTRIM(COALESCE(Revenue_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Modifier_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Bill_Type_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Facility_Type_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_NPI, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Last_Name, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_First_Name, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Specialty, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Address, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_City, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_State, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Zip, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Phone, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Fax, ''))), ':', RTRIM(LTRIM(COALESCE(Employee_YN, ''))) ))), 2)),
		  HashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Client_ID, ''))), ':', RTRIM(LTRIM(COALESCE(p.CentauriOECProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(Chase_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Member_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Claim_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Line, ''))), ':', RTRIM(LTRIM(COALESCE(Revenue_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Modifier_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Bill_Type_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Facility_Type_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_NPI, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Last_Name, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_First_Name, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Specialty, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Address, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_City, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_State, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Zip, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Phone, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Fax, ''))), ':', RTRIM(LTRIM(COALESCE(Employee_YN, ''))) ))), 2)),
		  LoadDate = @CurrentDate ,
		  FileName = @FileName
	   FROM oec.ClaimLineDetail_112548 s 
	   INNER JOIN CHSDV.dbo.R_OECProject p ON s.Client_ID = p.CentauriClientID AND p.ProjectID = @ProjectID

GO
