# Time Parser

[![Build Status](https://travis-ci.org/philipbl/time-parser.svg?branch=master)](https://travis-ci.org/philipbl/time-parser)

Time parser is a small utility for parsing time statements written in [Racket](http://racket-lang.org). I made this out of the need to calculate how many hours I worked. Simple time ranges are easy, but once you start having to subtract a 45 minute lunch and add in 20 minutes that you worked at home that morning, it starts getting annoying. To get some practice with writing lexers and parsers, I created a small language, that I call "time statements".

## Grammar
I'm not an expert in defining grammars (any suggestions would be appreciated), but here is what I came up with. Use this grammar to define a time statement.

```
<STATEMENT>     : <ABS_STATEMENT> (<OPERATOR> <STATEMENT>)*
                | <REL_STATEMENT> (<OPERATOR> <STATEMENT>)*
<ABS_STATEMENT> : <ABS_TIME> <JOINER> <ABS_TIME>
<ABS_TIME>      : <HOUR>:<MINUTE> <DAY>
<REL_STATEMENT> : <REL_TIME>
<REL_TIME>      : <REL_TIME_NUM> <REL_TIME_DES>
<REL_TIME_DES>  : minutes | minute | mins | min | m | hours | hour | h
<REL_TIME_NUM>  : <DIGIT>+ (<REL_TIME_FRAC>)?
<REL_TIME_FRAC> : .<DIGIT>*
<OPERATOR>      : - | +
<HOUR>          : 1[0-2]
                | 0[1-9]
                | [1-9]
<MINUTE>        : [0-5][0-9]
<DAY>           : AM | PM
<JOINER>        : to
```

There are two major time components: absolute time statements and relative time statements. Absolute time statements are time ranges, such as 8:00 AM to 3:00 PM. Relative time statements are just an arbitrary amount of time, such as 1 hour or 24 minute. Absolute and relative time statements can be combined together using `+` or `-`.

## Usage

There are two ways of using the time parser. You can pass in a time statement through command line parameters or through `stdin`.

```
$ racket time-parser.rkt 9:00 AM to 5:00 PM
=> 8.0 hours
```

```
$ racket time-parser.rkt 
9:00 AM to 5:00 PM
=> 8.0 hours
```

## Examples

```
$ racket time-parser.rkt 23 minutes + 9:00 AM to 5:00 PM - 42 min
=> 7.683333333333334 hours
```

```
$ racket time-parser.rkt 8:00 AM to 11:00 AM + 1:21 PM to 6:05 PM
=> 7.733333333333333 hours
```

```
$ racket time-parser.rkt 9:00 AM to 5:00 PM - 12:06 PM to 1:10 PM
=> 6.933333333333334 hours
```
