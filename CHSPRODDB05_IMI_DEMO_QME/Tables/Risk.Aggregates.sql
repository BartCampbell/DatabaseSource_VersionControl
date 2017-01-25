CREATE TABLE [Risk].[Aggregates]
(
[AggregateID] [tinyint] NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormulaPrefix] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormulaSuffix] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Risk].[Aggregates] ADD CONSTRAINT [PK_Risk_Aggregates] PRIMARY KEY CLUSTERED  ([AggregateID]) ON [PRIMARY]
GO
