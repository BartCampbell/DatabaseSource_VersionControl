SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To prepare Member
-- =============================================

CREATE PROCEDURE [dbo].[prepareMember]
AS
BEGIN
	Truncate Table cacheMember

	DECLARE @MAXEligibility AS DATE
	SELECT @MAXEligibility = MAX(EligibleMonth) FROM tblCMSEligibility

	Insert Into cacheMember
	SELECT M.Member_PK,ES CE_Start,CASE WHEN EE=@MAXEligibility THEN '9999-12-31' ELSE EE END CE_End
	FROM tblMember M
	Outer Apply (SELECT MIN(EligibleMonth) ES,MAX(EligibleMonth) EE FROM tblCMSEligibility WHERE Member_PK=M.Member_PK) T
	ORDER BY M.Member_PK	
END
GO
