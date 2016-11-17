CREATE TABLE [dbo].[L_Member_MMR]
(
[L_Member_MMR_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_MMR_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_Member_MMR] ADD CONSTRAINT [PK_L_Member_MMR] PRIMARY KEY CLUSTERED  ([L_Member_MMR_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_Member_MMR] ADD CONSTRAINT [FK_L_Member_MMR_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
ALTER TABLE [dbo].[L_Member_MMR] ADD CONSTRAINT [FK_L_Member_MMR_H_MMR] FOREIGN KEY ([H_MMR_RK]) REFERENCES [dbo].[H_MMR] ([H_MMR_RK])
GO
