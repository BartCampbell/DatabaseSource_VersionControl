CREATE TABLE [dbo].[L_SuspectProject]
(
[L_SuspectProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Project_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectProject] ADD CONSTRAINT [PK_L_SuspectProject] PRIMARY KEY CLUSTERED  ([L_SuspectProject_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectProject] ADD CONSTRAINT [FK_H_Project_RK2] FOREIGN KEY ([H_Project_RK]) REFERENCES [dbo].[H_Project] ([H_Project_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_SuspectProject] ADD CONSTRAINT [FK_H_Suspect_RK1] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
