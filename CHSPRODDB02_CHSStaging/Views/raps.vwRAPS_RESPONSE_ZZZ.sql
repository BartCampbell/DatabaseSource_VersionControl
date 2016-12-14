SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [raps].[vwRAPS_RESPONSE_ZZZ]
AS
     SELECT DISTINCT
          z.RecordID ,
          z.SubmitterID ,
          z.FileID ,
          z.BBBRecordTotal ,
          z.ResponseFileID ,
          UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.FileID, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))) ))), 2)) AS H_RAPS_Response_RK ,
          UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(z.RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(z.LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(c.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(z.RecordID,''))),':',RTRIM(LTRIM(COALESCE(z.SubmitterID,''))),':',RTRIM(LTRIM(COALESCE(z.FileID,''))),':',RTRIM(LTRIM(COALESCE(z.BBBRecordTotal,'')))))),2)) AS S_RAPS_Response_ZZZ_RK ,
          UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(z.RecordID,''))),':',RTRIM(LTRIM(COALESCE(z.SubmitterID,''))),':',RTRIM(LTRIM(COALESCE(z.FileID,''))),':',RTRIM(LTRIM(COALESCE(z.BBBRecordTotal,'')))))),2)) AS HashDiff ,
          z.LoadDate ,
          z.RecordSource
    FROM raps.RAPS_RESPONSE_AAA a 
    INNER JOIN raps.RAPS_RESPONSE_CCC c ON c.ResponseFileID = a.ResponseFileID 
    INNER JOIN raps.RAPS_RESPONSE_ZZZ z ON z.ResponseFileID = a.ResponseFileID

GO
