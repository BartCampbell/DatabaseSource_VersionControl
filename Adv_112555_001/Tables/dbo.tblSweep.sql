CREATE TABLE [dbo].[tblSweep]
(
[SweepYear] [smallint] NULL,
[Sweep] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SweepDeadline] [date] NULL,
[ID] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
