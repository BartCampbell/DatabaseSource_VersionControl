SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE	PROC [CGF_REP].[MaxClientAll] 
AS

DECLARE @Output TABLE ([ID] int IDENTITY(1,1), ValueField varchar(50), DisplayName varchar(50))

INSERT INTO @Output (ValueField, DisplayName) SELECT 'All Client', 'All Client'

SELECT * FROM @Output ORDER BY [ID]


GO
