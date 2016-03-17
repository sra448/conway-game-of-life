conway = require "../src/conway-logic.ls"
that-it = it

paul-callahans-pattern =  "XXX-X\n
                           X----\n
                           ---XX\n
                           -XX-X\n
                           X-X-X"

# should be its own suite, for not slowing down functional tests
describe "conway performance", ->

  # takes about 12 seconds on my xps 13
  that-it "computes a paul callahans infinite pattern to the 1000th tick in less than 20 seconds", ->
    time-start = new Date

    p = conway.read paul-callahans-pattern
    for x to 1000
      p = conway.tick p

    expect (new Date) - time-start
      .to-be-less-than 20 * 1000
