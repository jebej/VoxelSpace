# strongly inspired by https://github.com/s-macke/VoxelSpace
module VoxelSpace
using MiniFB, Printf, ColorTypes, FileIO
using Base: unsafe_trunc

include("map_utils.jl")
include("render.jl")
include("input.jl")

const VIEW_DIST = 1024
const WIN_WIDTH = 1200
const WIN_HEIGHT = 900
const MAP_WIDTH = 1024
const MAP_HEIGHT = 1024

function run(map="C1W")
    # Load map and create buffer
    datac, datah = read_map(map)
    data = Matrix{RGB24}(undef, WIN_WIDTH, WIN_HEIGHT)
    hbuffer = Vector{Int}(undef, WIN_WIDTH)

    # Create window
    window = mfb_open_ex("VoxelSpace.jl", WIN_WIDTH, WIN_HEIGHT, MiniFB.WF_RESIZABLE);

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

    try
        while mfb_wait_sync(window)
            # Compute movement direction and apply to pos
            dx,dy,dz,dθ = compute_movement!(θ)
            px += dx
            py += dy
            pz += dz
            θ  += dθ

            # Update texture
            render!(data,hbuffer,datac,datah,(px,py,pz),θ,WIN_HEIGHT>>1,WIN_HEIGHT>>1)

            state = mfb_update(window, data)
            state == MiniFB.STATE_OK || break

            # Compute FPS
            t2 = time_ns()
            @printf("\b\b\b%3.0f", 1E9/(t2-t1))
            t1 = t2
        end
    finally
        mfb_close(window)
        println()
    end
    return nothing
end

end # module
