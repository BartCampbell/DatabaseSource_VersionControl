SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevBGN]
AS
select *
from [dbo].[BGN] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[BGN] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
