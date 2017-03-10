SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/27/2012
-- Description:	Applies additional event base criteria for claim attributes.
-- =============================================
CREATE PROCEDURE [Batch].[ApplyEventBaseForClaimAttribs]
(
	@BatchID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	EXEC Batch.ApplyEventBaseTypeL @BatchID = @BatchID, @IsClaimAttrib = 1
END


GO
GRANT VIEW DEFINITION ON  [Batch].[ApplyEventBaseForClaimAttribs] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ApplyEventBaseForClaimAttribs] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ApplyEventBaseForClaimAttribs] TO [Processor]
GO
