SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Jul-03-2015
-- Description:	
-- =============================================
/* Sample Executions
ua_getUserActivity 4
*/
CREATE PROCEDURE [dbo].[ua_getUserActivity]
	@session bigint
AS
BEGIN
	SELECT AccessedDate,AccessedPage FROm tblUserSessionLog WHERE Session_PK = @session ORDER BY AccessedDate
END
GO
