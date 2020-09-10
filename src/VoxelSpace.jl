module VoxelSpace
using GLFW, ModernGL, Printf, ColorTypes, FileIO
using Base: unsafe_trunc

include("map_utils.jl")
include("render.jl")

const VIEW_DIST = 1024
const WIN_WIDTH = 1200
const WIN_HEIGHT = 900
const MAP_WIDTH = 1024
const MAP_HEIGHT = 1024

function run(map="C1W")
    GLFW.WindowHint(GLFW.DOUBLEBUFFER, false)
    window = GLFW.CreateWindow(WIN_WIDTH, WIN_HEIGHT, "VoxelSpace.jl")
    GLFW.MakeContextCurrent(window)

    try
        datac, datah = read_map(map)
        data = similar(datac,WIN_WIDTH,WIN_HEIGHT)
        hbuffer = Vector{Int}(undef,WIN_WIDTH)
        px = 512f0
        py = 512f0
        pz = 80f0
        θ  = 0f0

        # keyboard & mouse callbacks for controls
        mov_forward = Ref(false)
        mov_left = Ref(false)
        mov_right = Ref(false)
        mov_back = Ref(false)
        mov_up = Ref(false)
        mov_down = Ref(false)
        mov_boost = Ref(false)

        key_cb = (_, key, scancode, action, mods) -> begin
            if key == GLFW.KEY_W # up
                action == GLFW.PRESS   && (mov_forward[] = true)
                action == GLFW.RELEASE && (mov_forward[] = false)
            elseif key == GLFW.KEY_A # left
                action == GLFW.PRESS   && (mov_left[] = true)
                action == GLFW.RELEASE && (mov_left[] = false)
            elseif key == GLFW.KEY_D # right
                action == GLFW.PRESS   && (mov_right[] = true)
                action == GLFW.RELEASE && (mov_right[] = false)
            elseif key == GLFW.KEY_S # down
                action == GLFW.PRESS   && (mov_back[] = true)
                action == GLFW.RELEASE && (mov_back[] = false)
            elseif scancode == 57 # space
                action == GLFW.PRESS   && (mov_up[] = true)
                action == GLFW.RELEASE && (mov_up[] = false)
            elseif scancode == 29 # l-ctrl
                action == GLFW.PRESS   && (mov_down[] = true)
                action == GLFW.RELEASE && (mov_down[] = false)
            elseif scancode == 42 # l-shift
                action == GLFW.PRESS   && (mov_boost[] = true)
                action == GLFW.RELEASE && (mov_boost[] = false)
            end
        end
        GLFW.SetKeyCallback(window,key_cb)

        mouse_pos  = Float32[0,0]
        mouse_move = Float32[0,0]
        mouse_cb = (_, x, y) -> begin
            mouse_move .= (x,y) .- mouse_pos
            mouse_pos  .= (x,y)
        end
        GLFW.SetCursorPosCallback(window,mouse_cb)

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

        # Set up FPS counter
        t1 = time_ns()
        @printf("FPS: %3.0f",0.0)

        while !GLFW.WindowShouldClose(window)
        #for i = 1:60*10
            # Check for inputs
            GLFW.PollEvents()

            # Compute movement direction
            θ -= mouse_move[1]*1f-2
            mouse_move .= 0f0
            dx,dy = compute_movement(θ,mov_forward[],mov_left[],mov_right[],mov_back[])
            px += dx*(1 + mov_boost[])
            py += dy*(1 + mov_boost[])
            pz += (mov_up[]-mov_down[])

            # Update texture
            render!(data,hbuffer,datac,datah,(px,py,pz),θ,WIN_HEIGHT÷2,WIN_HEIGHT÷2)
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


function compute_movement(θ,mov_forward,mov_left,mov_right,mov_back)
    # signs empirically adjusted...
    sθ, cθ = sincos(θ)
    dx = (mov_right-mov_left)*cθ - (mov_forward-mov_back)*sθ
    dy = -(mov_right-mov_left)*sθ - (mov_forward-mov_back)*cθ
    n = dx>0 ? 1f0/hypot(dx,dy) : 1f0
    return dx*n, dy*n
end


function ModernGL.glGenTextures()
    id = Ref{GLuint}(0)
    glGenTextures(1, id)
    id[] <= 0 && @error "glGenTextures returned an invalid id. Is the OpenGL context active?"
    return id[]
end

end # module
