SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[EntityEnrollment] AS
SELECT  [ActualBeginDate],
        [ActualBeginGap],
        [ActualBeginGapDays],
        [ActualEndDate],
        [ActualEndGap],
        [ActualEndGapDays],
        [ActualEnrollGroupID],
        ActualFirstRow,
        [ActualGapDays],
        [ActualGapMaxDays],
        [ActualGaps],
        [ActualHasAnchor],
        ActualHasPayer,
        [ActualLastRow],
        [AdminGapDays],
        [AdminGaps],
        [AnchorDate],
        [BatchID],
        [BeginDate],
        [BeginDOBDate],
        [BeginEnrollDate],
        [BenefitID],
		BitBenefits,
		BitProductLines,
        [DataRunID],
        [DataSetID],
        [DSMemberID],
        [EndDate],
        [EndDOBDate],
        [EndEnrollDate],
        [EnrollGroupID],
        [EnrollItemID],
        [EnrollSegBeginDate],
        [EnrollSegEndDate],
        [EntityBaseID],
        [EntityEnrollID],
        [EntityEnrollSetID],
        [EntityEnrollSetLineID],
        [EntityID],
        [GapDays],
        [Gaps],
        [Gender],
        LastSegBeginDate,
        LastSegEndDate,
        [MeasEnrollID],
        [OptionNbr],
        [PayerDate],
        [ProductClassID]
FROM    Internal.[EntityEnrollment]
WHERE   (SpId = @@SPID) ;





GO
