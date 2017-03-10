CREATE TABLE [dbo].[AbstractionReviewSet]
(
[AbstractionReviewSetID] [int] NOT NULL IDENTITY(1, 1),
[StartDate] [smalldatetime] NOT NULL,
[EndDate] [smalldatetime] NOT NULL,
[SelectionPercentage] [decimal] (8, 6) NOT NULL,
[SelectionCriteria] [xml] NULL,
[Finalized] [bit] NOT NULL CONSTRAINT [DF_AbstractionReviewSet_Finalized] DEFAULT ((0)),
[HasDataEntry] [bit] NULL,
[IsCompliant] [bit] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_AbstractionReviewSet_CreatedDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_AbstractionReviewSet_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SelectAllComponents] [bit] NOT NULL CONSTRAINT [DF__Abstracti__Selec__10A1534B] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionReviewSet] ADD CONSTRAINT [PK_AbstractionReviewSet] PRIMARY KEY CLUSTERED  ([AbstractionReviewSetID]) ON [PRIMARY]
GO
