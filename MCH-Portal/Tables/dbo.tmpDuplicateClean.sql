CREATE TABLE [dbo].[tmpDuplicateClean]
(
[member_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Encounter_PK] [float] NULL,
[tasked_user_pk] [float] NULL,
[query_text] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[task_text] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[response_text] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QueryResponse_pk] [float] NULL,
[updated_User_PK] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated_date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[denial_text] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCodedPosted] [float] NULL
) ON [PRIMARY]
GO
