CREATE TABLE [Measure].[DateComparerTypes]
(
[Abbrev] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCompTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_DateComparerTypes_DateCompTypeGuid] DEFAULT (newid()),
[DateCompTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[DateComparerTypes] ADD CONSTRAINT [PK_DateComparerTypes] PRIMARY KEY CLUSTERED  ([DateCompTypeID]) ON [PRIMARY]
GO
