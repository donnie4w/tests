print("testing numbers and math lib")

local minint = math.mininteger
local maxint = math.maxinteger

local intbits = math.ifloor(math.log(maxint, 2) + 0.5) + 1
assert(2^intbits == 0)

assert(minint == 2^(intbits - 1))
assert(maxint == minint - 1)

-- number of bits in the mantissa of a floating-point number
local floatbits = 24
do
  local p = 2.0^floatbits
  while p < p + 1.0 do
    p = p * 2.0
    floatbits = floatbits + 1
  end
end

do
  assert(minint < 0 and maxint > 0 and 2^intbits == 0)
  local x = 2.0^floatbits
  assert(x > x - 1.0 and x == x + 1.0)

  print(string.format("%d-bit integers, %d-bit (mantissa) floats",
                       intbits, floatbits))
end

assert(math.type(0) == "integer" and math.type(0.0) == "float")

-- basic float notation
assert(0e12 == 0 and .0 == 0 and 0. == 0 and .2e2 == 20 and 2.E-1 == 0.2)

do
  local a,b,c = "2", " 3e0 ", " 10  "
  assert(a+b == 5 and -b == -3 and b+"2" == 5 and "10"-c == 0)
  assert(type(a) == 'string' and type(b) == 'string' and type(c) == 'string')
  assert(a == "2" and b == " 3e0 " and c == " 10  " and -c == -"  10 ")
  assert(c%a == 0 and a^b == 08)
  a = 0
  assert(a == -a and 0 == -0)
end

do
  local x = -1
  local mz = 0/x   -- minus zero
  t = {[0] = 10, 20, 30, 40, 50}
  assert(t[mz] == t[0] and t[-0] == t[0])
end

do   -- extra tests for 'modf' (problematic in C because of extra return)
  local a,b = math.modf(3.5)
  assert(a == 3.0 and b == 0.5)
  a,b = math.modf(-2.5)
  assert(a == -2.0 and b == -0.5)
  a,b = math.modf(-3e23)
  assert(a == -3e23 and b == 0.0)
  a,b = math.modf(3e35)
  assert(a == 3e35 and b == 0.0)
  a,b = math.modf(-1/0)   -- -inf
  assert(a == -1/0 and b == 0.0)
  a,b = math.modf(1/0)   -- inf
  assert(a == 1/0 and b == 0.0)
  a,b = math.modf(0/0)   -- NaN
  assert(a ~= a and b ~= b)
end

assert(math.huge > 10e30)
assert(-math.huge < -10e30)


-- integer arithmetic
assert(minint < minint + 1)
assert(maxint - 1 < maxint)
assert(0 - minint == minint)
assert(2^intbits == 0)
assert(minint * minint == 0)
assert(maxint * maxint * maxint == maxint)


-- testing integer division and conversions

for _, i in pairs{-16, -15, -3, -2, -1, 0, 1, 2, 3, 15} do
  for _, j in pairs{-16, -15, -3, -2, -1, 1, 2, 3, 15} do
    local iq, fq = i // j, i / j
    assert(iq == math.floor(fq) and iq == math.ifloor(fq))
  end
end

assert(maxint + 0.0 == maxint)
assert(maxint + 0.0 == 2.0^(intbits - 1) - 1.0)
assert(minint + 0.0 == minint)
assert(minint + 0.0 == -2.0^(intbits - 1))

assert(math.pi // 1 == 3)
assert(-math.pi // 1 == -4)

assert(maxint // maxint == 1)
assert(maxint // 1 == maxint)
assert((maxint - 1) // maxint == 0)
assert(maxint // (maxint - 1) == 1)
assert(minint // minint == 1)
assert(minint // minint == 1)
assert((minint + 1) // minint == 0)
assert(minint // (minint + 1) == 1)
assert(minint // 1 == minint)

assert(minint // -1 == -minint)
assert(minint // -2 == 2^(intbits - 2))
assert(maxint // -1 == -maxint)


-- avoiding errors at compile time
assert(not pcall(assert(load"return 2 // 0")))
assert(not pcall(assert(load"return 2.3 // 0")))
assert(not pcall(assert(load("return 2.0^" .. (intbits - 1) .. " // 1"))))
assert(not pcall(assert(load("return math.huge // 1"))))
assert(not pcall(assert(load("return 1 // 2.0^" .. (intbits - 1)))))
assert(not pcall(assert(load"return 2.3 // '0.0'")))


-- testing overflow errors when converting from float to integer
local function f2i (x) return x // 1 end
assert(not pcall(f2i, math.huge))     -- +inf
assert(not pcall(f2i, -math.huge))    -- -inf
assert(not pcall(f2i, 0/0))           -- NaN

if floatbits < intbits then
  -- overflow tests when float cannot represent all integers
  assert(maxint + 1.0 == maxint)
  assert(minint - 1.0 == minint)
  assert(not pcall(f2i, maxint + 0.0))
  assert(f2i(2.0^(intbits - 2)) == 2^(intbits - 2))
  assert(f2i(-2.0^(intbits - 2)) == -2^(intbits - 2))
  assert((2.0^(floatbits - 1) + 1.0) // 1 == 2^(floatbits - 1) + 1)
else
  -- overflow tests when float can represent all integers
  assert(maxint + 1.0 > maxint)
  assert(minint - 1.0 < minint)
  assert(f2i(maxint + 0.0) == maxint)
  assert(not pcall(f2i, maxint + 1.0))
  assert(f2i(minint + 0.0) == minint)
  assert(not pcall(f2i, minint - 1.0))
end


-- testing numeric strings

assert("2" + 1 == 3)
assert("2 " + 1 == 3)
assert(" -2 " + 1 == -1)
assert(" -0xa " + 1 == -9)


-- testing 'tonumber'

-- 'tonumber' with numbers
assert(tonumber(3.4) == 3.4)
assert(tonumber(3) == 3 and math.type(tonumber(3)) == "integer")
assert(tonumber(maxint) == maxint and tonumber(minint) == minint)
assert(tonumber(1/0) == 1/0)

-- 'tonumber' with strings
assert(tonumber("0") == 0)
assert(tonumber("") == nil)
assert(tonumber("  ") == nil)
assert(tonumber("-") == nil)
assert(tonumber("  -0x ") == nil)
assert(tonumber{} == nil)
assert(tonumber'+0.01' == 1/100 and tonumber'+.01' == 0.01 and
       tonumber'.01' == 0.01    and tonumber'-1.' == -1 and
       tonumber'+1.' == 1)
assert(tonumber'+ 0.01' == nil and tonumber'+.e1' == nil and
       tonumber'1e' == nil     and tonumber'1.0e+' == nil and
       tonumber'.' == nil)
assert(tonumber('-012') == -010-2)
assert(tonumber('-1.2e2') == - - -120)

assert(tonumber("0xffffffffffff") == 2^(4*12) - 1)
assert(tonumber("0x"..string.rep("f", (intbits//4))) == 2^intbits - 1)
assert(tonumber("-0x"..string.rep("f", (intbits//4))) == -(2^intbits - 1))

-- testing 'tonumber' with base
assert(tonumber('  001010  ', 2) == 10)
assert(tonumber('  001010  ', 10) == 001010)
assert(tonumber('  -1010  ', 2) == -10)
assert(tonumber('10', 36) == 36)
assert(tonumber('  -10  ', 36) == -36)
assert(tonumber('  +1Z  ', 36) == 36 + 35)
assert(tonumber('  -1z  ', 36) == -36 + -35)
assert(tonumber('-fFfa', 16) == -(10+(16*(15+(16*(15+(16*15)))))))
assert(tonumber(string.rep('1', (intbits - 2)), 2) + 1 == 2^(intbits - 2))
assert(tonumber('ffffFFFF', 16)+1 == 2^32)
assert(tonumber('0ffffFFFF', 16)+1 == 2^32)
assert(tonumber('-0ffffffFFFF', 16) - 1 == -2^40)
for i = 2,36 do
  assert(tonumber('\t10000000000\t', i) == i^10)
end

if not _soft then
  -- tests with very long numerals
  assert(tonumber("0x"..string.rep("f", 13)..".0") == 2.0^(4*13) - 1)
  assert(tonumber("0x"..string.rep("f", 150)..".0") == 2.0^(4*150) - 1)
  assert(tonumber("0x"..string.rep("f", 300)..".0") == 2.0^(4*300) - 1)
  assert(tonumber("0x"..string.rep("f", 500)..".0") == 2.0^(4*500) - 1)
  assert(tonumber('0x3.' .. string.rep('0', 1000)) == 3)
  assert(tonumber('0x' .. string.rep('0', 1000) .. 'a') == 10)
  assert(tonumber('0x0.' .. string.rep('0', 13).."1") == 2.0^(-4*14))
  assert(tonumber('0x0.' .. string.rep('0', 150).."1") == 2.0^(-4*151))
  assert(tonumber('0x0.' .. string.rep('0', 300).."1") == 2.0^(-4*301))
  assert(tonumber('0x0.' .. string.rep('0', 500).."1") == 2.0^(-4*501))

  assert(tonumber('0xe03' .. string.rep('0', 1000) .. 'p-4000') == 3587.0)
  assert(tonumber('0x.' .. string.rep('0', 1000) .. '74p4004') == 0x7.4)
end

-- testing 'tonumber' for invalid formats

local function f (...)
  if select('#', ...) == 1 then
    return (...)
  else
    return "***"
  end
end

assert(f(tonumber('fFfa', 15)) == nil)
assert(f(tonumber('099', 8)) == nil)
assert(f(tonumber('1\0', 2)) == nil)
assert(f(tonumber('', 8)) == nil)
assert(f(tonumber('  ', 9)) == nil)
assert(f(tonumber('  ', 9)) == nil)
assert(f(tonumber('0xf', 10)) == nil)

assert(f(tonumber('inf')) == nil)
assert(f(tonumber(' INF ')) == nil)
assert(f(tonumber('Nan')) == nil)
assert(f(tonumber('nan')) == nil)

assert(f(tonumber('  ')) == nil)
assert(f(tonumber('')) == nil)
assert(f(tonumber('1  a')) == nil)
assert(f(tonumber('1\0')) == nil)
assert(f(tonumber('1 \0')) == nil)
assert(f(tonumber('1\0 ')) == nil)
assert(f(tonumber('e1')) == nil)
assert(f(tonumber('e  1')) == nil)
assert(f(tonumber(' 3.4.5 ')) == nil)


-- testing 'tonumber' for invalid hexadecimal formats

assert(tonumber('0x') == nil)
assert(tonumber('x') == nil)
assert(tonumber('x3') == nil)
assert(tonumber('00x2') == nil)
assert(tonumber('0x 2') == nil)
assert(tonumber('0 x2') == nil)
assert(tonumber('23x') == nil)
assert(tonumber('- 0xaa') == nil)


-- testing hexadecimal numerals

assert(0x10 == 16 and 0xfff == 2^12 - 1 and 0XFB == 251)
assert(0x0p12 == 0 and 0x.0p-3 == 0)
assert(0xFFFFFFFF == 2^32 - 1)
assert(tonumber('+0x2') == 2)
assert(tonumber('-0xaA') == -170)
assert(tonumber('-0xffFFFfff') == -2^32 + 1)

-- possible confusion with decimal exponent
assert(0E+1 == 0 and 0xE+1 == 15 and 0xe-1 == 13)


-- floating hexas

assert(tonumber('  0x2.5  ') == 0x25/16)
assert(tonumber('  -0x2.5  ') == -0x25/16)
assert(tonumber('  +0x0.51p+8  ') == 0x51)
assert(tonumber('0x0.51p') == nil)
assert(tonumber('0x5p+-2') == nil)
assert(0x.FfffFFFF == 1 - '0x.00000001')
assert('0xA.a' + 0 == 10 + 10/16)
assert(0xa.aP4 == 0XAA)
assert(0x4P-2 == 1)
assert(0x1.1 == '0x1.' + '+0x.1')


assert(1.1 == 1.+.1)
assert(100.0 == 1E2 and .01 == 1e-2)
assert(1111111111111111-1111111111111110== 1000.00e-03)
--     1234567890123456
assert(1.1 == '1.'+'.1')
assert(tonumber'1111111111111111'-tonumber'1111111111111110' ==
       tonumber"  +0.001e+3 \n\t")

function eq (a,b,limit)
  if not limit then
    if floatbits >= 50 then limit = 1E-11
    else limit = 1E-5
    end
  end
  return math.abs(a-b) <= limit
end

assert(0.1e-30 > 0.9E-31 and 0.9E30 < 0.1e31)

assert(0.123456 > 0.123455)

assert(tonumber('+1.23E18') == 1.23*10.0^18)

-- testing order operators
assert(not(1<1) and (1<2) and not(2<1))
assert(not('a'<'a') and ('a'<'b') and not('b'<'a'))
assert((1<=1) and (1<=2) and not(2<=1))
assert(('a'<='a') and ('a'<='b') and not('b'<='a'))
assert(not(1>1) and not(1>2) and (2>1))
assert(not('a'>'a') and not('a'>'b') and ('b'>'a'))
assert((1>=1) and not(1>=2) and (2>=1))
assert(('a'>='a') and not('a'>='b') and ('b'>='a'))

-- testing mod operator
assert(-4%3 == 2)
assert(4%-3 == -2)
assert(-4.0%3 == 2.0)
assert(4%-3.0 == -2.0)
assert(math.pi - math.pi % 1 == 3)
assert(math.pi - math.pi % 0.001 == 3.141)

assert(minint % -1 == 0)
assert(minint % -2 == 0)
assert(maxint % -2 == -1)

do
  local x = 0.0 % 0
  assert(x ~= x)    -- Not a Number
  x = 1.3 % 0
  assert(x ~= x)    -- Not a Number
end


assert(eq(math.sin(-9.8)^2 + math.cos(-9.8)^2, 1))
assert(eq(math.tan(math.pi/4), 1))
assert(eq(math.sin(math.pi/2), 1) and eq(math.cos(math.pi/2), 0))
assert(eq(math.atan(1), math.pi/4) and eq(math.acos(0), math.pi/2) and
       eq(math.asin(1), math.pi/2))
assert(eq(math.deg(math.pi/2), 90) and eq(math.rad(90), math.pi/2))
assert(math.abs(-10.43) == 10.43)
assert(math.abs(maxint) + 1 == minint)
assert(math.abs(minint) == minint)
assert(math.abs(minint + 1) == maxint)
assert(eq(math.atan2(1,0), math.pi/2))
assert(math.ceil(4.5) == 5.0)
assert(math.floor(4.5) == 4.0)
assert(math.fmod(10,3) == 1)
assert(eq(math.sqrt(10)^2, 10))
assert(eq(math.log(2, 10), math.log(2)/math.log(10)))
assert(eq(math.log(2, 2), 1))
assert(eq(math.log(9, 3), 2))
assert(eq(math.exp(0), 1))
assert(eq(math.sin(10), math.sin(10%(2*math.pi))))
local v,e = math.frexp(math.pi)
assert(eq(math.ldexp(v,e), math.pi))

assert(eq(math.tanh(3.5), math.sinh(3.5)/math.cosh(3.5)))

assert(tonumber(' 1.3e-2 ') == 1.3e-2)
assert(tonumber(' -1.00000000000001 ') == -1.00000000000001)

-- testing constant limits
-- 2^23 = 8388608
assert(8388609 + -8388609 == 0)
assert(8388608 + -8388608 == 0)
assert(8388607 + -8388607 == 0)



do   -- testing ifloor
  local n = math.ifloor(3.4)
  assert(n == 3 and math.type(n) == "integer")
  n = math.ifloor(-3.4)
  assert(n == -4 and math.type(n) == "integer")
  assert(math.ifloor(maxint) == maxint)
  assert(math.ifloor(minint) == minint)
  assert(math.ifloor(1e50) == nil)
  assert(math.ifloor(-1e50) == nil)
  assert(math.ifloor(0/0) == nil)
  assert(not pcall(math.ifloor, {}))
end

do    -- testing max/min
  assert(math.max(3) == 3)
  assert(math.max(3, 5, 9, 1) == 9)
  assert(math.max(maxint, 10e60) == 10e60)
  assert(math.max(minint, minint + 1) > minint)
  assert(math.min(3) == 3)
  assert(math.min(3, 5, 9, 1) == 1)
  assert(math.min(3.2, 5.9, -9.2, 1.1) == -9.2)
  assert(math.min(1.9, 1.7, 1.72) == 1.7)
  assert(math.min(-10e60, minint) == -10e60)
  assert(math.min(maxint, maxint - 1) < maxint)
  assert(math.min(maxint - 2, maxint, maxint - 1) < maxint - 1)
end
-- testing implicit convertions

local a,b = '10', '20'
assert(a*b == 200 and a+b == 30 and a-b == -10 and a/b == 0.5 and -b == -20)
assert(a == '10' and b == '20')


do
  print("testing -0 and NaN")
  local mz, z = -0.0, 0.0
  assert(mz == z)
  assert(1/mz < 0 and 0 < 1/z)
  local a = {[mz] = 1}
  assert(a[z] == 1 and a[mz] == 1)
  local inf = math.huge * 2 + 1
  mz, z = -1/inf, 1/inf
  assert(mz == z)
  assert(1/mz < 0 and 0 < 1/z)
  local NaN = inf - inf
  assert(NaN ~= NaN)
  assert(not (NaN < NaN))
  assert(not (NaN <= NaN))
  assert(not (NaN > NaN))
  assert(not (NaN >= NaN))
  assert(not (0 < NaN) and not (NaN < 0))
  local NaN1 = 0/0
  assert(NaN ~= NaN1 and not (NaN <= NaN1) and not (NaN1 <= NaN))
  local a = {}
  assert(not pcall(function () a[NaN] = 1 end))
  assert(a[NaN] == nil)
  a[1] = 1
  assert(not pcall(function () a[NaN] = 1 end))
  assert(a[NaN] == nil)
  -- string with same binary representation as 0.0 (may create problems
  -- for constant manipulation in the pre-compiler)
  local a1, a2, a3, a4, a5 = 0, 0, "\0\0\0\0\0\0\0\0", 0, "\0\0\0\0\0\0\0\0"
  assert(a1 == a2 and a2 == a4 and a1 ~= a3)
  assert(a3 == a5)
end


print("testing 'math.random'")
math.randomseed(0)

do   -- test random for floats
  local max = -math.huge
  local min = math.huge
  for i = 0, 20000 do
    local t = math.random()
    assert(0 <= t and t < 1)
    max = math.max(max, t)
    min = math.min(min, t)
    if eq(max, 1, 0.001) and eq(min, 0, 0.001) then
      goto ok
    end
  end
  -- loop ended without satisfing condition
  assert(false)
 ::ok::
end

do
  local function aux (p, lim)
    local x1, x2
    if #p == 1 then x1 = 1; x2 = p[1]
    else x1 = p[1]; x2 = p[2]
    end
    local mark = {}; local count = 0   -- to check that all values appeared
    for i = 0, lim or 2000 do
      local t = math.random(table.unpack(p))
      assert(x1 <= t and t <= x2)
      if not mark[t] then  -- new value
        mark[t] = true
        count = count + 1
      end
      if count == x2 - x1 + 1 then   -- all values appeared; OK
        goto ok
      end
    end
    -- loop ended without satisfing condition
    assert(false)
   ::ok::
  end

  aux({-10,0})
  aux({6})
  aux({-10, 10})
  aux({minint, minint})
  aux({maxint, maxint})
  aux({minint, minint + 9})
  aux({maxint - 3, maxint})
end

do   -- full range
  local max = minint
  local min = maxint
  local n = 200
  local mark = {}; local count = 0   -- to count how many different values
  for _ = 1, n do
    local t = math.random(minint, maxint)
    max = math.max(max, t)
    min = math.min(min, t)
    if not mark[t] then  -- new value
      mark[t] = true
      count = count + 1
    end
  end
  -- at least 80% of values are different
  assert(count >= n * 0.8)
  -- min and max not too far from formal min and max
  assert(min < minint * 0.75 and max > maxint * 0.75)
end

for i=1,100 do
  assert(math.random(maxint) > 0)
  assert(math.random(minint, 0) <= 0)
end

assert(not pcall(math.random, 1, 2, 3))
assert(not pcall(math.random, minint + 1, minint))
assert(not pcall(math.random, maxint, maxint - 1))
assert(not pcall(math.random, maxint, minint))


print('OK')
