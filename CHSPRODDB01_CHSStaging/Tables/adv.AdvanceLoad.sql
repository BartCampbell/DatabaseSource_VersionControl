CREATE TABLE [adv].[AdvanceLoad]
(
[LoadKey] [int] NOT NULL IDENTITY(1, 1),
[TableType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunOrder] [int] NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__AdvanceLo__Creat__07A45AFB] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF__AdvanceLo__LastU__08987F34] DEFAULT (getdate())
) ON [PRIMARY]
GO
