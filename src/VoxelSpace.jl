module VoxelSpace
using GLFW, ModernGL, Printf, ColorTypes, FileIO
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
    data = similar(datac, WIN_WIDTH, WIN_HEIGHT)
    hbuffer = Vector{Int}(undef, WIN_WIDTH)

    # Create window
    GLFW.WindowHint(GLFW.DOUBLEBUFFER, false)
    window = GLFW.CreateWindow(WIN_WIDTH, WIN_HEIGHT, "VoxelSpace.jl")
    GLFW.MakeContextCurrent(window)

    # Generate texture
    tex = glGenTextures()
    glBindTexture(GL_TEXTURE_2D,tex)
    glTexImage2D(GL_TEXTURE_2D,0,GL_RGB8,WIN_WIDTH,WIN_HEIGHT,0,GL_RGB,GL_UNSIGNED_BYTE,data)

    # Generate and bind the read framebuffer
    readFboId = Ref{Cuint}(0)
    glGenFramebuffers(1,readFboId)
    glBindFramebuffer(GL_READ_FRAMEBUFFER,readFboId[])

    # Bind texture to the read framebuffer
    glFramebufferTexture2D(GL_READ_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,tex,0)

    # Bind the default framebuffer (0) to draw
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,0)

    # Set up input callbacks
    GLFW.SetKeyCallback(window,key_cb_fun)
    GLFW.SetCursorPosCallback(window,mouse_cb_fun)

    # Set up FPS counter
    t1 = time_ns()
    @printf("FPS: %3.0f",0.0)

    # Initial position and orientation
    px = 512f0
    py = 512f0
    pz = 80f0
    θ  = 0f0

    try
        while !GLFW.WindowShouldClose(window)
            # Check for inputs
            GLFW.PollEvents()

            # Compute movement direction and apply to pos
            dx,dy,dz,dθ = compute_movement!(θ)
            px += dx
            py += dy
            pz += dz
            θ  += dθ

            # Update texture
            render!(data,hbuffer,datac,datah,(px,py,pz),θ[],WIN_HEIGHT÷2,WIN_HEIGHT÷2)
            glTexSubImage2D(GL_TEXTURE_2D,0,0,0,WIN_WIDTH,WIN_HEIGHT,GL_RGB,GL_UNSIGNED_BYTE,data)

            # Blit read framebuffer (texture) to draw framebuffer (display)
            glBlitFramebuffer(0,0,WIN_WIDTH,WIN_HEIGHT,0,0,WIN_WIDTH,WIN_HEIGHT,GL_COLOR_BUFFER_BIT,GL_LINEAR)
            glFlush()
            #GLFW.SwapBuffers(window)

            # Compute FPS
            t2 = time_ns()
            @printf("\b\b\b%3.0f", 1E9/(t2-t1))
            t1 = t2
        end
    finally
        GLFW.DestroyWindow(window)
        println()
    end
    return nothing
end


function ModernGL.glGenTextures()
    id = Ref{GLuint}(0)
    glGenTextures(1, id)
    id[] <= 0 && @error "glGenTextures returned an invalid id. Is the OpenGL context active?"
    return id[]
end

end # module
