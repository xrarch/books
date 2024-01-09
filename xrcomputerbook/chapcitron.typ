#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Citron Interface
== Introduction

The Citron interface is a small memory-mapped region of 32-bit ports.#footnote([Historically, this was the port I/O space of a previous CISC processor architecture.]) Many of the integral devices of the XR/computer platform are exposed through this interface. It begins at the physical address 0xF8000000. For example, Citron Port 0x20 would be found at the offset 0x20 \* 4 = 0x80 within this space, or 0xF8000080.

=== Ports

Device ports have some standard behavior in order to simplify drivers somewhat. "Command ports" read zero if the device is completely idle and ready to accept any new command, and a non-zero value with device-specific meaning otherwise. When written, command ports cause the device to perform some action.

"Data ports" may have any device-specific action on reads and writes.

=== RTC

There is a simple Real Time Clock (RTC) that is responsible for tracking time and for asserting the interval timer interrupt. The time is tracked as a 32-bit Unix epoch timestamp, along with a millisecond part. The current time is stored persistently in a small battery-backed memory. The interval timer can be programmed to periodically interrupt at any 32-bit count of milliseconds.

The IRQ number for the interval timer is 0x02.

The RTC uses two Citron ports, a single command port (0x20) and a single data port (0x21). The data port is readable and writable as a 32-bit datum. The accepted commands are as follows:

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
  [0x1], [Set the timer interval to the number of milliseconds specified in the data port. If zero, the timer interrupt is disabled.],
  [0x2], [Reads the current epoch time seconds part into the data port.],
  [0x3], [Reads the current epoch time milliseconds part into the data port.],
  [0x4], [Sets the current epoch time seconds part from the contents of the data port.],
  [0x5], [Sets the current epoch time milliseconds part from the contents of the data port.],
)

])

=== Serial Ports

The XR/computer platform supports two serial ports. They are conventionally labeled Serial Port A and Serial Port B.

Each serial port uses two Citron ports, one command port and one data port. The two serial ports are sequential in the Citron port space, beginning at 0x10. For Serial Port A, the command and data ports are 0x10 and 0x11 respectively. For Serial Port B, they are 0x12 and 0x13.

The serial controller collects incoming bytes in a 32-byte receive buffer, and accumulates outgoing characters in a 16-byte transmit buffer. The bytes in the transmit buffer are asynchronously transmitted at 9600 baud.

Reading from the data port will dequeue the next character from the receive buffer. If the receive buffer is empty, 0xFFFF is returned. There is an optional interrupt that is asserted by the serial controller when a character is received.

Writing to the data port will enqueue a character into the transmit buffer. If the transmit buffer is full, reading from the command port will yield a non-zero value. This should be done before attempting to push a character. There is an optional interrupt that is asserted by the serial controller when the transmit buffer has some space available.

The IRQ numbers for serial ports A and B are 0x04 and 0x05 respectively.

The accepted commands are as follows:

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
  [0x3], [Enable the interrupt for this serial port.],
  [0x4], [Disable the interrupt for this serial port.],
)

])

=== Disk Controller

The XR/computer platform supports up to 8 block addressable devices (such as hard disks) via a simple disk controller. The disk controller has one Citron command port (0x19), and two data ports, data port *A* (0x1A) and data port *B* (0x1B).

The controller performs transfers in units of sectors, which are 512 bytes. One transfer can be in progress to each attached disk simultaneously, and can be up to 8 sectors (4KB) in length. The transfers perform DMA to and from arbitrary sector-aligned physical addresses (i.e. the low 9 bits of the physical address are ignored).

Reading the command port yields a bit set of status bits. The Nth bit where N is a disk number of the range [0, 7] indicates whether that disk is busy or not. This can be used for polled operation of the disk controller. An interrupt can also be made to trigger when transfers complete.

The IRQ number for the disk controller is 0x03.

#box([

The accepted commands are as follows:
  
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
  [0x1], [Select the disk number specified in data port *A*.],
  [0x2], [Start a READ transfer from the selected disk beginning at the sector number specified in data port *A*.],
  [0x3], [Start a WRITE transfer to the selected disk beginning at the sector number specified in data port *A*.],
  [0x4], [Set data port *B* to a bit set of disks whose transfer has completed since the last time this port was read. Atomically clears the bit set.],
  [0x5], [Read information about the disk whose number is in data port *A*. Data port *A* is set to 1 if the disk is present, 0 otherwise. Data port *B* is set to a 32 bit count of sectors in the disk.],
  [0x6], [Enable the transfer completion interrupt.],
  [0x7], [Disable the transfer completion interrupt.],
  [0x8], [Set the sector length for the next transfer from the contents of data port *A*.],
  [0x9], [Set the sector-aligned physical address for the next transfer from the contents of data port *A*.],
)

])