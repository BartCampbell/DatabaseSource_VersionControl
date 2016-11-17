CREATE TABLE [dbo].[L_OECProjectOEC]
(
[L_OECProjectOEC_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OECProject_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OEC_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL CONSTRAINT [DF_L_OECProjectOEC_LoadDate] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECProjectOEC] ADD CONSTRAINT [PK_L_OECProjectOEC] PRIMARY KEY CLUSTERED  ([L_OECProjectOEC_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECProjectOEC] ADD CONSTRAINT [FK_L_OECProjectOEC_H_OEC] FOREIGN KEY ([H_OEC_RK]) REFERENCES [dbo].[H_OEC] ([H_OEC_RK])
GO
ALTER TABLE [dbo].[L_OECProjectOEC] ADD CONSTRAINT [FK_L_OECProjectOEC_H_OECProject] FOREIGN KEY ([H_OECProject_RK]) REFERENCES [dbo].[H_OECProject] ([H_OECProject_RK])
GO
