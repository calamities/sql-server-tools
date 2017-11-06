
-- =============================================
-- Author: Cal Walsman
-- Create date: 2017-10-30
-- Description:
-- Creates a user defined table value function
-- that outputs a calendar table based on a
-- start and end date.
-- =============================================

alter FUNCTION dbo.udf_HotDate (@datestart datetime2, @dateend datetime2)
RETURNS @calendar TABLE (
  [day] int,
  [date] datetime2,
  [dayofweek] int,
  [isweekday] bit,
  [month] varchar(50),
  [ismonth] bit
)
AS

BEGIN

  DECLARE @rows int
  DECLARE @i int = 1

  SELECT
    @rows = DATEDIFF(DAY, @datestart, @dateend)

  WHILE (@i <= @rows)
  BEGIN

    INSERT INTO @calendar ([day])
      VALUES (@i)

    SET @i = @i + 1

  END

 UPDATE a
  SET [date] = DATEADD(DAY, [day] - 1, @datestart), dayofweek=datepart(dw,DATEADD(day,day-1,@datestart)),isweekday = case when datepart(dw,DATEADD(day,day-1,@datestart)) not in(7,1) then 1 else 0 end, month = datepart(mm,DATEADD(day,day-1,@datestart)), ismonth = case when datepart(d,DATEADD(day,day-1,@datestart)) =1 then 1 else 0 end
  --select *, DATEADD(day,day-1,@datestart), datepart(dw,DATEADD(day,day-1,@datestart)), case when datepart(d,DATEADD(day,day-1,@datestart)) =1 then datepart(mm,DATEADD(day,day-1,@datestart)) else 0 end
  FROM @calendar a


  RETURN
END
