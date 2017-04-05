CREATE TABLE [Ncqa].[IDSS_DataElements]
(
[AggregateID] [tinyint] NULL,
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_IDSS_DataElements_BitProductLines] DEFAULT ((0)),
[ExclusionTypeID] [tinyint] NULL,
[FromAgeMonths] [smallint] NULL,
[FromAgeTotMonths] AS ([FromAgeMonths]+((12)*[FromAgeYears])),
[FromAgeYears] [smallint] NULL,
[Gender] [tinyint] NULL,
[IdssColumnID] [int] NULL,
[IdssElementAbbrev] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdssElementDescr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdssElementGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_IDSS_DataElements_IdssElementGuid] DEFAULT (newid()),
[IdssElementID] [int] NOT NULL IDENTITY(1, 1),
[IdssMeasure] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdssMeasureDescr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsAuxiliary] [bit] NOT NULL CONSTRAINT [DF_IDSS_DataElements_IsAuxiliary] DEFAULT ((0)),
[IsBaseSample] [bit] NOT NULL CONSTRAINT [DF_IDSS_DataElements_IsBaseSample] DEFAULT ((0)),
[IsInSample] [bit] NOT NULL CONSTRAINT [DF_IDSS_DataElements_IsInSample] DEFAULT ((0)),
[IsUnknownAge] [bit] NOT NULL CONSTRAINT [DF_IDSS_DataElements_IsUnknownAge] DEFAULT ((0)),
[MeasureAbbrev] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasureID] [int] NULL,
[MeasureSetID] [int] NOT NULL,
[MetricAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricID] [int] NULL,
[PayerID] [int] NULL,
[ResultTypeID] [tinyint] NULL,
[ToAgeMonths] [smallint] NULL,
[ToAgeTotMonths] AS ([ToAgeMonths]+((12)*[ToAgeYears])),
[ToAgeYears] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/25/2012
-- Description:	Applies MeasureIDs and MetricIDs as abbreviations are updated.
-- =============================================
CREATE TRIGGER [Ncqa].[IDSS_DataElements_ApplyMeasureMetricIDs_IU] 
   ON  [Ncqa].[IDSS_DataElements] 
   AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	UPDATE	DE
	SET		MeasureID = MM.MeasureID
	FROM	Ncqa.IDSS_DataElements AS DE
			INNER JOIN Measure.Measures AS MM
					ON DE.MeasureSetID = MM.MeasureSetID AND
						DE.MeasureAbbrev = MM.Abbrev
	WHERE	(DE.IdssElementID IN (SELECT IdssElementID FROM INSERTED));
	
	UPDATE	DE
	SET		MetricID = MX.MetricID
	FROM	Ncqa.IDSS_DataElements AS DE
			INNER JOIN Measure.Measures AS MM
					ON DE.MeasureSetID = MM.MeasureSetID AND
						DE.MeasureAbbrev = MM.Abbrev
			INNER JOIN Measure.Metrics AS MX
					ON MM.MeasureID = MX.MeasureID AND
						DE.MetricAbbrev = MX.Abbrev
	WHERE	(DE.IdssElementID IN (SELECT IdssElementID FROM INSERTED));

END
GO
ALTER TABLE [Ncqa].[IDSS_DataElements] ADD CONSTRAINT [CK_Ncqa_IDSS_DataElements_FromAge] CHECK (([FromAgeMonths] IS NULL AND [FromAgeYears] IS NULL OR [FromAgeMonths] IS NOT NULL AND [FromAgeYears] IS NOT NULL))
GO
ALTER TABLE [Ncqa].[IDSS_DataElements] ADD CONSTRAINT [CK_Ncqa_IDSS_DataElements_ToAge] CHECK (([ToAgeMonths] IS NULL AND [ToAgeYears] IS NULL OR [ToAgeMonths] IS NOT NULL AND [ToAgeYears] IS NOT NULL))
GO
ALTER TABLE [Ncqa].[IDSS_DataElements] ADD CONSTRAINT [PK_IDSS_DataElements] PRIMARY KEY CLUSTERED  ([IdssElementID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IDSS_DataElements] ON [Ncqa].[IDSS_DataElements] ([IdssMeasure], [IdssElementAbbrev], [MeasureSetID], [BitProductLines]) ON [PRIMARY]
GO
