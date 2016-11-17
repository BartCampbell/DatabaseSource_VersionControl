SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	06/10/2016
-- Description:	Updates the RAPS staging tables with the metadata needed to load to the DataVault
-- =============================================
CREATE PROCEDURE [raps].[prUpdateResponseStaging]
	-- Add the parameters for the stored procedure here
	@ClientID INT,
	@FileName VARCHAR(100)
AS
BEGIN
	
	DECLARE @LoadDate DATETIME = GETDATE()
	
	SET NOCOUNT ON;

	--Update Client_RK
	UPDATE s
	SET H_Client_RK = c.ClientHashKey, ClientName = c.ClientName
	FROM raps.RAPS_RESPONSE_CCC s 
	     INNER JOIN CHSDV.dbo.R_Client c ON @ClientID = c.CentauriClientID

    --UPDATE AAA
    UPDATE a 
    SET --a.H_RAPS_Response_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.FileID, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))) ))), 2)),
	   --a.S_RAPS_Response_AAA_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(@LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(a.SubmitterID,''))),':',RTRIM(LTRIM(COALESCE(a.FileID,''))),':',RTRIM(LTRIM(COALESCE(a.TransactionDate,''))),':',RTRIM(LTRIM(COALESCE(a.ProdTestIND,''))),':',RTRIM(LTRIM(COALESCE(a.FileDiagType,'')))))),2)),
	   --a.HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.SubmitterID,''))),':',RTRIM(LTRIM(COALESCE(a.FileID,''))),':',RTRIM(LTRIM(COALESCE(a.TransactionDate,''))),':',RTRIM(LTRIM(COALESCE(a.ProdTestIND,''))),':',RTRIM(LTRIM(COALESCE(a.FileDiagType,''))) ))),2)),
	   a.LoadDate = @LoadDate,
	   a.RecordSource = @FileName
    FROM raps.RAPS_RESPONSE_AAA a 
    INNER JOIN raps.RAPS_RESPONSE_CCC c ON c.ResponseFileID = a.ResponseFileID; 

    --UPDATE BBB
    UPDATE b
    SET --b.H_RAPS_Response_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.FileID, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))) ))), 2)),
	   --b.S_RAPS_Response_BBB_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(@LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(b.SeqNo,''))),':',RTRIM(LTRIM(COALESCE(b.PlanNo,''))),':',RTRIM(LTRIM(COALESCE(b.OverPaymentID,''))),':',RTRIM(LTRIM(COALESCE(b.OverpaymentIDErrorCode,''))),':',RTRIM(LTRIM(COALESCE(b.PaymentYear,''))),':',RTRIM(LTRIM(COALESCE(b.PaymentYearErrorCode,'')))))),2)),
	   --b.HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.SeqNo,''))),':',RTRIM(LTRIM(COALESCE(b.PlanNo,''))),':',RTRIM(LTRIM(COALESCE(b.OverPaymentID,''))),':',RTRIM(LTRIM(COALESCE(b.OverpaymentIDErrorCode,''))),':',RTRIM(LTRIM(COALESCE(b.PaymentYear,''))),':',RTRIM(LTRIM(COALESCE(b.PaymentYearErrorCode,''))) ))),2)),
	   b.LoadDate = @LoadDate,
	   b.RecordSource = @FileName
    FROM raps.RAPS_RESPONSE_AAA a 
    INNER JOIN raps.RAPS_RESPONSE_CCC c ON c.ResponseFileID = a.ResponseFileID 
    INNER JOIN raps.RAPS_RESPONSE_BBB b ON b.ResponseFileID = a.ResponseFileID

    --UPDATE CCC
    UPDATE c
    SET c.H_RAPS_Response_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.FileID, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))) ))), 2)),
	   c.S_RAPS_Response_CCC_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(RTRIM(LTRIM(COALESCE(@FileName,''))) + ':' + RTRIM(LTRIM(COALESCE(@LoadDate,''))) + ':' + RTRIM(LTRIM(COALESCE(c.CentauriMemberID,''))) + ':' + RTRIM(LTRIM(COALESCE(c.SeqNo,''))) + ':' + RTRIM(LTRIM(COALESCE(c.SeqErrorCode,''))) + ':' + RTRIM(LTRIM(COALESCE(c.PatientControlNo,''))) + ':' + RTRIM(LTRIM(COALESCE(c.HicNo,''))) + ':' + RTRIM(LTRIM(COALESCE(c.HicErrorCode,''))) + ':' + RTRIM(LTRIM(COALESCE(c.PatientDOB,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DOBErrorCode,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType1,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.FromDate1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate2,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.DeleteIND2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode3,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB4,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.ProviderType5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate6,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.ThruDate6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND7,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.DiagnosisCode7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA8,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType10,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.FromDate10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.CorrectedHicNo,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError1,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError5,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError9,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError10,''))))), 2)),	  
	   c.HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(RTRIM(LTRIM(COALESCE(c.CentauriMemberID,''))) + ':' + RTRIM(LTRIM(COALESCE(c.SeqNo,''))) + ':' + RTRIM(LTRIM(COALESCE(c.SeqErrorCode,''))) + ':' + RTRIM(LTRIM(COALESCE(c.PatientControlNo,''))) + ':' + RTRIM(LTRIM(COALESCE(c.HicNo,''))) + ':' + RTRIM(LTRIM(COALESCE(c.HicErrorCode,''))) + ':' + RTRIM(LTRIM(COALESCE(c.PatientDOB,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DOBErrorCode,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType1,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.FromDate1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate2,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.DeleteIND2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode3,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB4,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.ProviderType5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate6,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.ThruDate6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND7,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.DiagnosisCode7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA8,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.FromDate9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ProviderType10,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.FromDate10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.ThruDate10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DeleteIND10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagnosisCode10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorA10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.DiagClstrErrorB10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.CorrectedHicNo,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode1,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError1,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError2,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError3,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError4,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode5,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError5,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError6,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError7,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError8,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode9,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError9,''))) + ':' + 
				RTRIM(LTRIM(COALESCE(c.RiskAssessmentCode10,''))) + ':' + RTRIM(LTRIM(COALESCE(c.RiskAssessmentCodeError10,''))))), 2)),
	   c.LoadDate = @LoadDate,
	   c.RecordSource = @FileName,
	   c.L_MemberRAPSResponse_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(a.FileID, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))) ))), 2)),
	   c.RAPS_Response_BK = CONVERT(VARCHAR(50),CONCAT(a.FileID,c.CentauriMemberID)),
	   c.ClientID = @ClientID,
	   c.S_MemberHICN_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(@LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(c.HicNo, '')))))), 2)),
	   c.S_MemberHICN_HashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(c.HicNo, '')))))), 2))
    FROM raps.RAPS_RESPONSE_AAA a 
    INNER JOIN raps.RAPS_RESPONSE_CCC c ON c.ResponseFileID = a.ResponseFileID 

    --UPDATE yyy
    UPDATE y
    SET --y.H_RAPS_Response_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.FileID, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))) ))), 2)),
	   --y.S_RAPS_Response_YYY_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(@LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(y.SeqNo,''))),':',RTRIM(LTRIM(COALESCE(y.PlanNo,''))),':',RTRIM(LTRIM(COALESCE(y.CCCRecordTotal,'')))))),2)),
	   --y.HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(y.SeqNo,''))),':',RTRIM(LTRIM(COALESCE(y.PlanNo,''))),':',RTRIM(LTRIM(COALESCE(y.CCCRecordTotal,'')))))),2)),
	   y.LoadDate = @LoadDate,
	   y.RecordSource = @FileName
    FROM raps.RAPS_RESPONSE_AAA a 
    INNER JOIN raps.RAPS_RESPONSE_CCC c ON c.ResponseFileID = a.ResponseFileID 
    INNER JOIN raps.RAPS_RESPONSE_YYY y ON y.ResponseFileID = a.ResponseFileID

    --UPDATE ZZZ
    UPDATE z
    SET --z.H_RAPS_Response_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.FileID, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))) ))), 2)),
	   --z.S_RAPS_Response_ZZZ_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@FileName, ''))), ':', RTRIM(LTRIM(COALESCE(@LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(z.RecordID,''))),':',RTRIM(LTRIM(COALESCE(z.SubmitterID,''))),':',RTRIM(LTRIM(COALESCE(z.FileID,''))),':',RTRIM(LTRIM(COALESCE(z.BBBRecordTotal,'')))))),2)),
	   --z.HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(z.RecordID,''))),':',RTRIM(LTRIM(COALESCE(z.SubmitterID,''))),':',RTRIM(LTRIM(COALESCE(z.FileID,''))),':',RTRIM(LTRIM(COALESCE(z.BBBRecordTotal,'')))))),2)),
	   z.LoadDate = @LoadDate,
	   z.RecordSource = @FileName
    FROM raps.RAPS_RESPONSE_AAA a 
    INNER JOIN raps.RAPS_RESPONSE_CCC c ON c.ResponseFileID = a.ResponseFileID 
    INNER JOIN raps.RAPS_RESPONSE_ZZZ z ON z.ResponseFileID = a.ResponseFileID

	

END

GO
