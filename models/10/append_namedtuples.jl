function append_nts(nts)
    dct = Dict()
    for par in keys(nts)
        if length(size(nts[par])) > 2
            r, s, c = size(nts[par])
            dct[par] = reshape(nts[par], r, s*c)
        else
            s, c = size(nts[par])
            dct[par] = reshape(nts[par], s*c)
        end
    end
    (;dct...)
end

nt = append_nts(nts)
