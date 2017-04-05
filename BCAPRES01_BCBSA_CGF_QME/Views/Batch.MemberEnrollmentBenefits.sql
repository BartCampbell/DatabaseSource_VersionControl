SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Batch].[MemberEnrollmentBenefits]
AS
SELECT	BBM.BatchID,
		MNB.BenefitID,
        MNB.DataSetID,
		BBM.DSMemberID,
        MNB.EnrollItemID
FROM	Member.EnrollmentBenefits AS MNB
		INNER JOIN Member.Enrollment AS MN
				ON MN.EnrollItemID = MNB.EnrollItemID
		INNER JOIN Batch.BatchMembers AS BBM
				ON BBM.DSMemberID = MN.DSMemberID;
GO
