SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[prLoadAbstractorAndReviewer]
AS
BEGIN
	SET NOCOUNT ON;

    EXEC dbo.prLoadAbstractor;
	EXEC dbo.prLoadReviewer;
END
GO
