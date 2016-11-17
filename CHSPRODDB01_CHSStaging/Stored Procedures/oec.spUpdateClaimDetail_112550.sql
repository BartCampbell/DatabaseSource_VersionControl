SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	08/15/2016
-- Description:	updates the reference keys for the OEC staging data
-- Usage:			
--		  EXECUTE oec.spUpdateClaimDetail_112550
-- =============================================
CREATE PROC [oec].[spUpdateClaimDetail_112550]
AS
     DECLARE @CurrentDate DATETIME = GETDATE(); 

	SET NOCOUNT ON;
	   --SELECT memberdob, CONVERT(VARCHAR(10),CONVERT(DATE,MemberDOB),112) FROM oec.AdvanceOECRaw_112550
    
    UPDATE oec.ClaimLineDetail_112550
    SET H_OEC_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Client_ID, ''))), ':', RTRIM(LTRIM(COALESCE('3', ''))), ':', RTRIM(LTRIM(COALESCE(Provider_NPI, ''))), ':', RTRIM(LTRIM(COALESCE(Member_ID, ''))) ))), 2)),
	   OEC_BK = CONVERT(VARCHAR(100),CONCAT(Client_ID,'3',Provider_NPI,Member_ID)),
	   S_OECClaimDetail_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE('OEC_112550_001_20160815_ClaimLineData.txt', ''))), ':', RTRIM(LTRIM(COALESCE(Client_ID, ''))), ':', RTRIM(LTRIM(COALESCE('3', ''))), ':', RTRIM(LTRIM(COALESCE(Chase_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Member_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Claim_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Line, ''))), ':', RTRIM(LTRIM(COALESCE(Revenue_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Modifier_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Bill_Type_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Facility_Type_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_NPI, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Last_Name, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_First_Name, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Specialty, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Address, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_City, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_State, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Zip, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Phone, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Fax, ''))), ':', RTRIM(LTRIM(COALESCE(Employee_YN, ''))) ))), 2)),
	   HashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Client_ID, ''))), ':', RTRIM(LTRIM(COALESCE('3', ''))), ':', RTRIM(LTRIM(COALESCE(Chase_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Member_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Claim_ID, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Line, ''))), ':', RTRIM(LTRIM(COALESCE(Revenue_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Service_Modifier_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Bill_Type_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Facility_Type_Code, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_NPI, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Last_Name, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_First_Name, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Specialty, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Address, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_City, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_State, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Zip, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Phone, ''))), ':', RTRIM(LTRIM(COALESCE(Provider_Office_Fax, ''))), ':', RTRIM(LTRIM(COALESCE(Employee_YN, ''))) ))), 2)),
	   LoadDate = @CurrentDate ,
	   FileName = 'OEC_112550_001_20160815_ClaimLineData.txt'

GO
