/*
 * MIT License
 *
 * Copyright (c) 2018 Jakob Dübel
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "mididev.hpp"
#include <iostream>
#include <string>
#include <unistd.h>

extern int yyparse(MidiDev *md);

int main (int argc, char **argv)
{
  std::string osc_url;
  
  if (argc != 2) {
    std::cout << "Usage: midi2osc-ardour <osc_url>" << std::endl;
    exit(EXIT_FAILURE);
  } else {    
    osc_url.assign(argv[1]);
  }

  MidiDev md = MidiDev(osc_url);
  md.parse();

  exit(EXIT_SUCCESS);
}
