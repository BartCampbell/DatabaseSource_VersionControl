SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vLatestChaseStatus]
AS
    SELECT  t.ChaseStatusID ,
            t.ClientID ,
            t.ChaseID ,
            t.Status ,
            t.Project ,
            t.FileName ,
            t.LoadDate ,
            t.rown
    FROM    ( SELECT    ChaseStatusID ,
                        ClientID ,
                        ChaseID ,
                        Status ,
                        Project ,
                        FileName ,
                        LoadDate ,
                        ROW_NUMBER() OVER ( PARTITION BY ChaseID ORDER BY LoadDate DESC ) AS rown
              FROM      dbo.ChaseStatus_Archive
              WHERE     Duplicate = 0
            ) t
    WHERE   t.rown = 1;

GO
