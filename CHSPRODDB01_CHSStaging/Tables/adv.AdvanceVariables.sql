CREATE TABLE [adv].[AdvanceVariables]
(
[AVKey] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__AdvanceVa__Creat__7D26CC88] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF__AdvanceVa__LastU__7E1AF0C1] DEFAULT (getdate()),
[SchemaType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableList] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
