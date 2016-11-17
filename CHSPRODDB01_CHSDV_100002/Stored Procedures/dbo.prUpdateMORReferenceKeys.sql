SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	07/25/2016
-- Description:	Updates the reference keys in the MOR staging tables
-- =============================================
CREATE PROCEDURE [dbo].[prUpdateMORReferenceKeys]
    @RecordSource VARCHAR(256)
AS
    BEGIN
	
        DECLARE @RK VARCHAR(32) ,
            @RecordTypeCode VARCHAR(1) ,
            @ContractNumber VARCHAR(5) ,
            @RunDate VARCHAR(8) ,
            @PaymentYearAndMonth VARCHAR(6);
        DECLARE @CurrentDate DATETIME = GETDATE();

        SET NOCOUNT ON;


        SELECT  @RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                        UPPER(CONCAT(RTRIM(LTRIM(COALESCE(RecordTypeCode, ''))), ':', 
													    RTRIM(LTRIM(COALESCE(ContractNumber, ''))), ':', 
													    RTRIM(LTRIM(COALESCE(RunDate, ''))), ':',
                                                                     RTRIM(LTRIM(COALESCE(PaymentYearandMonth, '')))))), 2)) ,
                @RecordTypeCode = RecordTypeCode ,
                @ContractNumber = ContractNumber ,
                @RunDate = RunDate ,
                @PaymentYearAndMonth = PaymentYearandMonth
        FROM    CHSStaging.mor.MOR_Header_Stage;


        UPDATE  CHSStaging.mor.MOR_Header_Stage
        SET     H_MOR_Header_RK = @RK ,
                LoadDate = @CurrentDate ,
                RecordSource = @RecordSource;

        UPDATE  CHSStaging.mor.MOR_Trailer_Stage
        SET     HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                             UPPER(CONCAT(RTRIM(LTRIM(COALESCE(RecordTypeCode, ''))), ':',
                                                                          RTRIM(LTRIM(COALESCE(ContractNumber, ''))), ':',
                                                                          RTRIM(LTRIM(COALESCE(TotalRecordCount, '')))))), 2)) ,
                S_MOR_Trailer_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                     UPPER(CONCAT(RTRIM(LTRIM(COALESCE(RecordTypeCode, ''))), ':',
                                                                                  RTRIM(LTRIM(COALESCE(ContractNumber, ''))), ':',
                                                                                  RTRIM(LTRIM(COALESCE(TotalRecordCount, ''))), ':',
                                                                                  RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',
                                                                                  RTRIM(LTRIM(COALESCE(RecordSource, '')))))), 2)) ,
                H_MOR_Header_RK = @RK ,
                LoadDate = @CurrentDate ,
                RecordSource = @RecordSource;


        UPDATE  CHSStaging.mor.MOR_ARecord_Stage
        SET     H_MOR_Header_RK = @RK ,
			 LS_MOR_ARecord_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                      UPPER(LTRIM(RTRIM(COALESCE(@RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(@ContractNumber, '')))
															 + LTRIM(RTRIM(COALESCE(@RunDate, ''))) + LTRIM(RTRIM(COALESCE(@PaymentYearAndMonth, '')))
															 + LTRIM(RTRIM(COALESCE(RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(HICN, '')))
                                                                            + LTRIM(RTRIM(COALESCE(LastName, ''))) + LTRIM(RTRIM(COALESCE(FirstName, '')))
                                                                            + LTRIM(RTRIM(COALESCE(MI, ''))) + LTRIM(RTRIM(COALESCE(DOB, '')))
                                                                            + LTRIM(RTRIM(COALESCE(Gender, ''))) + LTRIM(RTRIM(COALESCE(SSN, '')))
                                                                            + LTRIM(RTRIM(COALESCE(F034, ''))) + LTRIM(RTRIM(COALESCE(F3544, '')))
                                                                            + LTRIM(RTRIM(COALESCE(F4554, ''))) + LTRIM(RTRIM(COALESCE(F5559, '')))
                                                                            + LTRIM(RTRIM(COALESCE(F6064, ''))) + LTRIM(RTRIM(COALESCE(F6569, '')))
                                                                            + LTRIM(RTRIM(COALESCE(F7074, ''))) + LTRIM(RTRIM(COALESCE(F7579, '')))
                                                                            + LTRIM(RTRIM(COALESCE(F8084, ''))) + LTRIM(RTRIM(COALESCE(F8589, '')))
                                                                            + LTRIM(RTRIM(COALESCE(F9094, ''))) + LTRIM(RTRIM(COALESCE(F95GT, '')))
                                                                            + LTRIM(RTRIM(COALESCE(M034, ''))) + LTRIM(RTRIM(COALESCE(M3544, '')))
                                                                            + LTRIM(RTRIM(COALESCE(M4554, ''))) + LTRIM(RTRIM(COALESCE(M5559, '')))
                                                                            + LTRIM(RTRIM(COALESCE(M6064, ''))) + LTRIM(RTRIM(COALESCE(M6569, '')))
                                                                            + LTRIM(RTRIM(COALESCE(M7074, ''))) + LTRIM(RTRIM(COALESCE(M7579, '')))
                                                                            + LTRIM(RTRIM(COALESCE(M8084, ''))) + LTRIM(RTRIM(COALESCE(M8589, '')))
                                                                            + LTRIM(RTRIM(COALESCE(M9094, ''))) + LTRIM(RTRIM(COALESCE(M95GT, '')))
                                                                            + LTRIM(RTRIM(COALESCE(MedicaidFemaleDisabled, '')))
                                                                            + LTRIM(RTRIM(COALESCE(MedicaidFemaleAged, '')))
                                                                            + LTRIM(RTRIM(COALESCE(MedicaidMaleDisabled, '')))
                                                                            + LTRIM(RTRIM(COALESCE(MedicaidMaleAged, '')))
                                                                            + LTRIM(RTRIM(COALESCE(OriginallyDisabledFemale, '')))
                                                                            + LTRIM(RTRIM(COALESCE(OriginallyDisabledMale, ''))) + LTRIM(RTRIM(COALESCE(HCC1, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC2, ''))) + LTRIM(RTRIM(COALESCE(HCC5, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC7, ''))) + LTRIM(RTRIM(COALESCE(HCC8, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC9, ''))) + LTRIM(RTRIM(COALESCE(HCC10, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC15, ''))) + LTRIM(RTRIM(COALESCE(HCC16, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC17, ''))) + LTRIM(RTRIM(COALESCE(HCC18, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC19, ''))) + LTRIM(RTRIM(COALESCE(HCC21, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC25, ''))) + LTRIM(RTRIM(COALESCE(HCC26, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC27, ''))) + LTRIM(RTRIM(COALESCE(HCC31, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC32, ''))) + LTRIM(RTRIM(COALESCE(HCC33, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC37, ''))) + LTRIM(RTRIM(COALESCE(HCC38, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC44, ''))) + LTRIM(RTRIM(COALESCE(HCC45, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC51, ''))) + LTRIM(RTRIM(COALESCE(HCC52, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC54, ''))) + LTRIM(RTRIM(COALESCE(HCC55, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC67, ''))) + LTRIM(RTRIM(COALESCE(HCC68, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC69, ''))) + LTRIM(RTRIM(COALESCE(HCC70, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC71, ''))) + LTRIM(RTRIM(COALESCE(HCC72, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC73, ''))) + LTRIM(RTRIM(COALESCE(HCC74, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC75, ''))) + LTRIM(RTRIM(COALESCE(HCC77, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC78, ''))) + LTRIM(RTRIM(COALESCE(HCC79, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC80, ''))) + LTRIM(RTRIM(COALESCE(HCC81, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC82, ''))) + LTRIM(RTRIM(COALESCE(HCC83, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC92, ''))) + LTRIM(RTRIM(COALESCE(HCC95, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC96, ''))) + LTRIM(RTRIM(COALESCE(HCC100, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC101, ''))) + LTRIM(RTRIM(COALESCE(HCC104, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC105, ''))) + LTRIM(RTRIM(COALESCE(HCC107, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC108, ''))) + LTRIM(RTRIM(COALESCE(HCC111, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC112, ''))) + LTRIM(RTRIM(COALESCE(HCC119, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC130, ''))) + LTRIM(RTRIM(COALESCE(HCC131, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC132, ''))) + LTRIM(RTRIM(COALESCE(HCC148, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC149, ''))) + LTRIM(RTRIM(COALESCE(HCC150, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC154, ''))) + LTRIM(RTRIM(COALESCE(HCC155, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC157, ''))) + LTRIM(RTRIM(COALESCE(HCC158, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC161, ''))) + LTRIM(RTRIM(COALESCE(HCC164, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC174, ''))) + LTRIM(RTRIM(COALESCE(HCC176, '')))
                                                                            + LTRIM(RTRIM(COALESCE(HCC177, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC5, '')))
                                                                            + LTRIM(RTRIM(COALESCE(DD_HCC44, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC51, '')))
                                                                            + LTRIM(RTRIM(COALESCE(DD_HCC52, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC107, '')))
                                                                            + LTRIM(RTRIM(COALESCE(INT1, ''))) + LTRIM(RTRIM(COALESCE(INT2, '')))
                                                                            + LTRIM(RTRIM(COALESCE(INT3, ''))) + LTRIM(RTRIM(COALESCE(INT4, '')))
                                                                            + LTRIM(RTRIM(COALESCE(INT5, ''))) + LTRIM(RTRIM(COALESCE(INT6, ''))))), 2)) ,
                HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                             UPPER(LTRIM(RTRIM(COALESCE(@RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(@ContractNumber, '')))
													  + LTRIM(RTRIM(COALESCE(@RunDate, ''))) + LTRIM(RTRIM(COALESCE(@PaymentYearAndMonth, '')))
													  + LTRIM(RTRIM(COALESCE(RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(HICN, '')))
                                                                   + LTRIM(RTRIM(COALESCE(LastName, ''))) + LTRIM(RTRIM(COALESCE(FirstName, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MI, ''))) + LTRIM(RTRIM(COALESCE(DOB, '')))
                                                                   + LTRIM(RTRIM(COALESCE(Gender, ''))) + LTRIM(RTRIM(COALESCE(SSN, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F034, ''))) + LTRIM(RTRIM(COALESCE(F3544, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F4554, ''))) + LTRIM(RTRIM(COALESCE(F5559, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F6064, ''))) + LTRIM(RTRIM(COALESCE(F6569, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F7074, ''))) + LTRIM(RTRIM(COALESCE(F7579, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F8084, ''))) + LTRIM(RTRIM(COALESCE(F8589, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F9094, ''))) + LTRIM(RTRIM(COALESCE(F95GT, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M034, ''))) + LTRIM(RTRIM(COALESCE(M3544, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M4554, ''))) + LTRIM(RTRIM(COALESCE(M5559, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M6064, ''))) + LTRIM(RTRIM(COALESCE(M6569, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M7074, ''))) + LTRIM(RTRIM(COALESCE(M7579, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M8084, ''))) + LTRIM(RTRIM(COALESCE(M8589, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M9094, ''))) + LTRIM(RTRIM(COALESCE(M95GT, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MedicaidFemaleDisabled, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MedicaidFemaleAged, ''))) 
													  + LTRIM(RTRIM(COALESCE(MedicaidMaleDisabled, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MedicaidMaleAged, '')))
                                                                   + LTRIM(RTRIM(COALESCE(OriginallyDisabledFemale, '')))
                                                                   + LTRIM(RTRIM(COALESCE(OriginallyDisabledMale, ''))) + LTRIM(RTRIM(COALESCE(HCC1, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC2, ''))) + LTRIM(RTRIM(COALESCE(HCC5, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC7, ''))) + LTRIM(RTRIM(COALESCE(HCC8, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC9, ''))) + LTRIM(RTRIM(COALESCE(HCC10, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC15, ''))) + LTRIM(RTRIM(COALESCE(HCC16, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC17, ''))) + LTRIM(RTRIM(COALESCE(HCC18, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC19, ''))) + LTRIM(RTRIM(COALESCE(HCC21, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC25, ''))) + LTRIM(RTRIM(COALESCE(HCC26, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC27, ''))) + LTRIM(RTRIM(COALESCE(HCC31, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC32, ''))) + LTRIM(RTRIM(COALESCE(HCC33, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC37, ''))) + LTRIM(RTRIM(COALESCE(HCC38, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC44, ''))) + LTRIM(RTRIM(COALESCE(HCC45, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC51, ''))) + LTRIM(RTRIM(COALESCE(HCC52, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC54, ''))) + LTRIM(RTRIM(COALESCE(HCC55, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC67, ''))) + LTRIM(RTRIM(COALESCE(HCC68, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC69, ''))) + LTRIM(RTRIM(COALESCE(HCC70, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC71, ''))) + LTRIM(RTRIM(COALESCE(HCC72, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC73, ''))) + LTRIM(RTRIM(COALESCE(HCC74, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC75, ''))) + LTRIM(RTRIM(COALESCE(HCC77, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC78, ''))) + LTRIM(RTRIM(COALESCE(HCC79, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC80, ''))) + LTRIM(RTRIM(COALESCE(HCC81, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC82, ''))) + LTRIM(RTRIM(COALESCE(HCC83, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC92, ''))) + LTRIM(RTRIM(COALESCE(HCC95, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC96, ''))) + LTRIM(RTRIM(COALESCE(HCC100, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC101, ''))) + LTRIM(RTRIM(COALESCE(HCC104, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC105, ''))) + LTRIM(RTRIM(COALESCE(HCC107, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC108, ''))) + LTRIM(RTRIM(COALESCE(HCC111, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC112, ''))) + LTRIM(RTRIM(COALESCE(HCC119, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC130, ''))) + LTRIM(RTRIM(COALESCE(HCC131, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC132, ''))) + LTRIM(RTRIM(COALESCE(HCC148, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC149, ''))) + LTRIM(RTRIM(COALESCE(HCC150, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC154, ''))) + LTRIM(RTRIM(COALESCE(HCC155, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC157, ''))) + LTRIM(RTRIM(COALESCE(HCC158, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC161, ''))) + LTRIM(RTRIM(COALESCE(HCC164, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC174, ''))) + LTRIM(RTRIM(COALESCE(HCC176, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC177, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC5, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC44, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC51, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC52, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC107, '')))
                                                                   + LTRIM(RTRIM(COALESCE(INT1, ''))) + LTRIM(RTRIM(COALESCE(INT2, '')))
                                                                   + LTRIM(RTRIM(COALESCE(INT3, ''))) + LTRIM(RTRIM(COALESCE(INT4, '')))
                                                                   + LTRIM(RTRIM(COALESCE(INT5, ''))) + LTRIM(RTRIM(COALESCE(INT6, '')))
                                                                   + LTRIM(RTRIM(COALESCE(LoadDate, ''))) + LTRIM(RTRIM(COALESCE(RecordSource, ''))))), 2)) ,
                RecordSource = @RecordSource ,
                LoadDate = @CurrentDate ,
			 S_MemberDemo_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(FirstName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LastName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(MI, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(Gender, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(DOB, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(RecordSource, '')))))), 2)),
			 S_MemberDemo_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(FirstName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LastName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(MI, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(Gender, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(DOB, '')))))), 2)),
			 S_MemberHICN_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(HICN, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(RecordSource, '')))))), 2)),
			 S_MemberHICN_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(HICN, '')))))), 2)),
                L_Member_MOR_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@RecordTypeCode, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@ContractNumber, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@RunDate, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@PaymentYearAndMonth, '')))))), 2));


        UPDATE  CHSStaging.mor.MOR_BRecord_Stage
        SET     H_MOR_Header_RK = @RK ,
			 LS_MOR_BRecord_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                   UPPER(LTRIM(RTRIM(COALESCE(@RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(@ContractNumber, '')))
														   + LTRIM(RTRIM(COALESCE(@RunDate, ''))) + LTRIM(RTRIM(COALESCE(@PaymentYearAndMonth, '')))
														   + LTRIM(RTRIM(COALESCE(RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(HICN, '')))
                                                                         + LTRIM(RTRIM(COALESCE(LastName, ''))) + LTRIM(RTRIM(COALESCE(FirstName, '')))
                                                                         + LTRIM(RTRIM(COALESCE(MI, ''))) + LTRIM(RTRIM(COALESCE(DOB, '')))
                                                                         + LTRIM(RTRIM(COALESCE(Gender, ''))) + LTRIM(RTRIM(COALESCE(SSN, '')))
                                                                         + LTRIM(RTRIM(COALESCE(ESRD, ''))) + LTRIM(RTRIM(COALESCE(F034, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F3544, ''))) + LTRIM(RTRIM(COALESCE(F4554, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F5559, ''))) + LTRIM(RTRIM(COALESCE(F6064, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F6569, ''))) + LTRIM(RTRIM(COALESCE(F7074, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F7579, ''))) + LTRIM(RTRIM(COALESCE(F8084, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F8589, ''))) + LTRIM(RTRIM(COALESCE(F9094, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F95GT, ''))) + LTRIM(RTRIM(COALESCE(M034, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M3544, ''))) + LTRIM(RTRIM(COALESCE(M4554, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M5559, ''))) + LTRIM(RTRIM(COALESCE(M6064, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M6569, ''))) + LTRIM(RTRIM(COALESCE(M7074, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M7579, ''))) + LTRIM(RTRIM(COALESCE(M8084, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M8589, ''))) + LTRIM(RTRIM(COALESCE(M9094, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M95GT, ''))) + LTRIM(RTRIM(COALESCE(MedicaidFemaleDisabled, '')))
                                                                         + LTRIM(RTRIM(COALESCE(MedicaidFemaleAged, '')))
                                                                         + LTRIM(RTRIM(COALESCE(MedicaidMaleDisabled, '')))
                                                                         + LTRIM(RTRIM(COALESCE(MedicaidMaleAged, '')))
                                                                         + LTRIM(RTRIM(COALESCE(OriginallyDisabledFemale, '')))
                                                                         + LTRIM(RTRIM(COALESCE(OriginallyDisabledMale, ''))) + LTRIM(RTRIM(COALESCE(HCC001, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC002, ''))) + LTRIM(RTRIM(COALESCE(HCC006, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC008, ''))) + LTRIM(RTRIM(COALESCE(HCC009, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC010, ''))) + LTRIM(RTRIM(COALESCE(HCC011, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC012, ''))) + LTRIM(RTRIM(COALESCE(HCC017, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC018, ''))) + LTRIM(RTRIM(COALESCE(HCC019, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC021, ''))) + LTRIM(RTRIM(COALESCE(HCC022, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC023, ''))) + LTRIM(RTRIM(COALESCE(HCC027, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC028, ''))) + LTRIM(RTRIM(COALESCE(HCC029, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC033, ''))) + LTRIM(RTRIM(COALESCE(HCC034, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC035, ''))) + LTRIM(RTRIM(COALESCE(HCC039, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC040, ''))) + LTRIM(RTRIM(COALESCE(HCC046, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC047, ''))) + LTRIM(RTRIM(COALESCE(HCC048, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC051, ''))) + LTRIM(RTRIM(COALESCE(HCC052, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC054, ''))) + LTRIM(RTRIM(COALESCE(HCC055, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC057, ''))) + LTRIM(RTRIM(COALESCE(HCC058, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC070, ''))) + LTRIM(RTRIM(COALESCE(HCC071, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC072, ''))) + LTRIM(RTRIM(COALESCE(HCC073, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC074, ''))) + LTRIM(RTRIM(COALESCE(HCC075, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC076, ''))) + LTRIM(RTRIM(COALESCE(HCC077, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC078, ''))) + LTRIM(RTRIM(COALESCE(HCC079, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC080, ''))) + LTRIM(RTRIM(COALESCE(HCC082, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC083, ''))) + LTRIM(RTRIM(COALESCE(HCC084, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC085, ''))) + LTRIM(RTRIM(COALESCE(HCC086, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC087, ''))) + LTRIM(RTRIM(COALESCE(HCC088, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC096, ''))) + LTRIM(RTRIM(COALESCE(HCC099, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC100, ''))) + LTRIM(RTRIM(COALESCE(HCC103, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC104, ''))) + LTRIM(RTRIM(COALESCE(HCC106, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC107, ''))) + LTRIM(RTRIM(COALESCE(HCC108, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC110, ''))) + LTRIM(RTRIM(COALESCE(HCC111, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC112, ''))) + LTRIM(RTRIM(COALESCE(HCC114, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC115, ''))) + LTRIM(RTRIM(COALESCE(HCC122, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC124, ''))) + LTRIM(RTRIM(COALESCE(HCC134, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC135, ''))) + LTRIM(RTRIM(COALESCE(HCC136, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC137, ''))) + LTRIM(RTRIM(COALESCE(HCC138, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC139, ''))) + LTRIM(RTRIM(COALESCE(HCC140, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC141, ''))) + LTRIM(RTRIM(COALESCE(HCC157, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC158, ''))) + LTRIM(RTRIM(COALESCE(HCC159, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC160, ''))) + LTRIM(RTRIM(COALESCE(HCC161, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC162, ''))) + LTRIM(RTRIM(COALESCE(HCC166, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC167, ''))) + LTRIM(RTRIM(COALESCE(HCC169, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC170, ''))) + LTRIM(RTRIM(COALESCE(HCC173, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC176, ''))) + LTRIM(RTRIM(COALESCE(HCC186, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC188, ''))) + LTRIM(RTRIM(COALESCE(HCC189, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC006, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC034, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC046, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC054, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC055, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC110, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC176, ''))) + LTRIM(RTRIM(COALESCE(CANCER_IMMUNE, '')))
                                                                         + LTRIM(RTRIM(COALESCE(CHF_COPD, ''))) + LTRIM(RTRIM(COALESCE(CHF_RENAL, '')))
                                                                         + LTRIM(RTRIM(COALESCE(COPD_CARD_RESP_FAIL, ''))) 
														   + LTRIM(RTRIM(COALESCE(DIABETES_CHF, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SEPSIS_CARD_RESP_FAIL, ''))) + LTRIM(RTRIM(COALESCE(MEDICAID, '')))
                                                                         + LTRIM(RTRIM(COALESCE(Orginaly_Disabled, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC039, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC077, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC085, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC161, '')))
                                                                         + LTRIM(RTRIM(COALESCE(ART_OPENINGS_PRESSURE_ULCER, '')))
                                                                         + LTRIM(RTRIM(COALESCE(ASP_SPEC_BACT_PNEUM_PRES_ULC, '')))
                                                                         + LTRIM(RTRIM(COALESCE(COPD_ASP_SPEC_BACT_PNEUM, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DISABLED_PRESSURE_ULCER, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_CHF, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_COPD, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_SEIZURES, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SEPSIS_ARTIF_OPENINGS, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SEPSIS_ASP_SPEC_BACT_PNEUM, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SEPSIS_PRESSURE_ULCER, ''))))), 2)) ,
                HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                             UPPER(LTRIM(RTRIM(COALESCE(@RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(@ContractNumber, '')))
													  + LTRIM(RTRIM(COALESCE(@RunDate, ''))) + LTRIM(RTRIM(COALESCE(@PaymentYearAndMonth, '')))
													  + LTRIM(RTRIM(COALESCE(RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(HICN, '')))
                                                                   + LTRIM(RTRIM(COALESCE(LastName, ''))) + LTRIM(RTRIM(COALESCE(FirstName, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MI, ''))) + LTRIM(RTRIM(COALESCE(DOB, '')))
                                                                   + LTRIM(RTRIM(COALESCE(Gender, ''))) + LTRIM(RTRIM(COALESCE(SSN, '')))
                                                                   + LTRIM(RTRIM(COALESCE(ESRD, ''))) + LTRIM(RTRIM(COALESCE(F034, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F3544, ''))) + LTRIM(RTRIM(COALESCE(F4554, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F5559, ''))) + LTRIM(RTRIM(COALESCE(F6064, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F6569, ''))) + LTRIM(RTRIM(COALESCE(F7074, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F7579, ''))) + LTRIM(RTRIM(COALESCE(F8084, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F8589, ''))) + LTRIM(RTRIM(COALESCE(F9094, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F95GT, ''))) + LTRIM(RTRIM(COALESCE(M034, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M3544, ''))) + LTRIM(RTRIM(COALESCE(M4554, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M5559, ''))) + LTRIM(RTRIM(COALESCE(M6064, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M6569, ''))) + LTRIM(RTRIM(COALESCE(M7074, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M7579, ''))) + LTRIM(RTRIM(COALESCE(M8084, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M8589, ''))) + LTRIM(RTRIM(COALESCE(M9094, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M95GT, ''))) + LTRIM(RTRIM(COALESCE(MedicaidFemaleDisabled, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MedicaidFemaleAged, ''))) 
													  + LTRIM(RTRIM(COALESCE(MedicaidMaleDisabled, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MedicaidMaleAged, '')))
                                                                   + LTRIM(RTRIM(COALESCE(OriginallyDisabledFemale, '')))
                                                                   + LTRIM(RTRIM(COALESCE(OriginallyDisabledMale, ''))) + LTRIM(RTRIM(COALESCE(HCC001, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC002, ''))) + LTRIM(RTRIM(COALESCE(HCC006, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC008, ''))) + LTRIM(RTRIM(COALESCE(HCC009, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC010, ''))) + LTRIM(RTRIM(COALESCE(HCC011, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC012, ''))) + LTRIM(RTRIM(COALESCE(HCC017, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC018, ''))) + LTRIM(RTRIM(COALESCE(HCC019, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC021, ''))) + LTRIM(RTRIM(COALESCE(HCC022, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC023, ''))) + LTRIM(RTRIM(COALESCE(HCC027, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC028, ''))) + LTRIM(RTRIM(COALESCE(HCC029, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC033, ''))) + LTRIM(RTRIM(COALESCE(HCC034, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC035, ''))) + LTRIM(RTRIM(COALESCE(HCC039, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC040, ''))) + LTRIM(RTRIM(COALESCE(HCC046, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC047, ''))) + LTRIM(RTRIM(COALESCE(HCC048, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC051, ''))) + LTRIM(RTRIM(COALESCE(HCC052, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC054, ''))) + LTRIM(RTRIM(COALESCE(HCC055, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC057, ''))) + LTRIM(RTRIM(COALESCE(HCC058, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC070, ''))) + LTRIM(RTRIM(COALESCE(HCC071, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC072, ''))) + LTRIM(RTRIM(COALESCE(HCC073, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC074, ''))) + LTRIM(RTRIM(COALESCE(HCC075, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC076, ''))) + LTRIM(RTRIM(COALESCE(HCC077, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC078, ''))) + LTRIM(RTRIM(COALESCE(HCC079, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC080, ''))) + LTRIM(RTRIM(COALESCE(HCC082, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC083, ''))) + LTRIM(RTRIM(COALESCE(HCC084, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC085, ''))) + LTRIM(RTRIM(COALESCE(HCC086, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC087, ''))) + LTRIM(RTRIM(COALESCE(HCC088, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC096, ''))) + LTRIM(RTRIM(COALESCE(HCC099, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC100, ''))) + LTRIM(RTRIM(COALESCE(HCC103, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC104, ''))) + LTRIM(RTRIM(COALESCE(HCC106, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC107, ''))) + LTRIM(RTRIM(COALESCE(HCC108, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC110, ''))) + LTRIM(RTRIM(COALESCE(HCC111, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC112, ''))) + LTRIM(RTRIM(COALESCE(HCC114, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC115, ''))) + LTRIM(RTRIM(COALESCE(HCC122, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC124, ''))) + LTRIM(RTRIM(COALESCE(HCC134, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC135, ''))) + LTRIM(RTRIM(COALESCE(HCC136, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC137, ''))) + LTRIM(RTRIM(COALESCE(HCC138, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC139, ''))) + LTRIM(RTRIM(COALESCE(HCC140, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC141, ''))) + LTRIM(RTRIM(COALESCE(HCC157, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC158, ''))) + LTRIM(RTRIM(COALESCE(HCC159, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC160, ''))) + LTRIM(RTRIM(COALESCE(HCC161, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC162, ''))) + LTRIM(RTRIM(COALESCE(HCC166, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC167, ''))) + LTRIM(RTRIM(COALESCE(HCC169, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC170, ''))) + LTRIM(RTRIM(COALESCE(HCC173, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC176, ''))) + LTRIM(RTRIM(COALESCE(HCC186, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC188, ''))) + LTRIM(RTRIM(COALESCE(HCC189, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC006, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC034, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC046, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC054, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC055, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC110, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC176, ''))) + LTRIM(RTRIM(COALESCE(CANCER_IMMUNE, '')))
                                                                   + LTRIM(RTRIM(COALESCE(CHF_COPD, ''))) + LTRIM(RTRIM(COALESCE(CHF_RENAL, '')))
                                                                   + LTRIM(RTRIM(COALESCE(COPD_CARD_RESP_FAIL, ''))) + LTRIM(RTRIM(COALESCE(DIABETES_CHF, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SEPSIS_CARD_RESP_FAIL, ''))) + LTRIM(RTRIM(COALESCE(MEDICAID, '')))
                                                                   + LTRIM(RTRIM(COALESCE(Orginaly_Disabled, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC039, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC077, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC085, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC161, ''))) 
													  + LTRIM(RTRIM(COALESCE(ART_OPENINGS_PRESSURE_ULCER, '')))
                                                                   + LTRIM(RTRIM(COALESCE(ASP_SPEC_BACT_PNEUM_PRES_ULC, '')))
                                                                   + LTRIM(RTRIM(COALESCE(COPD_ASP_SPEC_BACT_PNEUM, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DISABLED_PRESSURE_ULCER, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_CHF, ''))) + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_COPD, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_SEIZURES, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SEPSIS_ARTIF_OPENINGS, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SEPSIS_ASP_SPEC_BACT_PNEUM, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SEPSIS_PRESSURE_ULCER, ''))) + LTRIM(RTRIM(COALESCE(LoadDate, '')))
                                                                   + LTRIM(RTRIM(COALESCE(RecordSource, ''))))), 2)) ,
                RecordSource = @RecordSource ,
                LoadDate = @CurrentDate ,
                S_MemberDemo_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(FirstName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LastName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(MI, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(Gender, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(DOB, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(RecordSource, '')))))), 2)),
			 S_MemberDemo_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(FirstName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LastName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(MI, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(Gender, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(DOB, '')))))), 2)),
                S_MemberHICN_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(HICN, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(RecordSource, '')))))), 2)),
			 S_MemberHICN_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(HICN, '')))))), 2)),
                L_Member_MOR_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@RecordTypeCode, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@ContractNumber, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@RunDate, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@PaymentYearAndMonth, '')))))), 2));
	   
        UPDATE  CHSStaging.mor.MOR_CRecord_Stage
        SET     H_MOR_Header_RK = @RK ,
			 LS_MOR_CRecord_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                   UPPER(LTRIM(RTRIM(COALESCE(@RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(@ContractNumber, '')))
														   + LTRIM(RTRIM(COALESCE(@RunDate, ''))) + LTRIM(RTRIM(COALESCE(@PaymentYearAndMonth, '')))
														   + LTRIM(RTRIM(COALESCE(RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(HICN, '')))
                                                                         + LTRIM(RTRIM(COALESCE(LastName, ''))) + LTRIM(RTRIM(COALESCE(FirstName, '')))
                                                                         + LTRIM(RTRIM(COALESCE(MI, ''))) + LTRIM(RTRIM(COALESCE(DOB, '')))
                                                                         + LTRIM(RTRIM(COALESCE(Gender, ''))) + LTRIM(RTRIM(COALESCE(SSN, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F034, ''))) + LTRIM(RTRIM(COALESCE(F3544, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F4554, ''))) + LTRIM(RTRIM(COALESCE(F5559, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F6064, ''))) + LTRIM(RTRIM(COALESCE(F6569, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F7074, ''))) + LTRIM(RTRIM(COALESCE(F7579, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F8084, ''))) + LTRIM(RTRIM(COALESCE(F8589, '')))
                                                                         + LTRIM(RTRIM(COALESCE(F9094, ''))) + LTRIM(RTRIM(COALESCE(F95GT, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M034, ''))) + LTRIM(RTRIM(COALESCE(M3544, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M4554, ''))) + LTRIM(RTRIM(COALESCE(M5559, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M6064, ''))) + LTRIM(RTRIM(COALESCE(M6569, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M7074, ''))) + LTRIM(RTRIM(COALESCE(M7579, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M8084, ''))) + LTRIM(RTRIM(COALESCE(M8589, '')))
                                                                         + LTRIM(RTRIM(COALESCE(M9094, ''))) + LTRIM(RTRIM(COALESCE(M95GT, '')))
                                                                         + LTRIM(RTRIM(COALESCE(MedicaidFemaleDisabled, '')))
                                                                         + LTRIM(RTRIM(COALESCE(MedicaidFemaleAged, '')))
                                                                         + LTRIM(RTRIM(COALESCE(MedicaidMaleDisabled, '')))
                                                                         + LTRIM(RTRIM(COALESCE(MedicaidMaleAged, '')))
                                                                         + LTRIM(RTRIM(COALESCE(OriginallyDisabledFemale, '')))
                                                                         + LTRIM(RTRIM(COALESCE(OriginallyDisabledMale, ''))) + LTRIM(RTRIM(COALESCE(HCC001, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC002, ''))) + LTRIM(RTRIM(COALESCE(HCC006, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC008, ''))) + LTRIM(RTRIM(COALESCE(HCC009, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC010, ''))) + LTRIM(RTRIM(COALESCE(HCC011, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC012, ''))) + LTRIM(RTRIM(COALESCE(HCC017, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC018, ''))) + LTRIM(RTRIM(COALESCE(HCC019, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC021, ''))) + LTRIM(RTRIM(COALESCE(HCC022, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC023, ''))) + LTRIM(RTRIM(COALESCE(HCC027, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC028, ''))) + LTRIM(RTRIM(COALESCE(HCC029, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC033, ''))) + LTRIM(RTRIM(COALESCE(HCC034, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC035, ''))) + LTRIM(RTRIM(COALESCE(HCC039, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC040, ''))) + LTRIM(RTRIM(COALESCE(HCC046, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC047, ''))) + LTRIM(RTRIM(COALESCE(HCC048, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC054, ''))) + LTRIM(RTRIM(COALESCE(HCC055, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC057, ''))) + LTRIM(RTRIM(COALESCE(HCC058, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC070, ''))) + LTRIM(RTRIM(COALESCE(HCC071, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC072, ''))) + LTRIM(RTRIM(COALESCE(HCC073, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC074, ''))) + LTRIM(RTRIM(COALESCE(HCC075, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC076, ''))) + LTRIM(RTRIM(COALESCE(HCC077, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC078, ''))) + LTRIM(RTRIM(COALESCE(HCC079, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC080, ''))) + LTRIM(RTRIM(COALESCE(HCC082, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC083, ''))) + LTRIM(RTRIM(COALESCE(HCC084, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC085, ''))) + LTRIM(RTRIM(COALESCE(HCC086, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC087, ''))) + LTRIM(RTRIM(COALESCE(HCC088, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC096, ''))) + LTRIM(RTRIM(COALESCE(HCC099, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC100, ''))) + LTRIM(RTRIM(COALESCE(HCC103, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC104, ''))) + LTRIM(RTRIM(COALESCE(HCC106, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC107, ''))) + LTRIM(RTRIM(COALESCE(HCC108, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC110, ''))) + LTRIM(RTRIM(COALESCE(HCC111, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC112, ''))) + LTRIM(RTRIM(COALESCE(HCC114, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC115, ''))) + LTRIM(RTRIM(COALESCE(HCC122, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC124, ''))) + LTRIM(RTRIM(COALESCE(HCC134, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC135, ''))) + LTRIM(RTRIM(COALESCE(HCC136, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC137, ''))) + LTRIM(RTRIM(COALESCE(HCC157, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC158, ''))) + LTRIM(RTRIM(COALESCE(HCC161, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC162, ''))) + LTRIM(RTRIM(COALESCE(HCC166, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC167, ''))) + LTRIM(RTRIM(COALESCE(HCC169, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC170, ''))) + LTRIM(RTRIM(COALESCE(HCC173, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC176, ''))) + LTRIM(RTRIM(COALESCE(HCC186, '')))
                                                                         + LTRIM(RTRIM(COALESCE(HCC188, ''))) + LTRIM(RTRIM(COALESCE(HCC189, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC006, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC034, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC046, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC054, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC055, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC110, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC176, ''))) + LTRIM(RTRIM(COALESCE(CANCER_IMMUNE, '')))
                                                                         + LTRIM(RTRIM(COALESCE(CHF_COPD, ''))) + LTRIM(RTRIM(COALESCE(CHF_RENAL, '')))
                                                                         + LTRIM(RTRIM(COALESCE(COPD_CARD_RESP_FAIL, ''))) 
														   + LTRIM(RTRIM(COALESCE(DIABETES_CHF, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SEPSIS_CARD_RESP_FAIL, ''))) + LTRIM(RTRIM(COALESCE(MEDICAID, '')))
                                                                         + LTRIM(RTRIM(COALESCE(Orginaly_Disabled, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC039, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC077, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC085, '')))
                                                                         + LTRIM(RTRIM(COALESCE(DD_HCC161, ''))) 
														   + LTRIM(RTRIM(COALESCE(DISABLED_PRESSURE_ULCER, '')))
                                                                         + LTRIM(RTRIM(COALESCE(ART_OPENINGS_PRESSURE_ULCER, '')))
                                                                         + LTRIM(RTRIM(COALESCE(ASP_SPEC_BACT_PNEUM_PRES_ULC, '')))
                                                                         + LTRIM(RTRIM(COALESCE(COPD_ASP_SPEC_BACT_PNEUM, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_CHF, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_COPD, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_SEIZURES, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SEPSIS_ARTIF_OPENINGS, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SEPSIS_ASP_SPEC_BACT_PNEUM, '')))
                                                                         + LTRIM(RTRIM(COALESCE(SEPSIS_PRESSURE_ULCER, ''))))), 2)) ,
                HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                             UPPER(LTRIM(RTRIM(COALESCE(@RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(@ContractNumber, '')))
													  + LTRIM(RTRIM(COALESCE(@RunDate, ''))) + LTRIM(RTRIM(COALESCE(@PaymentYearAndMonth, '')))
													  + LTRIM(RTRIM(COALESCE(RecordTypeCode, ''))) + LTRIM(RTRIM(COALESCE(HICN, '')))
                                                                   + LTRIM(RTRIM(COALESCE(LastName, ''))) + LTRIM(RTRIM(COALESCE(FirstName, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MI, ''))) + LTRIM(RTRIM(COALESCE(DOB, '')))
                                                                   + LTRIM(RTRIM(COALESCE(Gender, ''))) + LTRIM(RTRIM(COALESCE(SSN, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F034, ''))) + LTRIM(RTRIM(COALESCE(F3544, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F4554, ''))) + LTRIM(RTRIM(COALESCE(F5559, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F6064, ''))) + LTRIM(RTRIM(COALESCE(F6569, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F7074, ''))) + LTRIM(RTRIM(COALESCE(F7579, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F8084, ''))) + LTRIM(RTRIM(COALESCE(F8589, '')))
                                                                   + LTRIM(RTRIM(COALESCE(F9094, ''))) + LTRIM(RTRIM(COALESCE(F95GT, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M034, ''))) + LTRIM(RTRIM(COALESCE(M3544, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M4554, ''))) + LTRIM(RTRIM(COALESCE(M5559, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M6064, ''))) + LTRIM(RTRIM(COALESCE(M6569, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M7074, ''))) + LTRIM(RTRIM(COALESCE(M7579, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M8084, ''))) + LTRIM(RTRIM(COALESCE(M8589, '')))
                                                                   + LTRIM(RTRIM(COALESCE(M9094, ''))) + LTRIM(RTRIM(COALESCE(M95GT, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MedicaidFemaleDisabled, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MedicaidFemaleAged, ''))) 
													  + LTRIM(RTRIM(COALESCE(MedicaidMaleDisabled, '')))
                                                                   + LTRIM(RTRIM(COALESCE(MedicaidMaleAged, '')))
                                                                   + LTRIM(RTRIM(COALESCE(OriginallyDisabledFemale, '')))
                                                                   + LTRIM(RTRIM(COALESCE(OriginallyDisabledMale, ''))) 
													  + LTRIM(RTRIM(COALESCE(HCC001, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC002, ''))) + LTRIM(RTRIM(COALESCE(HCC006, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC008, ''))) + LTRIM(RTRIM(COALESCE(HCC009, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC010, ''))) + LTRIM(RTRIM(COALESCE(HCC011, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC012, ''))) + LTRIM(RTRIM(COALESCE(HCC017, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC018, ''))) + LTRIM(RTRIM(COALESCE(HCC019, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC021, ''))) + LTRIM(RTRIM(COALESCE(HCC022, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC023, ''))) + LTRIM(RTRIM(COALESCE(HCC027, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC028, ''))) + LTRIM(RTRIM(COALESCE(HCC029, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC033, ''))) + LTRIM(RTRIM(COALESCE(HCC034, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC035, ''))) + LTRIM(RTRIM(COALESCE(HCC039, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC040, ''))) + LTRIM(RTRIM(COALESCE(HCC046, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC047, ''))) + LTRIM(RTRIM(COALESCE(HCC048, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC054, ''))) + LTRIM(RTRIM(COALESCE(HCC055, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC057, ''))) + LTRIM(RTRIM(COALESCE(HCC058, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC070, ''))) + LTRIM(RTRIM(COALESCE(HCC071, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC072, ''))) + LTRIM(RTRIM(COALESCE(HCC073, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC074, ''))) + LTRIM(RTRIM(COALESCE(HCC075, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC076, ''))) + LTRIM(RTRIM(COALESCE(HCC077, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC078, ''))) + LTRIM(RTRIM(COALESCE(HCC079, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC080, ''))) + LTRIM(RTRIM(COALESCE(HCC082, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC083, ''))) + LTRIM(RTRIM(COALESCE(HCC084, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC085, ''))) + LTRIM(RTRIM(COALESCE(HCC086, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC087, ''))) + LTRIM(RTRIM(COALESCE(HCC088, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC096, ''))) + LTRIM(RTRIM(COALESCE(HCC099, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC100, ''))) + LTRIM(RTRIM(COALESCE(HCC103, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC104, ''))) + LTRIM(RTRIM(COALESCE(HCC106, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC107, ''))) + LTRIM(RTRIM(COALESCE(HCC108, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC110, ''))) + LTRIM(RTRIM(COALESCE(HCC111, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC112, ''))) + LTRIM(RTRIM(COALESCE(HCC114, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC115, ''))) + LTRIM(RTRIM(COALESCE(HCC122, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC124, ''))) + LTRIM(RTRIM(COALESCE(HCC134, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC135, ''))) + LTRIM(RTRIM(COALESCE(HCC136, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC137, ''))) + LTRIM(RTRIM(COALESCE(HCC157, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC158, ''))) + LTRIM(RTRIM(COALESCE(HCC161, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC162, ''))) + LTRIM(RTRIM(COALESCE(HCC166, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC167, ''))) + LTRIM(RTRIM(COALESCE(HCC169, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC170, ''))) + LTRIM(RTRIM(COALESCE(HCC173, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC176, ''))) + LTRIM(RTRIM(COALESCE(HCC186, '')))
                                                                   + LTRIM(RTRIM(COALESCE(HCC188, ''))) + LTRIM(RTRIM(COALESCE(HCC189, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC006, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC034, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC046, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC054, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC055, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC110, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC176, ''))) + LTRIM(RTRIM(COALESCE(CANCER_IMMUNE, '')))
                                                                   + LTRIM(RTRIM(COALESCE(CHF_COPD, ''))) + LTRIM(RTRIM(COALESCE(CHF_RENAL, '')))
                                                                   + LTRIM(RTRIM(COALESCE(COPD_CARD_RESP_FAIL, ''))) + LTRIM(RTRIM(COALESCE(DIABETES_CHF, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SEPSIS_CARD_RESP_FAIL, ''))) + LTRIM(RTRIM(COALESCE(MEDICAID, '')))
                                                                   + LTRIM(RTRIM(COALESCE(Orginaly_Disabled, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC039, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC077, ''))) + LTRIM(RTRIM(COALESCE(DD_HCC085, '')))
                                                                   + LTRIM(RTRIM(COALESCE(DD_HCC161, ''))) + LTRIM(RTRIM(COALESCE(DISABLED_PRESSURE_ULCER, '')))
                                                                   + LTRIM(RTRIM(COALESCE(ART_OPENINGS_PRESSURE_ULCER, '')))
                                                                   + LTRIM(RTRIM(COALESCE(ASP_SPEC_BACT_PNEUM_PRES_ULC, '')))
                                                                   + LTRIM(RTRIM(COALESCE(COPD_ASP_SPEC_BACT_PNEUM, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_CHF, ''))) + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_COPD, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SCHIZOPHRENIA_SEIZURES, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SEPSIS_ARTIF_OPENINGS, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SEPSIS_ASP_SPEC_BACT_PNEUM, '')))
                                                                   + LTRIM(RTRIM(COALESCE(SEPSIS_PRESSURE_ULCER, ''))) + LTRIM(RTRIM(COALESCE(LoadDate, '')))
                                                                   + LTRIM(RTRIM(COALESCE(RecordSource, ''))))), 2)) ,
                RecordSource = @RecordSource ,
                LoadDate = @CurrentDate ,
                S_MemberDemo_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(FirstName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LastName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(MI, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(Gender, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(DOB, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(RecordSource, '')))))), 2)),
			 S_MemberDemo_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(FirstName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LastName, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(MI, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(Gender, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(DOB, '')))))), 2)),
                S_MemberHICN_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(HICN, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(RecordSource, '')))))), 2)),
			 S_MemberHICN_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(HICN, '')))))), 2)),
                L_Member_MOR_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CentauriMemberID, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@RecordTypeCode, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@ContractNumber, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@RunDate, ''))), ':',
                                                                                 RTRIM(LTRIM(COALESCE(@PaymentYearAndMonth, '')))))), 2));


    END;
GO
