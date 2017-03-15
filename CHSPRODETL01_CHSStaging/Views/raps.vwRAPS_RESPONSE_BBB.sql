SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [raps].[vwRAPS_RESPONSE_BBB]
AS
     SELECT DISTINCT
          b.RecordID ,
          b.SeqNo ,
          b.PlanNo ,
          b.OverpaymentID ,
          b.OverpaymentIDErrorCode ,
          b.PaymentYear ,
          b.PaymentYearErrorCode ,
          b.ResponseFileID ,
          UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.FileID, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))) ))), 2)) AS H_RAPS_Response_RK ,
          UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(b.LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(c.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(b.SeqNo,''))),':',RTRIM(LTRIM(COALESCE(b.PlanNo,''))),':',RTRIM(LTRIM(COALESCE(b.OverPaymentID,''))),':',RTRIM(LTRIM(COALESCE(b.OverpaymentIDErrorCode,''))),':',RTRIM(LTRIM(COALESCE(b.PaymentYear,''))),':',RTRIM(LTRIM(COALESCE(b.PaymentYearErrorCode,'')))))),2)) AS S_RAPS_Response_BBB_RK ,
          UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(b.SeqNo,''))),':',RTRIM(LTRIM(COALESCE(b.PlanNo,''))),':',RTRIM(LTRIM(COALESCE(b.OverPaymentID,''))),':',RTRIM(LTRIM(COALESCE(b.OverpaymentIDErrorCode,''))),':',RTRIM(LTRIM(COALESCE(b.PaymentYear,''))),':',RTRIM(LTRIM(COALESCE(b.PaymentYearErrorCode,''))) ))),2)) AS HashDiff ,
          b.LoadDate ,
          b.RecordSource
    FROM raps.RAPS_RESPONSE_AAA a 
    INNER JOIN raps.RAPS_RESPONSE_CCC c ON c.ResponseFileID = a.ResponseFileID 
    INNER JOIN raps.RAPS_RESPONSE_BBB b ON b.ResponseFileID = a.ResponseFileID

GO
