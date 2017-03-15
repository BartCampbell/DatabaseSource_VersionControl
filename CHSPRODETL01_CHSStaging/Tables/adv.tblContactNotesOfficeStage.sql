CREATE TABLE [adv].[tblContactNotesOfficeStage]
(
[ContactNotesOffice_PK] [int] NOT NULL,
[Project_PK] [smallint] NULL,
[Office_PK] [bigint] NULL,
[ContactNote_PK] [smallint] NULL,
[ContactNoteText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[contact_num] [tinyint] NULL CONSTRAINT [DF__tblContac__conta__46D27B73] DEFAULT ((1)),
[followup] [date] NULL,
[IsResponded] [bit] NULL,
[IsViewedByScheduler] [bit] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblContac__LoadD__4CACE708] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNotesOfficeHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CNI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblContactNotesOfficeStage] ADD CONSTRAINT [PK_tblContactNotesOfficeStage] PRIMARY KEY CLUSTERED  ([ContactNotesOffice_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
