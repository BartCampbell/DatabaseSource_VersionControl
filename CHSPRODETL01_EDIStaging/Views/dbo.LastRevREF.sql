SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevREF]
AS
select *
from [dbo].[REF] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[REF] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
