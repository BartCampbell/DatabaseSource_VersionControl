SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[Report_CBPPursuitDataCollectionProgress]
AS 
SELECT  CustomerMemberID,
        NameFirst,
        NameLast,
        AbstractionDate = CONVERT(varchar(10), AbstractionDate, 101),
        SampleVoidReasonCode,
        ChartStatus,
        ServiceDate = CONVERT(varchar(10), ServiceDate, 101),
        NotationType,
        NotesExists = CASE WHEN PEN.PursuitEventID IS NULL THEN 'N'
                           ELSE 'Y'
                      END,
        SupplementalDataExists = CASE WHEN PESI.PursuitEventID IS NULL
                                      THEN 'N'
                                      ELSE 'Y'
                                 END,
        NoteText,
        [Character],
        Description
FROM    Pursuit a
        INNER JOIN PursuitEvent a2 ON a.PursuitID = a2.PursuitID
        INNER JOIN Member b ON a.MemberID = b.MemberID
        INNER JOIN Measure Me ON a2.MeasureID = Me.MeasureID
        LEFT JOIN MedicalRecordCBPConf c ON a.PursuitID = c.PursuitID
        LEFT JOIN PursuitEventNote PEN ON a2.PursuitEventID = PEN.PursuitEventID
        LEFT JOIN PursuitEventSupplementalInformation PESI ON a2.PursuitEventID = PESI.PursuitEventID
WHERE   HEDISMeasure = 'CBP'
ORDER BY 6


GO
