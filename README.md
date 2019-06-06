# logic_tester
Assembler code for PIC18F4550 microcontroller. It can test a variety of TTL logic gates, such as NOT, OR, 2 input AND, XOR, NOR and NAND.

# You can see it on a LCD screen!
The tester tests each one of the logic gates within one of the integrated circuit mentioned above. The LCD displays on screen the functionality of all the logic gates (OK if it works, XX if it doesn't). You can move through two menus two select any of the integrated circuits (see figure below).

![alt text](https://github.com/herrerandresc/logic_tester/blob/master/block_diagram.png)

# How to use it?
You need to connect a LCD screen to the PIC and 4 pull down resistors, like the figure below.

![alt text](https://github.com/herrerandresc/logic_tester/blob/master/schematic.png)

Those resistors act like buttons to surf through the menus and select an integrated circuit to test. The integrated circuit must be always connected such that the display of the state of the gates on the screen is on the same orientation of the integrated circuit. (Vcc to the left upper side and GND to the right lower side, like the figure below).

![alt text](https://github.com/herrerandresc/logic_tester/blob/master/ic_and_display.png)

# The license
I included a GPL license to make the code libre access to anyone, allowing you to improve it and add other funcitonalities. Enjoy it!
