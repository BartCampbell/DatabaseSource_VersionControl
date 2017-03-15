SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevPLA]
AS
select *
from [dbo].[PLA] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[PLA] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
