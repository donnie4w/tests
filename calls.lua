print("testando chamadas")
oldfb = _ERRORMESSAGE
_ERRORMESSAGE = print

function f(a,b,c) local d = 'a'; t={a,b,c,d} end

f(  -- mudar de linha assim tem que poder
  1,2)
assert(t[1] == 1 and t[2] == 2 and t[3] == nil and t[4] == 'a')
f(1,2,   -- idem
      3,4)
assert(t[1] == 1 and t[2] == 2 and t[3] == 3 and t[4] == 'a')

function fat(x)
  if x <= 1 then return 1
  else return x*dostring("return fat(" .. x-1 .. ")")
  end
end

assert(dostring "dostring 'assert(fat(6)==720)' ")
a = loadstring('return fat(5), 3')
a,b = a()
assert(a == 120 and b == 3)
print('+')

function err_on_n (n)
  if n==0 then error(); assert(nil);
  else err_on_n (n-1); assert(nil);
  end
end

do
  local assert, dostring = assert, dostring
  function dummy (n)
    if n > 0 then
      assert(dostring("err_on_n(" .. n .. ")") == nil)
      dummy(n-1)
    end
end
end

dummy(10)

function deep (n)
  if n>0 then deep(n-1) end
end
deep(10)
deep(200)
_ERRORMESSAGE = oldfb
print('+')


a = nil
(function (x) a=x end)(23)
assert(a == 23 and (function (x) return x*2 end)(20) == 40)


a = {}; lim = 1000
for i=1, lim do a[i]=i end
x = {unpack(a)}
assert(getn(x) == lim and x[1] == 1 and x[lim] == lim)
a,x = unpack{1}
assert(a==1 and x==nil)
a,x = unpack{1,2;n=1}
assert(a==1 and x==nil)


-- testando closures

-- operador de ponto fixo
Y = function (le)
      local a
      function a (f)
        return %le(function (x) return %f(%f)(x) end)
      end
      return a(a)
    end


-- fatorial sem recursao

F = function (f)
      return function (n)
               if n == 0 then return 1
               else return n*%f(n-1) end
             end
    end

fat = Y(F)

assert(fat(0) == 1 and fat(4) == 24 and Y(F)(5)==5*Y(F)(4))

local g = function (z)
  local f = function (a,b,c,d)
    return function (x,y) return a+b+c+d+a+x+y+z end
  end
  return f(z,z+1,z+2,z+3)
end

f = g(10)
assert(f(9, 16) == 10+11+12+13+10+9+16+10)

Y, F, f = nil
print('+')

-- testando multiplos retornos

function unlpack (t, i)
  i = i or 1
  if (i <= getn(t)) then
    return t[i], unlpack(t, i+1)
  end
end

function lpack (...) return arg end

function equaltab (t1, t2)
  assert(getn(t1) == getn(t2))
  for i=1,getn(t1) do
    assert(t1[i] == t2[i])
  end
end

function f() return 1,2,30,4 end
function ret2 (a,b) return a,b end

a,b,c,d = unlpack{1,2,3}
assert(a==1 and b==2 and c==3 and d==nil)
a = {1,2,3,4,nil,10,'alo',nil,assert}
equaltab(lpack(unlpack(a)), a)
equaltab(lpack(unlpack(a), -1), {1,-1})
a,b,c,d = ret2(f()), ret2(f())
assert(a==1 and b==1 and c==2 and d==nil)
a,b,c,d = unlpack(lpack(ret2(f()), ret2(f())))
assert(a==1 and b==1 and c==2 and d==nil)
a,b,c,d = unlpack(lpack(ret2(f()), (ret2(f()))))
assert(a==1 and b==1 and c==nil and d==nil)

a = ret2{ unlpack{1,2,3}, unlpack{3,2,1}, unlpack{"a", "b"}}
assert(a[1] == 1 and a[2] == 3 and a[3] == "a" and a[4] == "b")

print('OK')
return deep
