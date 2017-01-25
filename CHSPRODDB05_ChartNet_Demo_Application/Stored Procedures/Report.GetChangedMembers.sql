SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetChangedMembers]
(
	@LastChangedRangeStartDate datetime = NULL,
	@LastChangedRangeEndDate datetime = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @LastChangedRangeStartDate IS NULL
		SET @LastChangedRangeStartDate = 0;

	IF @LastChangedRangeEndDate IS NULL
		SET @LastChangedRangeEndDate = DATEADD(ss, 1, GETDATE());

	SELECT	MBR.MemberID,
			MBR.ProductLine,
			MBR.Product,
			MBR.CustomerMemberID,
			MBR.NameLast AS LastName,
			MBR.NameFirst AS FirstName,
			MBR.NameMiddleInitial AS MI,
			MBR.OriginalDateOfBirth,
			MBR.OriginalGender,
			MBR.DateOfBirth AS CurrentDateOfBirth,
			MBR.Gender AS CurrentGender,
			MBR.LastChangedDate,
			MBR.LastChangedUser
	FROM	dbo.Member AS MBR WITH(NOLOCK)
	WHERE	(MBR.Changed = 1) AND
			(MBR.LastChangedDate BETWEEN @LastChangedRangeStartDate AND @LastChangedRangeEndDate);
	
END

GO
GRANT EXECUTE ON  [Report].[GetChangedMembers] TO [Reporting]
GO
