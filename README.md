# midi2osc-ardour
Use a MIDI device to control transport in [Ardour](https://ardour.org/).

This code is an example how to convert arbitrary MIDI event sequences
to one specific [Open Sound
Control](http://opensoundcontrol.org/introduction-osc) command.  If
you know [Bison](http://liblo.sourceforge.net/) or understand
[BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) grammar
this small piece of software could be easily adapted to your needs.


## Dependencies

* A MIDI device
* ALSA libasound.so
* [liblo](http://liblo.sourceforge.net/) (for interfacing Ardour via [Open Sound Control](http://opensoundcontrol.org/introduction-osc))
* [Bison](http://liblo.sourceforge.net/) parser generator


## Build

```bash
$ mkdir build && cd build
$ cmake ..
$ make
```


## Usage

```bash
$ ./midi2osc-ardour "osc.udp://daw.example.org:3819/"
```

Exit with `Ctrl^C`.


## Configuration

There is no usable default configuration, yet.

You might want to change the configuration in the code. See the Bison
grammar file `src/parser.y`. Follow these steps:

1. Find the `yylex()` function and check out, which hexcode your
   button produces.

2. Make sure, you define a token with the same code. Add e.g.:
```
%token TOKEN_MY_BUTTON_PRESS   0x0abcde;
%token TOKEN_MY_BUTTON_RELEASE 0x0abcdf;
```

3. Add a grammar rule with your C++ code. E.g.:
```
event_rule: [...]
| [...]
| TOKEN_MY_BUTTON_PRESS TOKEN_MY_BUTTON_RELEASE {
  std::cout << "My button was pressed and released." << std::endl;
} 
;
```
