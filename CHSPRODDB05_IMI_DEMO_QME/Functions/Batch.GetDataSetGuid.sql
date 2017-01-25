SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/23/2011
-- Description:	Retrieves the GUID matching the specified Data Set ID.
-- =============================================
CREATE FUNCTION [Batch].[GetDataSetGuid]
(
	@DataSetID int
)
RETURNS uniqueidentifier
AS
BEGIN
	DECLARE @Result uniqueidentifier;

	IF @DataSetID IS NOT NULL
		SELECT	@Result = DataSetGuid 
		FROM	Batch.DataSets AS DS WITH(NOLOCK)
		WHERE	(DataSetID = @DataSetID)

	RETURN @Result;
END
GO
GRANT EXECUTE ON  [Batch].[GetDataSetGuid] TO [Processor]
GO
