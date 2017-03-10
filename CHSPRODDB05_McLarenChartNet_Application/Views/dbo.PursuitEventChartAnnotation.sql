SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[PursuitEventChartAnnotation] AS
WITH Annotations AS
(
	SELECT	RVCI.PursuitEventChartImageID,
			content.value('@page', 'int') AS PageNumber,
			content.value('@xpos', 'int') AS XPosition,
			content.value('@ypos', 'int') AS YPosition,
			content.value('@height', 'int') AS Height,
			content.value('@width', 'int') AS Width,
			content.value('@color', 'varchar(64)') AS Color,
			content.value('@font', 'varchar(64)') AS Font,
			content.value('@created', 'datetime') AS CreatedDate,
			content.value('@by', 'varchar(128)') AS CreatedUser,
			content.value('@modified', 'datetime') AS LastModifiedDate,
			content.value('.','varchar(max)') AS NoteText
	FROM	dbo.PursuitEventChartImage AS RVCI
			CROSS APPLY RVCI.AnnotationContent.nodes('/annotations/annotation') AS c(content)
	WHERE	RVCI.AnnotationContent IS NOT NULL
)
SELECT	PursuitEventChartImageID,
		PageNumber,
		XPosition,
		YPosition,
		Height,
		Width,
		Color,
		Font,
		CreatedDate,
		CreatedUser,
		LastModifiedDate,
		NoteText,
		ROW_NUMBER() OVER (PARTITION BY PursuitEventChartImageID ORDER BY PageNumber, YPosition, XPosition) AS SortOrder
FROM	Annotations;
GO
