SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Random].[Seed] AS
SELECT	CHECKSUM(NEWID()) AS RandomCheckSum,NEWID() AS RandomGuid, RAND() AS RandomNumber
GO