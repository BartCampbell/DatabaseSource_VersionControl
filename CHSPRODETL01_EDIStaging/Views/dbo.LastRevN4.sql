SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevN4]
AS
select *
from [dbo].[N4] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[N4] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
