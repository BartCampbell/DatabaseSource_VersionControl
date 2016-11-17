CREATE TABLE [dbo].[H_Suspect]
(
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Suspect_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientSuspectID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Suspect] ADD CONSTRAINT [PK_H_Suspect] PRIMARY KEY CLUSTERED  ([H_Suspect_RK]) ON [PRIMARY]
GO
