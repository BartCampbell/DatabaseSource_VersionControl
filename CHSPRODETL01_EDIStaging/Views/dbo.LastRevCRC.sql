SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCRC]
AS
select *
from [dbo].[CRC] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CRC] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
