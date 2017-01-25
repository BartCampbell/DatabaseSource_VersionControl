CREATE TABLE [Measure].[MemberMonths]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MbrMonthGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MemberMonths_MbrMonthGuid] DEFAULT (newid()),
[MbrMonthID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[MemberMonths] ADD CONSTRAINT [PK_MemberMonths] PRIMARY KEY CLUSTERED  ([MbrMonthID]) ON [PRIMARY]
GO
