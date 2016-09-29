SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sa_savePoolPriority] 
	@PK1 int,
	@Priority1 int,
	@PK2 int,
	@Priority2 int
AS
BEGIN
	Update tblPool SET Pool_Priority = @Priority2 WHERE Pool_PK = @PK1
	Update tblPool SET Pool_Priority = @Priority1 WHERE Pool_PK = @PK2

	exec sa_getPools 1
END
GO
