#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Amtsu Peripheral Bus
== Introduction

The XR/computer platform supports up to 4 low-speed peripheral devices connected to the system via the Amtsu peripheral bus. These devices include things such as mice and keyboards.

The Amtsu bus interface is presented as a set of Citron ports. There are four data ports, *SELECT* (0x30), *MID* (0x31), *A* (0x33), and *B* (0x34).  There is one command port (0x32).

The *SELECT* port contains an ID number of the currently selected Amtsu device, of the range [0, 5]. Writing into this port selects a different device. ID 0 is reserved for the command set of the Amtsu controller.

The *MID* port is read-only and contains the Model ID of the currently selected device. This is a unique identifier for the types of peripheral devices.

The *A*, *B*, and command ports are mapped to virtual *A*, *B*, and command ports of the selected peripheral device. Note that these are actually transmitted via a simple protocol over a relatively slow serial connection, and therefore take many more cycles to access than most Citron ports.

Note that when interrupts are enabled for an Amtsu peripheral, the IRQ number is 0x30 + N where N is the device ID.

The following is a table of the currently defined Amtsu model identifiers:

#tablex(
  columns: (1fr, 3fr),
  align: center,
  cellx([
    #set text(fill: white)
    #set align(center)
    *Name*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *MID*
  ], fill: rgb(0,0,0,255)),
  [AISA Mouse], [0x4D4F5553],
  [AISA Keyboard], [0x8FC48FC4],
)

When ID 0 is selected, the Amtsu controller itself accepts commands through the Citron ports. It accepts the following commands:

#box([
  
#tablex(
  columns: (1fr, 14fr),

  cellx([
    #set text(fill: white)
    #set align(center)
    *\#*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Function*
  ], fill: rgb(0,0,0,255)),
  [0x1], [Enable interrupts from the device number specified in data port *B*.],
  [0x2], [Reset the devices on the Amtsu peripheral bus.],
  [0x3], [Disable interrupts from the device number specified in data port *B*.],
)

])

#box([

== Keyboard

There is a standard keyboard device for the Amtsu bus. The keyboard is a simple input device designed to operate at the speed of a human hand (that is, very slowly relative to the microprocessor).

When the IRQ for a keyboard device is enabled in the Amtsu controller, an interrupt will be signaled whenever a key is pressed or released.

When selected in the Amtsu interface, this device presents several commands:

#tablex(
  columns: (1fr, 14fr),

  cellx([
    #set text(fill: white)
    #set align(center)
    *\#*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Function*
  ], fill: rgb(0,0,0,255)),
  [0x1], [Pop a scancode from the keyboard into data port *A*. If the 15th bit of the scancode is set, that is, it has been OR'ed with 0x8000, then the key was released and the true scancode is the low 14 bits. Otherwise, it was pressed.],
  [0x2], [Reset the keyboard.],
  [0x3], [If the scancode in data port *A* is currently pressed, then set data port *A* to 1. Otherwise, set it to 0.],
)
])

#box([

The layout of the keyboard is shown below. Scancodes for each key are labeled in the center of the key:

#image("layout.png")

])

#box([

== Mouse

There is a standard mouse device for the Amtsu bus. The mouse is a simple pointing input device. There are three buttons.

When the IRQ for a mouse device is enabled in the Amtsu controller, an interrupt will be signaled whenever the mouse moves, and whenever one of the buttons is pressed or released.

])

#box([

When selected in the Amtsu interface, this device presents several commands:

#tablex(
  columns: (1fr, 14fr),

  cellx([
    #set text(fill: white)
    #set align(center)
    *\#*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Function*
  ], fill: rgb(0,0,0,255)),
  [0x1], [
    Read information from the last event into the data ports. Data port *A* is set to a value that indicates the type of the event. Data port *B* is set to an argument for the event.
  ],
  [0x2], [Reset the mouse.],
)

])

=== Mouse Events

#box([

When command 0x1 is written to the command port, information from the last mouse event is latched into data ports *A* and *B*. The event types reported in data port *A* have the following meaning:

#tablex(
  columns: (1fr, 14fr),

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x1*
  ], fill: rgb(0,0,0,255)),
  [Button pressed.],

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x2*
  ], fill: rgb(0,0,0,255)),
  [Button released.],

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x3*
  ], fill: rgb(0,0,0,255)),
  [Mouse moved.],
)

])

#box([

When the event type indicates a button press or release, data port *B* reports a number representing the mouse button:

#tablex(
  columns: (1fr, 14fr),

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x1*
  ], fill: rgb(0,0,0,255)),
  [Left button.],

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x2*
  ], fill: rgb(0,0,0,255)),
  [Right button.],

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x3*
  ], fill: rgb(0,0,0,255)),
  [Middle button.],
)

])

#image("mousedelta.png")

When the event type indicates mouse movement, the change in mouse position is indicated in a 32-bit value called the "mouse delta" which is latched into data port *B*.

The upper 16 bits of this value contain the change in X position, and the lower 16 bits contain the change in Y position. These are both 16-bit signed (two's complement) integers. X represents "left-right" and Y represents "up-down". A negative change indicates a movement to the "left" or "up", and a positive change represents a movement to the "right" or "down".