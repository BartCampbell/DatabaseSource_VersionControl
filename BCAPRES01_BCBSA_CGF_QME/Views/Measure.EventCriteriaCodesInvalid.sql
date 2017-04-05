SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Measure].[EventCriteriaCodesInvalid] AS 
SELECT DISTINCT TOP (100) PERCENT
		CCT.CodeType,
		CCT.Descr AS CodeTypeDescr,  
		CCT.CodeTypeID,
        MVC.Descr AS EventCritDescr,
        MVC.EventCritGuid,
        MVC.EventCritID,
        MVC.MeasureSetID,
        MVC.Reference1,
        MVC.Reference2,
        MVC.Reference3,
        MVC.Reference4
FROM	Measure.EventCriteriaCodes AS MVCC
		INNER JOIN Claim.Codes AS CC
				ON MVCC.CodeID = CC.CodeID
		INNER JOIN Claim.CodeTypes AS CCT
				ON CC.CodeTypeID = CCT.CodeTypeID
		INNER JOIN Measure.EventCriteria AS MVC
				ON MVCC.EventCritID = MVC.EventCritID
WHERE	CC.IsValid = 0
ORDER BY MVC.EventCritID
		
GO
