CREATE TABLE [Measure].[DateComparers]
(
[DateComparerGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_DateComparers_DateComparerGuid] DEFAULT (newid()),
[DateComparerID] [smallint] NOT NULL,
[DateCompTypeID] [tinyint] NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsBeginDate] [bit] NOT NULL CONSTRAINT [DF_DateComparers_IsBeginDate] DEFAULT ((0)),
[IsEndDate] [bit] NOT NULL CONSTRAINT [DF_DateComparers_IsEndDate] DEFAULT ((0)),
[IsInit] [bit] NOT NULL CONSTRAINT [DF_DateComparers_Allow1stRank] DEFAULT ((0)),
[IsInverse] [bit] NOT NULL CONSTRAINT [DF_DateComparers_IsInverse] DEFAULT ((0)),
[IsLinked] [bit] NOT NULL CONSTRAINT [DF_DateComparers_IsLinked] DEFAULT ((0)),
[IsSeed] [bit] NOT NULL CONSTRAINT [DF_DateComparers_IsSeed] DEFAULT ((0)),
[IsValid] AS (CONVERT([bit],case  when object_id((((quotename(db_name())+'.')+quotename([procschema]))+'.')+quotename([procname])) IS NOT NULL then (1) else (0) end,(0))),
[ProcName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[DateComparers] ADD CONSTRAINT [PK_DateComparers] PRIMARY KEY CLUSTERED  ([DateComparerID]) ON [PRIMARY]
GO
