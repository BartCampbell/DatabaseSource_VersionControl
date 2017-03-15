SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevN1]
AS
select *
from [dbo].[N1] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[N1] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
