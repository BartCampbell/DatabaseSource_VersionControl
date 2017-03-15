SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevFC]
AS
select *
from [dbo].[FC] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[FC] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
