{ChartTime, ChartTimeIterator, ChartTimeRange, utils} = require('../')


# !TODO: Needs testing of skip functionality

exports.ChartTimeIteratorTest =
  setUp: (callback) ->
    @i = new ChartTimeIterator({
      start:new ChartTime({granularity: 'day', year: 2011, month:1, day: 1}),
      pastEnd:new ChartTime({granularity: 'day', year: 2011, month:1, day: 7})
    })
    
    callback()
    
  testNextAndHasNext: (test) ->
    f = () ->
      i2 = new ChartTimeIterator({
        start:new ChartTime({granularity: 'day', year: 2011, month:1, day: 1}),
        pastEnd:new ChartTime({granularity: 'day', year: 2011, month:1, day: 1})
      })
      i2.next()

    StopIteration = if typeof(StopIteration) is 'undefined' then utils.StopIteration else StopIteration
    test.throws(f, StopIteration, 'should throw on calling next() when hasNext() is false')

    i2 = new ChartTimeIterator({
      start:new ChartTime({granularity: 'day', year: 2011, month:1, day: 1}),
      pastEnd:new ChartTime({granularity: 'day', year: 2011, month:1, day: 10}),
      workDays: 'Monday ,   Wednesday, Thursday ,Saturday',
      holidays: [
        {month: 12, day: 25},
        {month: 1, day: 1},
        {month: 7, day: 4},
        {year: 2011, month: 11, day: 24}  # Thanksgiving 2011
      ]
    })

    temp = i2.next()
    test.equal(temp.dowString(), 'Monday', 'Should be Monday because 01-01 is a holiday and Sunday is not a workday')

    temp = i2.next()
    test.equal(temp.dowString(), 'Wednesday', 'Should be Wednesday')

    temp = i2.next()
    test.equal(temp.dowString(), 'Thursday', 'Should be Thursday')

    temp = i2.next()
    test.equal(temp.dowString(), 'Saturday', 'Should be Saturday again')

    test.equal(i2.hasNext(), false, 'Should be no more because the 2011-01-09 is Sunday which is not a workDay')

    test.done()

  testIterator: (test) ->
    spec = {
      start:new ChartTime({granularity: 'day', year: 2011, month:1, day: 1}),
      pastEnd:new ChartTime({granularity: 'day', year: 2011, month:1, day: 10}),
      workDays: 'Monday ,   Wednesday, Thursday ,Saturday',
      holidays: [
        {month: 12, day: 25},
        {month: 1, day: 1},
        {month: 7, day: 4},
        {year: 2011, month: 11, day: 24}  # Thanksgiving 2011
      ]
    }

    i2 = new ChartTimeIterator(spec)
    while (i2.hasNext())
      i2.next()
    test.equal(i2.count, 4, 'i2.count expected to be 4, got: ' + i2.count)

    all = i2.getAll()

    spec.skip = -1
    i2 = new ChartTimeIterator(spec)
    test.deepEqual(i2.getAll(), all.reverse(), 'should be the same in reverse')

    all.reverse()
    delete spec.skip
    pastEnd = spec.pastEnd
    delete spec.pastEnd
    spec.limit = 4
    i2 = new ChartTimeIterator(spec)
    test.deepEqual(i2.getAll(), all, 'should be the same with limit')

    spec.pastEnd = pastEnd
    start = spec.start
    delete spec.start
    spec.limit = 4
    spec.skip = -1
    i2 = new ChartTimeIterator(spec)
    test.deepEqual(i2.getAll(), all.reverse(), 'should be the same in reverse')

    test.done()

  testHours: (test) ->
    spec = {
      start: new ChartTime({granularity: 'hour', year: 2011, month:1, day: 3, hour: 14}),
      pastEnd: new ChartTime('2011-01-04T22'),
      startWorkTime: {hour: 9, minute: 0},
      pastEndWorkTime: {hour: 17, minute: 0}
    }
    i2 = new ChartTimeIterator(spec)

    test.equal(i2.getAll().length, 11, 'should be 11 work hours between these two ChartTimes')

    test.done()
    
  testHoursNightShift: (test) ->
    spec = {
      start: new ChartTime({granularity: 'hour', year: 2011, month:1, day: 3, hour: 20}),
      pastEnd: new ChartTime(granularity: 'hour', hour: 8, year:2011, month:1, day:4)
      startWorkTime: {hour: 23, minute: 0},
      pastEndWorkTime: {hour: 8, minute:0}
    }
    i2 = new ChartTimeIterator(spec)
    test.equal(i2.getAll().length, 8, 'should be 8 work hours from 11pm til 7am')
    
    test.done()
    
   testHoursSpanDays: (test) ->
    spec = {
      start: new ChartTime({granularity: 'hour', year: 2011, month:1, day: 3, hour: 7}),
      pastEnd: new ChartTime(granularity: 'hour', year:2011, month:1, day:4, hour: 23)
      startWorkTime: {hour: 8, minute: 0},
      pastEndWorkTime: {hour: 18, minute:0}
    }
    i2 = new ChartTimeIterator(spec)
    test.equal(i2.getAll().length, 20, 'should be 20 work hours')
    
    test.done()    
    
  testHoursSpanWeeks: (test) ->
    spec = {
      start: new ChartTime(granularity:'hour', year: 2011, month: 12, day: 30, hour: 1),
      pastEnd: new ChartTime(granularity: 'hour', year: 2012, month: 1, day: 3, hour: 1)
    }
    i2 = new ChartTimeIterator(spec)
    test.equal(i2.getAll().length, 48)  
    test.done()
  
  testWorkHours: (test) ->
    spec = {
      start: new ChartTime(granularity: 'hour', year: 2012, month: 2, day: 1, hour: 5),
      pastEnd: new ChartTime(granularity: 'hour', year: 2012, month: 2, day: 5, hour: 23)
      startWorkTime: {hour: 10, minute: 30}
      pastEndWorkTime: {hour: 12, minute: 30}
    }
    i2 = new ChartTimeIterator(spec)
    test.equal(i2.getAll().length, 6)
    test.done()
  
  testMinutes: (test) ->
    spec = {
      start: new ChartTime({granularity: 'minute', year: 2011, month:1, day: 3, hour: 14, minute: 23}),
      pastEnd: new ChartTime('2011-01-04T22:23'),
      startWorkTime: {hour: 9, minute: 30},
      pastEndWorkTime: {hour: 17, minute: 15}
    }
    i2 = new ChartTimeIterator(spec)

    test.equal(i2.getAll().length, 11*60 + 2*15 - 30 - 23, "should be #{11*60 + 2*15 - 30 - 23} work minutes between these two ChartTimes")

    test.done()
    
  testMinutesSpanDays: (test) ->
    spec = {
    	start: new ChartTime(granularity: 'minute', year: 2012, month:1, day: 17, hour: 12, minute: 0)
    	pastEnd: new ChartTime(granularity: 'minute', year: 2012, month: 1, day: 18, hour: 12, minute: 0)
    }
    i2 = new ChartTimeIterator(spec)
    test.equal(i2.getAll().length, 1440)
    test.done()
    
  testMinutesSpanWeeks: (test) ->
    spec = {
    	start: new ChartTime(granularity: 'minute', year: 2012, month:1, day: 20, hour: 12, minute: 0)
    	pastEnd: new ChartTime(granularity: 'minute', year: 2012, month: 1, day: 23, hour: 12, minute: 0)
    }
    i2 = new ChartTimeIterator(spec)
    test.equal(i2.getAll().length, 1440)
    test.done()    
  
  testMilliseconds: (test) ->
    spec = {
      start: new ChartTime(granularity: 'millisecond', year: 2011, month:1, day: 3, hour: 14, minute: 23, second: 45, millisecond: 900),
      pastEnd: new ChartTime(granularity: 'millisecond', year: 2011, month:1, day:3, hour: 14, minute: 23, second: 46, millisecond: 5),
    }
    i2 = new ChartTimeIterator(spec)

    test.equal(i2.getAll().length, 105)
    test.done()  
 
  testQuarter: (test) ->
    spec = {
      start: new ChartTime({granularity: 'quarter', year: 2011, quarter:1}),
      pastEnd: new ChartTime('2013Q3'),
    }
    i2 = new ChartTimeIterator(spec)

    test.equal(i2.getAll().length, 10, 'should be 10 quarters between these two ChartTimes')

    test.done()

  testDow: (test) ->
    spec = {
      start: new ChartTime('2008W52-3'),
      pastEnd: new ChartTime(granularity: 'week_day', year: 2011, week: 3, week_day: 3),
      holidays: [
        {month: 12, day: 25},
        {month: 1, day: 1},
        {month: 7, day: 4},
        {year: 2011, month: 11, day: 24}  # Thanksgiving 2011
      ]
    }
    i2 = new ChartTimeIterator(spec)

    test.equal(i2.getAll().length, 107 * 5 + 3 + 2 - 4, "should be #{107*5 + 3 + 2 - 4} days between these two ChartTimes")

    test.done()
    
  testWeeks: (test) ->
    spec = {
      start: new ChartTime('2008W52'),
      pastEnd: new ChartTime(granularity: 'week', year: 2011, week: 3),
    }
    i2 = new ChartTimeIterator(spec)

    test.equal(i2.getAll().length, 108, 'should be #{108} days between these two ChartTimes')

    test.done()
    
  testDaysSpanYears: (test) ->
    spec = {
       start: new ChartTime('2010-12-30'),
       pastEnd: new ChartTime('2011-01-15')
    }
    i2 = new ChartTimeIterator(spec)
    test.equal(i2.getAll().length, 12)
    test.done()
    
  testWeeksSpanYears: (test) ->
    spec = {
       start: new ChartTime('2010-11-30').inGranularity('week'),  # Could just do new ChartTime('2010W48')
       pastEnd: new ChartTime('2011-01-15').inGranularity('week') # '2011W02'
    }
    i2 = new ChartTimeIterator(spec)
    test.equal(i2.getAll().length, 6) # I think 6 is correct. Remember weeks start on Monday.
    test.done()   
   
  testDaysSpanMonths: (test) ->
    spec = {
     	start: new ChartTime('2011-01-15')
     	pastEnd: new ChartTime('2011-02-15')
    }
    i2 = new ChartTimeIterator(spec)
    test.equal(i2.getAll().length, 21)
    test.done()
    
  testDaysSpanWeeks: (test) ->
    spec = {
    	start: new ChartTime('2011-05-05')
    	pastEnd: new ChartTime('2011-05-25')
    }
    i2 = new ChartTimeIterator(spec)
    test.equal(i2.getAll().length, 14)
    test.done()
   
#    testMonthsSpanQuarters: (test) ->  # Commented out because month is not yet a sub-granularity to quarter. It stops at quarter right now. Maybe will upgrade later.
#      spec = {
#      	start: new ChartTime('2011-02-01'),
#      	pastEnd: new ChartTime('2011-07-01')
#      }
#    	 i2 = new ChartTimeIterator(spec)
#    	 test.equal(i2.getAll().length, 6)
#    	 test.done()
   
   
   testQuartersSpanYears: (test) ->
     spec = {
     	start: new ChartTime('2011-10-01').inGranularity('quarter'),  # Could just do new ChartTime('2011Q3')
     	pastEnd: new ChartTime('2012-04-01').inGranularity('quarter')
     }
     i2 = new ChartTimeIterator(spec)
     test.equal(i2.getAll().length, 2)
     test.done()  
     
  testThrows: (test) ->
    spec = {
      start:new ChartTime({granularity: 'day', year: 2011, month:1, day: 1}),
      pastEnd:new ChartTime({granularity: 'day', year: 2011, month:1, day: 10}),
      workDays: 'Monday ,   Wednesday, Thursday ,Saturday',
      holidays: [
        {month: 12, day: 25},
        {month: 1, day: 1},
        {month: 7, day: 4},
        {year: 2011, month: 11, day: 24}  # Thanksgiving 2011
      ]
    }

    f = () ->
      i3 = new ChartTimeIterator(spec)

    pastEnd = spec.pastEnd
    delete spec.pastEnd
    test.throws(f, utils.AssertException, 'should throw with only start')

    spec.limit = 10
    spec.skip = -1
    test.throws(f, utils.AssertException, 'should throw when no pastEnd and skip is negative')

    start = spec.start
    delete spec.start
    delete spec.limit
    test.throws(f, Error, 'should throw with no start, pastEnd, limit')

    spec.pastEnd = pastEnd
    spec.limit = 10
    spec.skip = 1
    test.throws(f, utils.AssertException, 'should throw when no start and skip is positive')

    test.done()