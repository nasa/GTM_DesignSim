---------Using the Xlink plugin with Xplane9---------

To install the plugin copy the ./bin/Plugin/Xlink folder over to 
  <X-Plane>/Resources/plugins
where <X-Plane> is the X-Plane 9 installation directory.

Next time you start Xplane there should be an Xlink menu item under
the plugins menu.  Options within this menu toggle on/off when
selected and, they include:

 - Receiving flight-path info from matlab via UPD messages
 - Displaying internal data in a text overlay
 - Display simulation data in a text overlay

Instruments in the vehicles cockpit and the vehicle HUD will not
display the correct information.  The plugin is best used with a
chase-plane view.  Keyboard commands +,-, and arrows control the
camera position in chase plane view.

The surfaces are mapped to X-Planes B777 vehicle, but should work with
most others as well.  The file ./img/Speed-Bird_paint_modified.png can
be used to replace the file 
  <X-Plane>/Aircraft/Heavy Metal/B777-200 British Airways/Speed-Bird_paint.png
to provide a vehicle that does not have British-Airways logos.

Joysticks axis are configured with X-Planes "Joystick and Equipment"
menu.  Joystick Buttons (or keyboard keys) can be also configured
under this way, with "custom commands" - Look for an Xlink item in the
"X-System" folder.










