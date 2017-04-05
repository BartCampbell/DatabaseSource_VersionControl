SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Ncqa].[PLD_MemberInfo] AS 
WITH AllMembers AS 
(
	SELECT DISTINCT
			RMD.DataRunID, 
			RMD.DSMemberID,
			RMD.PopulationID,
			RMD.ProductLineID
	FROM	Result.MeasureDetail_Classic AS RMD WITH(NOLOCK, INDEX(IX_MeasureDetail))
	WHERE	IsDenominator = 1 OR IsDenominator IS NULL OR Qty > 0 OR [Days] > 0
	UNION 
	SELECT DISTINCT
			RMMD.DataRunID, 
			RMMD.DSMemberID,
			RMMD.PopulationID,
			RMMD.ProductLineID
	FROM	Result.MemberMonthDetail_Classic AS RMMD WITH(NOLOCK, INDEX(IX_MemberMonthDetail))
	WHERE	RMMD.CountMonths > 0
),
MemberMonths AS
(
	SELECT	ISNULL(RMMD.CountMonths, 0) AS CountMonths,
			t.DataRunID,
			DR.DataSetID AS DataSetID, 
			t.DSMemberID,
			t.PopulationID,
			t.ProductLineID
	FROM	AllMembers AS t
			INNER JOIN Batch.DataRuns AS DR WITH(NOLOCK)
					ON t.DataRunID = DR.DataRunID
			OUTER APPLY	(
							SELECT	SUM(CountMonths) AS CountMonths
							FROM	Result.MemberMonthDetail_Classic AS tRMMD WITH(NOLOCK, INDEX(IX_MemberMonthDetail))
							WHERE	tRMMD.DataRunID = t.DataRunID AND
									tRMMD.DSMemberID = t.DSMemberID AND
									tRMMD.PopulationID = t.PopulationID AND
									tRMMD.ProductLineID = t.ProductLineID AND
									tRMMD.BenefitID = DR.DefaultBenefitID
						) AS RMMD
)
SELECT	M.City,
		t.CountMonths,
		RDMSK.CustomerMemberID,
		t.DataRunID,
		t.DataSetID, 
		RDMSK.DOB,
		t.DSMemberID, 
		LOWER(ISNULL(M.Gender, Member.ConvertGenderToMF(RDMSK.Gender))) AS Gender,
		RDMSK.HicNumber,
		RDMSK.IhdsMemberID,
		M.NameFirst,
		M.NameLast,
		RDMSK.PlanId,
		t.PopulationID,
		t.ProductLineID,
		RDMSK.SnpType,
		M.[State],
		M.ZipCode
FROM	MemberMonths AS t
		INNER JOIN Result.DataSetMemberKey AS RDMSK WITH(NOLOCK)
				ON t.DataRunID = RDMSK.DataRunID AND
					t.DSMemberID = RDMSK.DSMemberID
		LEFT OUTER JOIN dbo.Member AS M WITH(NOLOCK)
				ON RDMSK.IhdsMemberID = M.ihds_member_id;

GO
