CREATE TABLE [dbo].[tmpQueryDuplicationBeforeCLean]
(
[Encounter_PK] [bigint] NOT NULL,
[tasked_user_pk] [smallint] NULL,
[query_text] [varchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[task_text] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[response_text] [varchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QueryResponse_pk] [tinyint] NULL,
[updated_User_PK] [smallint] NULL,
[updated_date] [smalldatetime] NULL,
[denial_text] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCodedPosted] [bit] NOT NULL
) ON [PRIMARY]
GO
