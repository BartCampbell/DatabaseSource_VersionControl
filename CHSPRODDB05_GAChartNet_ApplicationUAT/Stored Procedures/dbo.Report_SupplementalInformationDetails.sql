SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Report_SupplementalInformationDetails]
AS 
SELECT  A.AbstractorName,
        M.CustomerMemberID,
        M.NameLast,
        M.NameFirst,
        M.DateOfBirth,
        Me.HEDISMeasure,
        PESI.CreateDate,
        PESI.[Character],
        PESI.Description
FROM    PursuitEventSupplementalInformation PESI
        INNER JOIN PursuitEvent PE ON PESI.PursuitEventID = PE.PursuitEventID
        INNER JOIN Pursuit P ON PE.PursuitID = P.PursuitID
        INNER JOIN Member M ON P.MemberID = M.MemberID
        INNER JOIN Measure Me ON PE.MeasureID = Me.MeasureID
        INNER JOIN Abstractor A ON P.AbstractorID = A.AbstractorID
ORDER BY A.AbstractorName,
        M.NameLast,
        M.NameFirst,
        M.DateOfBirth,
        Me.HEDISMeasure,
        PESI.CreateDate





GO
