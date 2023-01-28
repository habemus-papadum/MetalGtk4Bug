
using Colors, FixedPointNumbers, Gtk4, Metal

## Metal version of cpu.jl 

function generate(img, pos)
    r, c = Int32.(size(img))
    i,j = thread_position_in_grid_2d()
    @inbounds if i <= r && j <= c
        img[i,j] = pos < j < pos + 10 ? colorant"red" : colorant"thistle"
    end
    return
end

img = MtlArray{RGB{N0f8}}(undef, 800,600)
wrapped = unsafe_wrap(Array{RGB{N0f8}}, img, size(img))

## initial image
Metal.@sync @metal threads=16,16 grid=size(img) generate(img, 0)

win = GtkWindow("Test", 800, 600);
data = reinterpret(Gtk4.GdkPixbufLib.RGB, wrapped) ## use unsafe_wrap after fixing segfault
pixbuf = Gtk4.GdkPixbufLib.GdkPixbuf(data,false) 
view = GtkImage(pixbuf)

push!(win,view)

if !isinteractive()
    @async Gtk4.GLib.glib_main()
end

for i=1:400
    Metal.@sync @metal threads=16,16 grid=size(img) generate(img, i*2)
    Gtk4.G_.set_from_pixbuf(view, pixbuf)
    sleep(0.01)
end

#
if !isinteractive()
    Gtk4.GLib.waitforsignal(win,:close_request)
end