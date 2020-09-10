function read_map(map::String)
    map_dir = joinpath(dirname(@__DIR__), "maps")
    datac = load(joinpath(map_dir,map)*".png")
    datah = Float32.(reinterpret(UInt8,load(joinpath(map_dir,MAP_LIST[map])*".png")))
    return datac, datah
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
