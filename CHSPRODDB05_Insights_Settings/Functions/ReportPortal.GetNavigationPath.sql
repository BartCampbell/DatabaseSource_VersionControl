SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/30/2015
-- Description:	Retrieves the path for navigating to a given report object through the navigation hierarchy.  
-- =============================================
CREATE FUNCTION [ReportPortal].[GetNavigationPath]
(
	@RptObjID smallint,
	@PathSeparator varchar(16) = ' » '
)
RETURNS 
@Results TABLE 
(
	[NavigationPath] varchar(1024) NULL,
	[NavigationRoot] varchar(128) NULL
)
AS
BEGIN
	DECLARE @Path varchar(1024);
	DECLARE @Root varchar(128)
	DECLARE @ID smallint;
	DECLARE @NewID smallint;

	SET @ID = @RptObjID;

	SELECT @Path = DisplayName FROM ReportPortal.Objects WITH(NOLOCK) WHERE RptObjID = @RptObjID AND RptObjTypeID IN (2, 3);

	WHILE (@ID IS NOT NULL AND @Path IS NOT NULL)
		BEGIN;
			SET @NewID = NULL;

			SELECT	@NewID = RPN.RptObjID,
					@Path = RPO.DisplayName + ISNULL(@PathSeparator + @Path, ''),
					@Root = RPO.DisplayName
			FROM	ReportPortal.Objects AS RPO WITH(NOLOCK)
					INNER JOIN ReportPortal.Navigation AS RPN WITH(NOLOCK)
							ON RPN.RptObjID = RPO.RptObjID
			WHERE	(RPN.ChildID = @ID);

			SET @ID = @NewID;
		END;

	INSERT INTO @Results
	SELECT @Path, @Root

	RETURN 
END
GO
