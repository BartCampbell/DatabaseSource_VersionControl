SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Report_FPC_PrenatalPartialDataVisits]
AS 
SELECT  CustomerMemberID,
        PrenatalServicingProviderType,
        OBGYNVisitFlag,
        OBGYNSource,
        ServiceDate = CONVERT(varchar(10), ServiceDate, 101)
FROM    Pursuit P
        INNER JOIN PursuitEvent PE ON P.PursuitID = PE.PursuitID
        INNER JOIN Member M ON P.MemberID = M.MemberID
        INNER JOIN MedicalRecordFPCPre MRPre ON PE.PursuitEventID = MRPre.PursuitEventID
WHERE   PrenatalServicingProviderType = 'OBGYN' AND
        (OBGYNSource = '' OR
         OBGYNVisitFlag <> 1
        )


SELECT  CustomerMemberID,
        PrenatalServicingProviderType,
        PCPVisitFlag,
        PCPSource,
        DiagnosisOfPregancy,
        ServiceDate = CONVERT(varchar(10), ServiceDate, 101)
FROM    Pursuit P
        INNER JOIN PursuitEvent PE ON P.PursuitID = PE.PursuitID
        INNER JOIN Member M ON P.MemberID = M.MemberID
        INNER JOIN MedicalRecordFPCPre MRPre ON PE.PursuitEventID = MRPre.PursuitEventID
WHERE   PrenatalServicingProviderType = 'PCP' AND
        PCPVisitFlag <> 1 AND
        DiagnosisOfPregancy = 1

GO
