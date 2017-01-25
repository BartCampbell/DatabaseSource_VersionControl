SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/23/2011
-- Description:	Retrieves the GUID matching the specified Data Run ID.
-- =============================================
CREATE FUNCTION [Batch].[GetDataRunGuid]
(
	@DataRunID int
)
RETURNS uniqueidentifier
AS
BEGIN
	DECLARE @Result uniqueidentifier;

	IF @DataRunID IS NOT NULL
		SELECT	@Result = DataRunGuid
		FROM	Batch.DataRuns AS DR WITH(NOLOCK)
		WHERE	(DataRunID = @DataRunID)

	RETURN @Result;
END
GO
GRANT EXECUTE ON  [Batch].[GetDataRunGuid] TO [Processor]
GO
