SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevHD]
AS
select *
from [dbo].[HD] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[HD] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
