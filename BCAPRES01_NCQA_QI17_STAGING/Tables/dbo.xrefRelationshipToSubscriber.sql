CREATE TABLE [dbo].[xrefRelationshipToSubscriber]
(
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClientValue] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StandardValue] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StandardDescription] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
