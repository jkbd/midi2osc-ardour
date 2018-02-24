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

#include <iostream>
#include "mididev.hpp"


extern int yyparse(MidiDev *seq);


MidiDev::MidiDev(std::string& osc_url) {
  int err;
  
  /* open sequencer */
  err = snd_seq_open(&seq, "default", SND_SEQ_OPEN_DUPLEX, 0);
  check_snd("open sequencer", err);

  /* set our client's name */
  err = snd_seq_set_client_name(seq, "midi2osc-ardour");
  check_snd("set client name", err);
  
  printf("ALSA client id: %d\n", snd_seq_client_id(seq));

  /*error will be negativ. port numbers are positive (and 0)*/
  err = snd_seq_create_simple_port(seq, "midi2osc-ardour",
                                   SND_SEQ_PORT_CAP_WRITE | SND_SEQ_PORT_CAP_SUBS_WRITE,
				   SND_SEQ_PORT_TYPE_MIDI_GENERIC | SND_SEQ_PORT_TYPE_APPLICATION);
  check_snd("create port", err);
  puts("Port created.");

  err = snd_seq_connect_from(seq, 0, 20, 0);
  check_snd("connect port", err);
  puts("Connected port 20:0.");

  err = snd_seq_nonblock(seq, 1);
  check_snd("set nonblock mode", err);
  puts("Set to non-block.");
    
  // Create a OSC address
  ardour = lo_address_new_from_url(osc_url.c_str());
}


MidiDev::~MidiDev() {
  lo_address_free(ardour);
}


void MidiDev::parse() {
  yyparse(this);
}


/*
 * error handling for ALSA functions
 */
void MidiDev::check_snd(const char *operation, int err)
{
  if (err < 0) {
    std::cerr << "ERROR" << std::endl;
    //fatal("Cannot %s - %s", operation, snd_strerror(err));
  }
}
