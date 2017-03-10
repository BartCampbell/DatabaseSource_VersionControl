SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Report_FPC_GA_QA]
AS 
SELECT  CustomerMemberID,
        GestationalSource = LEFT(GestationalSource, 25),
        GestationalAge,
        CalculatedEDD,
        LMPDate = CONVERT(varchar(10), LMPDate, 101),
        DeliveryDate = CONVERT(varchar(10), DeliveryDate, 101)
FROM    Pursuit P
        INNER JOIN PursuitEvent PE ON P.PursuitID = PE.PursuitID
        INNER JOIN Member M ON P.MemberID = M.MemberID
        INNER JOIN MedicalRecordFPCGA MRGA ON PE.PursuitEventID = MRGA.PursuitEventID
ORDER BY GestationalAge,
        CalculatedEDD
GO
