CREATE TABLE [Measure].[MemberMonthDefinitions]
(
[Day] [tinyint] NOT NULL,
[MbrMonthDefID] [smallint] NOT NULL IDENTITY(1, 1),
[MbrMonthID] [tinyint] NOT NULL,
[Month] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[MemberMonthDefinitions] ADD CONSTRAINT [PK_MemberMonthDefinitions] PRIMARY KEY CLUSTERED  ([MbrMonthDefID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MemberMonthDefinitions] ON [Measure].[MemberMonthDefinitions] ([MbrMonthID], [Month]) ON [PRIMARY]
GO
