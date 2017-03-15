SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [raps].[vwRAPS_RESPONSE_AAA]
AS
     SELECT DISTINCT
          a.RecordID ,
          a.SubmitterID ,
          a.FileID ,
          a.TransactionDate ,
          a.ProdTestIND ,
          a.FileDiagType ,
          a.ResponseFileID ,
          UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.FileID, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))) ))), 2)) AS H_RAPS_Response_RK ,
          UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(a.LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(c.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(a.SubmitterID,''))),':',RTRIM(LTRIM(COALESCE(a.FileID,''))),':',RTRIM(LTRIM(COALESCE(a.TransactionDate,''))),':',RTRIM(LTRIM(COALESCE(a.ProdTestIND,''))),':',RTRIM(LTRIM(COALESCE(a.FileDiagType,'')))))),2)) AS S_RAPS_Response_AAA_RK ,
          UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(a.SubmitterID,''))),':',RTRIM(LTRIM(COALESCE(a.FileID,''))),':',RTRIM(LTRIM(COALESCE(a.TransactionDate,''))),':',RTRIM(LTRIM(COALESCE(a.ProdTestIND,''))),':',RTRIM(LTRIM(COALESCE(a.FileDiagType,''))) ))),2)) AS HashDiff ,
          a.LoadDate ,
          a.RecordSource
     FROM raps.RAPS_RESPONSE_AAA a 
    INNER JOIN raps.RAPS_RESPONSE_CCC c ON c.ResponseFileID = a.ResponseFileID; 

GO
