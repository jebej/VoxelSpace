# strongly inspired by https://github.com/s-macke/VoxelSpace
module VoxelSpace
using MiniFB, ColorTypes, PNGFiles, Printf
using Base: unsafe_trunc

include("map_utils.jl")
include("render.jl")
include("input.jl")

const VIEW_DIST = 1024
const WIN_WIDTH = 1200
const WIN_HEIGHT = 900
const MAP_WIDTH = 1024
const MAP_HEIGHT = 1024
const ZSCALE = 1024f0/2
const HORIZON = 1024f0/2

function run(map="C1W")
    # Load map and create framebuffer
    datac, datah = read_map(map)
    fbuffer = Matrix{RGB24}(undef, WIN_WIDTH, WIN_HEIGHT)
    hbuffer = Vector{Int}(undef, WIN_WIDTH)

    # Create window
    window = mfb_open("VoxelSpace.jl", WIN_WIDTH, WIN_HEIGHT)

    # Set up input callbacks
    key_cb_fun_c = @cfunction(key_cb_fun, Cvoid, (Ptr{Cvoid}, mfb_key, mfb_key_mod, Bool))
    mouse_cb_fun_c = @cfunction(mouse_cb_fun, Cvoid, (Ptr{Cvoid}, Int32, Int32))
    mfb_set_keyboard_callback(window, key_cb_fun_c)
    mfb_set_mouse_move_callback(window, mouse_cb_fun_c)

    # Set up FPS counter
    t1 = time_ns()
    @printf("FPS: %3.0f",0.0)

    # Initial position and orientation
    px = 512f0
    py = 512f0
    pz = 80f0
    θ  = 0f0

    while mfb_wait_sync(window)
        # Compute movement direction and apply to pos
        dx,dy,dz,dθ = compute_movement!(θ)
        px += dx
        py += dy
        pz += dz
        θ  += dθ

        # Render viewport
        render!(fbuffer,hbuffer,datac,datah,(px,py,pz),θ)

        # Compute FPS
        t2 = time_ns()
        @printf("\b\b\b%3.0f", 1E9/(t2-t1))
        t1 = t2

        # Update framebuffer
        state = mfb_update(window, fbuffer)
        state == MiniFB.STATE_OK || break
    end

    mfb_close(window)
    println()

    return nothing
end

end # module
