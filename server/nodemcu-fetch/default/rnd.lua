rnd = {}

local previous, next, modulus, multiplier, increment = 0, 0, 2^31 - 1, 48271, 0

function rnd.seed(seed)
  previous = seed or 0
  next = 0
end

function rnd.random(min, max)
  next = (multiplier * previous + increment) % modulus
  local rand = (next % (modulus - 1 + 1)) + 1
  previous = next

  local p = rand / modulus;
  p = p * ((max or 1) - (min or 0))
  return (min or 0) + p
end

rnd.seed(node.heap())
