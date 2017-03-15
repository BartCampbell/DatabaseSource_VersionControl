SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevREL]
AS
select *
from [dbo].[REL] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[REL] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
