SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[FaxLogTypes]
WITH SCHEMABINDING AS
WITH FaxLogTypes(FaxLogType, [Description]) AS
(
	SELECT	CONVERT(char(1), 'R'), CONVERT(varchar(32), 'Receive')
	UNION
	SELECT	CONVERT(char(1), 'S'), CONVERT(varchar(32), 'Send')
)
SELECT	t.FaxLogType,
        t.[Description]
FROM	FaxLogTypes AS t
GO
