
using Colors, FixedPointNumbers, Gtk4

function generate(img, pos)
    r, c = Int32.(size(img))
    @Threads.threads for i=1:r
        for j=1:c
            img[i,j] = pos < j < pos + 10 ? colorant"red" : colorant"thistle"
        end
    end
    return
end

img = Array{RGB{N0f8}}(undef, 800,600)
generate(img, 0)

win = GtkWindow("Test", 800, 600);
data = reinterpret(Gtk4.GdkPixbufLib.RGB, img)
pixbuf = Gtk4.GdkPixbufLib.GdkPixbuf(data,false) 
view = GtkImage(pixbuf)

push!(win,view)

if !isinteractive()
    @async Gtk4.GLib.glib_main()
end

for i=1:400
    generate(img, i*2)
    Gtk4.G_.set_from_pixbuf(view, pixbuf)
    sleep(0.01)
end

#
if !isinteractive()
    Gtk4.GLib.waitforsignal(win,:close_request)
end