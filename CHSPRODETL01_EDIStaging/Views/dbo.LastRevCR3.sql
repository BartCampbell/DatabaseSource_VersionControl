SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCR3]
AS
select *
from [dbo].[CR3] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CR3] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
