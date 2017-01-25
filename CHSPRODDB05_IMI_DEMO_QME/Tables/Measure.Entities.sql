CREATE TABLE [Measure].[Entities]
(
[AgeAsOfDays] [smallint] NULL,
[AgeAsOfMonths] [smallint] NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_MeasureEntities_IsEnabled] DEFAULT ((1)),
[IsSummarized] [bit] NOT NULL CONSTRAINT [DF_Entities_IsSummarized] DEFAULT ((1)),
[IsNonSuppPrioritized] [bit] NOT NULL CONSTRAINT [DF_Entities_IsNonSupplementalPrioritized] DEFAULT ((1)),
[Iteration] [tinyint] NOT NULL CONSTRAINT [DF_Entities_Iteration] DEFAULT ((1)),
[EntityGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureEntities_MeasEntityGuid] DEFAULT (newid()),
[EntityID] [int] NOT NULL IDENTITY(1, 1),
[EntityTypeID] [tinyint] NOT NULL CONSTRAINT [DF_Entities_EntityTypeID] DEFAULT ((1)),
[HasEnrollment] AS ([Measure].[HasEntityEnrollment]([EntityID])),
[MaxCount] [int] NULL,
[MaxEnrollGaps] [int] NULL,
[MeasureSetID] [int] NOT NULL,
[ReqAllEnrollSegInProdLines] [bit] NOT NULL CONSTRAINT [DF_Entities_ReqAllEnrollSegInProdLines] DEFAULT ((0)),
[UniqueDescr] AS (CONVERT([varchar](164),left((replace(CONVERT([varchar](36),[EntityGuid],(0)),'-','')+' - ')+[Descr],(164)),(0))) PERSISTED
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[Entities] ADD CONSTRAINT [CK_Entities_AgeAsOf] CHECK (([AgeAsOfDays] IS NOT NULL AND [AgeAsOfMonths] IS NOT NULL OR [AgeAsOfDays] IS NULL AND [AgeAsOfMonths] IS NULL))
GO
ALTER TABLE [Measure].[Entities] ADD CONSTRAINT [PK_MeasureEntities] PRIMARY KEY CLUSTERED  ([EntityID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Entities_UniqueDescr] ON [Measure].[Entities] ([UniqueDescr]) ON [PRIMARY]
GO
