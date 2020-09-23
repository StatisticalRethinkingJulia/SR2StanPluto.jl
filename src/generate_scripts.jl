using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"

indir = projectdir("notebooks")
outdir = projectdir("scripts")

!isdir(outdir) && mkdir(outdir)

function copy_file(
  fromfile::AbstractString, fromdir::AbstractString, todir::AbstractString
)

  nblines = readlines(joinpath(fromdir, fromfile))
  outfilename = joinpath(todir, fromfile)

  isfile(outfilename) && rm(outfilename)
  outfile = open(outfilename, "w")

  for i in nblines
    #println(i)
    if length(i) > 0 && i[1] == '#'
      continue
    else
      write(outfile, i)
      write(outfile, "\n")
    end
  end

  close(outfile)

end

cd(indir) do
  nbsubdirs = readdir()
  for nbsubdir in nbsubdirs
    if isdir(nbsubdir) && nbsubdir !== "scripts"
      !isdir(joinpath(outdir, nbsubdir)) && mkdir(joinpath(outdir, nbsubdir))

      # Find all notebooks holding nbsubdir

      nbs = readdir(nbsubdir)
      println("$(nbsubdir): $(nbs)")

      # Copy the notebooks to the scripts dir

      for nb in nbs
        copy_file(nb, joinpath(indir, nbsubdir), joinpath(outdir, nbsubdir))
      end

    else
      println(("$(nbsubdir) ignored"))
    end
  end

end
