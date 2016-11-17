SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [raps].[vwRAPS_RESPONSE_YYY]
AS
     SELECT DISTINCT
          y.RecordID ,
          y.SeqNo ,
          y.PlanNo ,
          y.CCCRecordTotal ,
          y.ResponseFileID ,
          UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.FileID, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriMemberID, ''))) ))), 2)) AS H_RAPS_Response_RK ,
          UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(y.RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(y.LoadDate, ''))), ':',RTRIM(LTRIM(COALESCE(c.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(y.SeqNo,''))),':',RTRIM(LTRIM(COALESCE(y.PlanNo,''))),':',RTRIM(LTRIM(COALESCE(y.CCCRecordTotal,'')))))),2)) AS S_RAPS_Response_YYY_RK ,
          UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(y.SeqNo,''))),':',RTRIM(LTRIM(COALESCE(y.PlanNo,''))),':',RTRIM(LTRIM(COALESCE(y.CCCRecordTotal,'')))))),2)) AS HashDiff ,
          y.LoadDate ,
          y.RecordSource
    FROM raps.RAPS_RESPONSE_AAA a 
    INNER JOIN raps.RAPS_RESPONSE_CCC c ON c.ResponseFileID = a.ResponseFileID 
    INNER JOIN raps.RAPS_RESPONSE_YYY y ON y.ResponseFileID = a.ResponseFileID

GO
