CREATE TABLE [Log].[Changes]
(
[ChngTypeID] [tinyint] NOT NULL CONSTRAINT [DF_Changes_ChngTypeID] DEFAULT ((1)),
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_Changes_IsEnabled] DEFAULT ((1)),
[LogDate] [datetime] NOT NULL CONSTRAINT [DF_Changes_LogDate] DEFAULT (getdate()),
[LogGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Changes_LogGuid] DEFAULT (newid()),
[LogID] [smallint] NOT NULL IDENTITY(1, 1),
[LogUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Changes_LogUser] DEFAULT (suser_sname())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Log].[Changes] ADD CONSTRAINT [CK_Log_Changes_Antiscripting] CHECK ((NOT [Comments] like '%<script>%' AND NOT [Comments] like '%</script>%'))
GO
ALTER TABLE [Log].[Changes] ADD CONSTRAINT [PK_Log_Changes] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
