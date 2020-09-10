function testfun1(p)
  local i
  for outer i in 1:2:20
    i > p && break
  end
  return i
end

function testfun2(p)
           local i
           for i = 1:100
               rand() > p && break
           end
           if @isdefined(i)
               return i
           else
               return 999
           end
       end

function testfun3(p)
           local i
           for outer i = 1:100
               rand() > p && break
           end
           if @isdefined(i)
               return i
           else
               return 999
           end
       end

testfun1(8) |> display

testfun2(0.99) |> display

testfun3(0.99) |> display
