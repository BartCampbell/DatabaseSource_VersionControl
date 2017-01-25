CREATE TABLE [Ncqa].[PLD_FileLayouts]
(
[AggregateID] [tinyint] NULL,
[ColumnEnd] [smallint] NOT NULL,
[ColumnLength] [smallint] NOT NULL,
[ColumnPosition] [smallint] NOT NULL,
[ColumnStart] [smallint] NOT NULL,
[FieldDescr] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FieldName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromAge] AS (floor(([FromAgeYears]*(12.00)+[FromAgeMonths])/(12.00))) PERSISTED,
[FromAgeMonths] [smallint] NULL,
[FromAgeTotMonths] AS ((12)*[FromAgeYears]+[FromAgeMonths]) PERSISTED,
[FromAgeYears] [tinyint] NULL,
[Gender] [tinyint] NULL,
[MeasureID] [int] NULL,
[MetricAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricID] [int] NULL,
[PldColumnID] [smallint] NULL,
[PldFileID] [int] NOT NULL,
[PldLayoutGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PLD_Layout_PldLayoutGuid] DEFAULT (newid()),
[PldLayoutID] [int] NOT NULL IDENTITY(1, 1),
[ToAge] AS (floor(([ToAgeYears]*(12.00)+[ToAgeMonths])/(12.00))) PERSISTED,
[ToAgeMonths] [smallint] NULL,
[ToAgeTotMonths] AS ([ToAgeYears]*(12)+[ToAgeMonths]) PERSISTED,
[ToAgeYears] [tinyint] NULL,
[ValidateID] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/21/2012
-- Description:	Applies MeasureIDs and MetricIDs as abbreviations are updated.
-- =============================================
CREATE TRIGGER [Ncqa].[PLD_Layout_ApplyMeasureMetricIDs_IU] 
   ON  [Ncqa].[PLD_FileLayouts] 
   AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	WITH Metrics AS
	(
		SELECT	MX.*, MM.MeasureSetID
		FROM	Measure.Metrics AS MX
				INNER JOIN Measure.Measures AS MM
						ON MX.MeasureID = MM.MeasureID
	)
	UPDATE	t
	SET		MeasureID = MX.MeasureID,
			MetricID = MX.MetricID
	FROM	Ncqa.[PLD_FileLayouts] AS t
			INNER JOIN Ncqa.PLD_Files AS f
					ON t.PldFileID = f.PldFileID
			LEFT OUTER JOIN Metrics AS MX
					ON f.MeasureSetID = MX.MeasureSetID AND
						t.MetricAbbrev = MX.Abbrev
	WHERE	(t.PldLayoutId IN (SELECT PldLayoutId FROM INSERTED));

END
GO
ALTER TABLE [Ncqa].[PLD_FileLayouts] ADD CONSTRAINT [PK_PLD_FileLayouts] PRIMARY KEY CLUSTERED  ([PldLayoutID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PLD_FileLayouts] ON [Ncqa].[PLD_FileLayouts] ([PldFileID], [ColumnPosition]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PLD_FileLayouts_PldLayoutGuid] ON [Ncqa].[PLD_FileLayouts] ([PldLayoutGuid]) ON [PRIMARY]
GO
