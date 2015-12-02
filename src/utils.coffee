# Utility random stuff, probably refactor out at some point
randInt = (max) ->
  max = Math.floor(max)
  # Between zero and max, exclusive
  Math.floor Math.random() * max

randIndex = (ary) ->
  randInt ary.length

randFromArray = (ary) ->
  index = randIndex(ary)
  return ary[index]

takeRandFromArray = (ary) ->
  chosen_index = randIndex ary
  ary.splice(chosen_index, 1)[0]

# And also, Javascript modulo doesn't behave the way I want
# Credit to http://javascript.about.com/od/problemsolving/a/modulobug.htm
# This behaves like python's num1 % num2
mod = (num1, num2) ->
  return ((num1%num2)+num2)%num2;

module.exports =
  randInt: randInt,
  randIndex: randIndex,
  randFromArray: randFromArray,
  takeRandFromArray: takeRandFromArray,
  mod: mod,
