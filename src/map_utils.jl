function read_map(map::String)
    map_dir = joinpath(dirname(@__DIR__), "maps")
    datac = RGB24.(PNGFiles.load(joinpath(map_dir,map)*".png"))
    datah = Float32.(reinterpret(UInt8,PNGFiles.load(joinpath(map_dir,MAP_LIST[map])*".png")))
    if size(datac,1) == 2*size(datah,1) # some height maps need to be upsampled
        datah = upsample_map_2x(datah)
    end
    return datac, datah
end

function upsample_map_2x(data::Matrix)
    # simple linear interpolation
    w,h = size(data)
    data_2x = similar(data,2w,2h)
    @inbounds for j = 1:h, i = 1:w
        ii,jj = 2*(i-1)+1, 2*(j-1)+1
        data_2x[ii,  jj]   = data[i,j]
        data_2x[ii+1,jj]   = (data[i,j] + data[mod1(i+1,w),j])/2
        data_2x[ii,  jj+1] = (data[i,j] + data[i,mod1(j+1,h)])/2
        data_2x[ii+1,jj+1] = (data[i,j] + data[mod1(i+1,w),mod1(j+1,h)])/2
    end
    return data_2x
end

const MAP_LIST = Dict{String,String}(
    "C1W" => "D1",
    "C2W" => "D2",
    "C3" => "D3",
    "C4" => "D4",
    "C5W" => "D5",
    "C6W" => "D6",
    "C7W" => "D7",
    "C8" => "D6",
    "C9W" => "D9",
    "C10W" => "D10",
    "C11W" => "D11",
    "C12W" => "D11",
    "C13" => "D13",
    "C14" => "D14",
    "C14W" => "D14",
    "C15" => "D15",
    "C16W" => "D16",
    "C17W" => "D17",
    "C18W" => "D18",
    "C19W" => "D19",
    "C20W" => "D20",
    "C21" => "D21",
    "C22W" => "D22",
    "C23W" => "D21",
    "C24W" => "D24",
    "C25W" => "D25",
    "C26W" => "D18",
    "C27W" => "D15",
    "C28W" => "D25",
    "C29W" => "D16",
    )
