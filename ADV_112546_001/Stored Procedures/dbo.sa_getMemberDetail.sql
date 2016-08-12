SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Finance Report List
-- =============================================
/* Sample Executions
sa_getMemberDetail @Member=218,@SuspectYear=2014
*/
CREATE PROCEDURE [dbo].[sa_getMemberDetail]
	@Member BigInt,
	@SuspectYear smallint
AS
BEGIN
	SELECT  H.HCC_Desc,SH.PaymentModel
			, SH.PreHCC,SH.PreRAF,SH.PreRAF*S.BidRate PreAmount
			, SH.PostHCC,SH.PostRAF,SH.PostRAF*S.BidRate PostAmount
			, SH.Paid,SH.RAPS,SH.Projected,SH.Pharmacy,SH.Lab	
	FROM cacheSuspect S
		INNER JOIN cacheSuspectHCC SH ON SH.Member_PK = S.Member_PK AND SH.SuspectYear = S.SuspectYear
		INNER JOIN tblHCC H ON H.HCC = SH.PreHCC AND H.PaymentModel = SH.PaymentModel
	WHERE S.SuspectYear = @SuspectYear AND S.Member_PK = @Member
	ORDER BY H.HCC_Desc
END
SELECT TOP 10 * FROM cacheSuspectHCC
GO
