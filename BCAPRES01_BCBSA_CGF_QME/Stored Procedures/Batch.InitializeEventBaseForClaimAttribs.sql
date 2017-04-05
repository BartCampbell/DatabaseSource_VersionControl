SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/27/2012
-- Description:	Initialize base event records for claim attributes.
-- =============================================
CREATE PROCEDURE [Batch].[InitializeEventBaseForClaimAttribs]
(
	@BatchID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	EXEC Batch.InitializeEventBase @BatchID = @BatchID, @IsClaimAttrib = 1;
END

GO
GRANT EXECUTE ON  [Batch].[InitializeEventBaseForClaimAttribs] TO [Processor]
GO
