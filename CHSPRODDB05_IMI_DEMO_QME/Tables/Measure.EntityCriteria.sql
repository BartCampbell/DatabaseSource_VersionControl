CREATE TABLE [Measure].[EntityCriteria]
(
[AfterDOBDays] [smallint] NOT NULL CONSTRAINT [DF_EntityCriteria_AfterDOBDays] DEFAULT ((0)),
[AfterDOBMonths] [smallint] NOT NULL CONSTRAINT [DF_EntityCriteria_AfterDOBMonths] DEFAULT ((0)),
[Allow] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_Allow] DEFAULT ((1)),
[AllowActiveScript] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_AllowActiveScript] DEFAULT ((1)),
[AllowAdmitPreDOB] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_AllowAdmitPreDOB] DEFAULT ((0)),
[AllowBeginDate] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_AllowBeginDate] DEFAULT ((1)),
[AllowEndDate] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_AllowEndDate] DEFAULT ((1)),
[AllowEnrollSeg] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_AllowEnrollSeg] DEFAULT ((1)),
[AllowServDate] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_AllowServDate] DEFAULT ((1)),
[AllowSupplemental] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_AllowSupplemental] DEFAULT ((0)),
[AllowXfers] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_AllowXfers] DEFAULT ((1)),
[BeginDays] [smallint] NULL,
[BeginEnrollSegDays] [smallint] NULL,
[BeginEnrollSegMonths] [smallint] NULL,
[BeginMonths] [smallint] NULL,
[DateComparerID] [smallint] NOT NULL,
[DateComparerInfo] [int] NOT NULL,
[DateComparerLink] [int] NULL,
[DaysMax] [smallint] NULL,
[DaysMin] [smallint] NULL,
[EndDays] [smallint] NULL,
[EndEnrollSegDays] [smallint] NULL,
[EndEnrollSegMonths] [smallint] NULL,
[EndMonths] [smallint] NULL,
[EntityCritGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EntityCriteria_EntityCritGuid] DEFAULT (newid()),
[EntityCritID] [int] NOT NULL IDENTITY(1, 1),
[EntityID] [int] NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_IsEnabled] DEFAULT ((1)),
[IsForIndex] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_IsForIndex] DEFAULT ((1)),
[IsInit] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_IsInit] DEFAULT ((0)),
[OptionNbr] [tinyint] NOT NULL,
[QtyComparerID] [tinyint] NULL,
[QtyMax] [decimal] (12, 6) NULL,
[QtyMin] [decimal] (12, 6) NULL CONSTRAINT [DF_EntityCriteria_QtyMin] DEFAULT ((1)),
[RankOrder] [smallint] NULL,
[RequireDiffProvider] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_RequireDiffProvider] DEFAULT ((0)),
[RequirePaid] [bit] NOT NULL CONSTRAINT [DF_EntityCriteria_RequirePaid] DEFAULT ((0)),
[ValueMax] [decimal] (18, 6) NULL,
[ValueMin] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EntityCriteria] ADD CONSTRAINT [PK_MeasureCriteria] PRIMARY KEY CLUSTERED  ([EntityCritID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MeasureCriteria_MeasPopID] ON [Measure].[EntityCriteria] ([EntityID]) ON [PRIMARY]
GO
