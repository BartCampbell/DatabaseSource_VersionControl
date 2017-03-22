SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	EXEC comman_updateSuspectFlags
CREATE PROCEDURE [dbo].[comman_updateSuspectFlags]
AS
BEGIN
	Update S SET 
			IsCoded = CASE WHEN CS.IsCoded=1 AND S.IsCoded=0 THEN 1 ELSE S.IsCoded END,
			Coded_Date = CASE WHEN CS.IsCoded=1 AND S.IsCoded=0 THEN GetDate() ELSE S.Coded_Date END,
			Coded_User_PK = CASE WHEN CS.IsCoded=1 AND S.IsCoded=0 THEN 1 ELSE S.Coded_User_PK END,
			IsScanned = CASE WHEN CS.IsExtracted=1 AND S.IsScanned=0 THEN 1 ELSE S.IsScanned END,
			Scanned_Date = CASE WHEN CS.IsExtracted=1 AND S.IsScanned=0 THEN GetDate() ELSE S.Scanned_Date END,
			Scanned_User_PK = CASE WHEN CS.IsExtracted=1 AND S.IsScanned=0 THEN 1 ELSE S.Scanned_User_PK END,
			IsCNA = CASE WHEN CS.IsCNA=1 AND S.IsCNA=0 AND S.IsScanned=0 THEN 1 ELSE S.IsCNA END,
			CNA_Date = CASE WHEN CS.IsCNA=1 AND S.IsCNA=0 AND S.IsScanned=0 THEN GetDate() ELSE S.CNA_Date END,
			CNA_User_PK = CASE WHEN CS.IsCNA=1 AND S.IsCNA=0 AND S.IsScanned=0 THEN 1 ELSE S.CNA_User_PK END,
			FollowUp = NULL
		FROM tblChaseStatus CS INNER JOIN tblSuspect S ON S.ChaseStatus_PK = CS.ChaseStatus_PK
		WHERE CS.IsCoded=1 OR CS.IsExtracted=1 OR CS.IsCNA=1
END
GO
