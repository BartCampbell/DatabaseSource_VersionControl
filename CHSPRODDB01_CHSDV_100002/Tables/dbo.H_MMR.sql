CREATE TABLE [dbo].[H_MMR]
(
[H_MMR_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MMR_BK] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sequence] [int] NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_MMR] ADD CONSTRAINT [PK_H_MMR] PRIMARY KEY CLUSTERED  ([H_MMR_RK]) ON [PRIMARY]
GO
