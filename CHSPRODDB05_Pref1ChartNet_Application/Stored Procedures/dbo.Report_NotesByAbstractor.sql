SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Report_NotesByAbstractor]
    @AbstractorID int = NULL
AS 
SELECT  A.AbstractorName,
        M.CustomerMemberID,
        M.NameLast,
        M.NameFirst,
        M.DateOfBirth,
        Me.HEDISMeasure,
        PEN.NoteText
FROM    PursuitEventNote PEN
        INNER JOIN PursuitEvent PE ON PEN.PursuitEventID = PE.PursuitEventID
        INNER JOIN Pursuit P ON PE.PursuitID = P.PursuitID
        INNER JOIN Member M ON P.MemberID = M.MemberID
        INNER JOIN Measure Me ON PE.MeasureID = Me.MeasureID
        INNER JOIN Abstractor A ON P.AbstractorID = A.AbstractorID
WHERE   A.AbstractorID = ISNULL(@AbstractorID, A.AbstractorID)
ORDER BY A.AbstractorName,
        PEN.NoteText





GO
