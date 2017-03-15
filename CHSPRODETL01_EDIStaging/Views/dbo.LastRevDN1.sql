SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevDN1]
AS
select *
from [dbo].[DN1] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[DN1] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
