SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevINS]
AS
select *
from [dbo].[INS] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[INS] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
