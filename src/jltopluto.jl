# jl2pluto.jl : Convert an ordinary Julia file to Pluto notebook.
#
#  Call by :
#
#   jl2pluto [-f] inputfile.jl [outputplutonb.jl]
#
#   If unspecified, outputplutonb.jl  defaults to "inputjfile-pluto.jl"
#   If no "-f", do not overwrite existing output notebook
#   If    "-f", force write output notebook, erasing it if already existing
#

# J.D.A.DAVID 13/08/2020
# Inspired by discussion with @fonsp and discourse exchanges.
# See  https://github.com/fonsp/Pluto.jl/issues/132 for API first example

import Pluto

# inputfile="0tplot.jl";
# outputfile="0tplot-pluto.jl";

function input2plutonb(inputfile, outputfile)
    code=input2code(inputfile);
    plnb = Pluto.Notebook(Pluto.Cell.(code));
    Pluto.save_notebook(plnb, outputfile);
end

function input2code(inputfile::AbstractString)
  code=String[]
  open(inputfile) do f
    hit_eof = false
    while true
        line = ""
        ast = nothing
        interrupted = false
        while true
            try
                oneline = readline(f, keep=true)
                line = line * oneline
            catch e
                if isa(e,InterruptException)
                    try # raise the debugger if present
                        ccall(:jl_raise_debugger, Int, ())
                    catch
                    end
                    line = ""
                    interrupted = true
                    break
                elseif isa(e,EOFError)
                    hit_eof = true
                    break
                else
                    rethrow()
                end
            end
            ast = Base.parse_input_line(line)
            (isa(ast,Expr) && ast.head == :incomplete) || break
        end
        ast = Base.parse_input_line(line)
        if isa(ast,Expr)
            push!(code,line)
        else
            if !isempty(line)
                @info "input2code : not_an expr - ignoring $line"
            end
        end
        ((!interrupted && isempty(line)) || hit_eof) && break
    end
  end
  return code
end

msghelp="""
jl2pluto.jl : Convert an ordinary Julia file to Pluto notebook.
Call by :
  jl2pluto [-f] inputfile.jl [outputplutonb.jl]
  If unspecified, outputplutonb.jl  defaults to "inputjfile-pluto.jl"
  If no "-f", do not overwrite existing output notebook
  If    "-f", force write output notebook, erasing it if already existing
  
"""

if length(ARGS) <1; println(msghelp); exit(0); end

if ARGS[1] == "-h"; println(msghelp); exit(0); end

enableoverwrite=false
if ARGS[1] == "-f"; enableoverwrite=true; popfirst!(ARGS) end


inputfile=ARGS[1]
if !isfile(inputfile)
    println("jl2pluto : inputfile $inputfile does not exists, aborting")
    exit(1)
end
if filesize(inputfile) < 2
    println("jl2pluto : inputfile $inputfile is empty, aborting")
    exit(1)
end

if length(ARGS) <2
    baseinputfile=replace(inputfile, ".jl" => "")
    outputfile=baseinputfile * "-pluto.jl"
else
    outputfile=ARGS[2]
end
if isfile(outputfile)
    if !enableoverwrite
        println("jl2pluto : outputfile $outputfile already exists, aborting")
        exit(1)
    end
end

input2plutonb(inputfile,outputfile)
@info "Pluto notebook $outputfile written."
