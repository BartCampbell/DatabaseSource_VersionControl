SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PrepareFax]
(
	@FaxLogID int
)
AS
BEGIN
	SET NOCOUNT ON;

    IF (ISNULL(dbo.GetAllowFaxLogSubmission(), 0) = 1)
		EXEC dbo.CreateFaxLogSubmission @FaxLogID = @FaxLogID;

END
GO
