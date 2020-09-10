Pkg.activate(".")
using BenchmarkTools, VoxelSpace
using VoxelSpace: WIN_WIDTH, WIN_HEIGHT, render!

function bench_render()
    datac, datah = VoxelSpace.read_map("C1W")
    data = similar(datac,WIN_WIDTH,WIN_HEIGHT)
    hbuffer = Vector{Int}(undef,WIN_WIDTH)
    pos = (512f0,512f0,78f0)

    @benchmark render!($data,$hbuffer,$datac,$datah,$pos,θ,$WIN_HEIGHT÷2,$WIN_HEIGHT÷2) setup=θ=2*rand(Float32)*π
end

function profile_renderer()
    datac, datah = VoxelSpace.read_map("C1W")
    data = similar(datac,WIN_WIDTH,WIN_HEIGHT)
    hbuffer = Vector{Int}(undef,WIN_WIDTH)
    pos = (512f0,512f0,78f0)

    @profiler for i = 1:1000
        θ = 2*rand(Float32)*π
        render!(data,hbuffer,datac,datah,pos,θ,WIN_HEIGHT÷2,WIN_HEIGHT÷2)
    end
end

# VoxelSpace.run()
