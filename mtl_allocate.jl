
using Colors, FixedPointNumbers, Gtk4, Metal

## Metal version of cpu.jl -- allocates arrays 
## (Was created to test if unsafe_wrap was the problem)

function generate(img, pos)
    r, c = Int32.(size(img))
    i,j = thread_position_in_grid_2d()
    @inbounds if i <= r && j <= c
        img[i,j] = pos < j < pos + 10 ? colorant"red" : colorant"thistle"
    end
    return
end

img = MtlArray{RGB{N0f8}}(undef, 800,600)
Metal.@sync @metal threads=16,16 grid=size(img) generate(img, 0)

win = GtkWindow("Test", 800, 600);
data = reinterpret(Gtk4.GdkPixbufLib.RGB, Array(img)) ## use unsafe_wrap after fixing segfault
pixbuf = Gtk4.GdkPixbufLib.GdkPixbuf(data,false) 
view = GtkImage(pixbuf)

push!(win,view)

if !isinteractive()
    @async Gtk4.GLib.glib_main()
end

for i=1:400

    Metal.@sync @metal threads=16,16 grid=size(img) generate(img, i*2)
    global data = reinterpret(Gtk4.GdkPixbufLib.RGB, Array(img)) 
    global pixbuf = Gtk4.GdkPixbufLib.GdkPixbuf(data,false) 
    
    Gtk4.G_.set_from_pixbuf(view, pixbuf)
    sleep(0.01)
end

#
if !isinteractive()
    Gtk4.GLib.waitforsignal(win,:close_request)
end