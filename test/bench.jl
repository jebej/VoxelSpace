Pkg.activate(dirname(@__DIR__))
using BenchmarkTools, VoxelSpace
using VoxelSpace: WIN_WIDTH, WIN_HEIGHT, render!

function bench_render()
    datac, datah = VoxelSpace.read_map("C1W")
    fbuffer = similar(datac,WIN_WIDTH,WIN_HEIGHT)
    hbuffer = Vector{Int}(undef,WIN_WIDTH)
    pos = (512f0,512f0,78f0)

    @benchmark render!($fbuffer,$hbuffer,$datac,$datah,$pos,θ) setup=θ=2*rand(Float32)*π
end

function profile_render()
    datac, datah = VoxelSpace.read_map("C1W")
    fbuffer = similar(datac,WIN_WIDTH,WIN_HEIGHT)
    hbuffer = Vector{Int}(undef,WIN_WIDTH)
    pos = (512f0,512f0,78f0)

    @profiler for i = 1:1000
        θ = 2*rand(Float32)*π
        render!(fbuffer,hbuffer,datac,datah,pos,θ)
    end
end

# VoxelSpace.run()
