%{
  /*
   * MIT License
   *
   * Copyright (c) 2018 Jakob Dübel
   *
   * Permission is hereby granted, free of charge, to any person
   * obtaining a copy of this software and associated documentation
   * files (the "Software"), to deal in the Software without
   * restriction, including without limitation the rights to use,
   * copy, modify, merge, publish, distribute, sublicense, and/or sell
   * copies of the Software, and to permit persons to whom the
   * Software is furnished to do so, subject to the following
   * conditions:
   * 
   * The above copyright notice and this permission notice shall be
   * included in all copies or substantial portions of the Software.
   *
   * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
   * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
   * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
   * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   * OTHER DEALINGS IN THE SOFTWARE.
   */
  
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <alloca.h>
#include <sys/poll.h>

#include "../src/mididev.hpp"

extern void yyerror(snd_seq_t *seq, const char*);
int yylex(snd_seq_t *seq);

#define YYERROR_VERBOSE yes
#define YYDEBUG 1

static volatile sig_atomic_t stop = 0;

static void sighandler(int)
{
  stop = 1;
}

  
//int yylex(MidiDev *md);
//void yyerror (MidiDev *md, const char *msg);

//void print_event(jack_midi_event_t e); 
//void send_simple_osc(MidiDev *md, const char *order);
 
%}


/* 
 * We use the sequencer to get the MIDI messages
 */
%parse-param {snd_seq_t *seq}
%lex-param {snd_seq_t *seq}


/*
 * This is the starting-point metasymbol.
 */
%start events

%token PAD_01_PRESS    0x00002406;
%token PAD_01_RELEASE  0x00002407;
%token PAD_02_PRESS    0x00002506;
%token PAD_02_RELEASE  0x00002507;
%token PAD_03_PRESS    0x00002606;
%token PAD_03_RELEASE  0x00002607;
%token PAD_04_PRESS    0x00002706;
%token PAD_04_RELEASE  0x00002707;
%token PAD_05_PRESS    0x00002806;
%token PAD_05_RELEASE  0x00002807;
%token PAD_06_PRESS    0x00002906;
%token PAD_06_RELEASE  0x00002907;
%token PAD_07_PRESS    0x00002a06;
%token PAD_07_RELEASE  0x00002a07;
%token PAD_08_PRESS    0x00002b06;
%token PAD_08_RELEASE  0x00002b07;

%token CONTROL_01      0x0000010a;
%token CONTROL_02      0x0000020a;
%token CONTROL_03      0x0000030a;
%token CONTROL_04      0x0000040a;
%token CONTROL_05      0x0000050a;
%token CONTROL_06      0x0000060a;
%token CONTROL_07      0x0000070a;
%token CONTROL_08      0x0000080a;

%token PROGRAM_01      0x0000000b;
%token PROGRAM_02      0x0000010b;
%token PROGRAM_03      0x0000020b;
%token PROGRAM_04      0x0000030b;
%token PROGRAM_05      0x0000040b;
%token PROGRAM_06      0x0000050b;
%token PROGRAM_07      0x0000060b;
%token PROGRAM_08      0x0000070b;


%% /* Grammar rules and actions follow */

events: %empty /* empty*/
| events pad
| events controller
| events program
;

pad : PAD_01_PRESS PAD_01_RELEASE {
  puts("PAD1!");
 }
| PAD_02_PRESS PAD_02_RELEASE
| PAD_03_PRESS PAD_03_RELEASE
| PAD_04_PRESS PAD_04_RELEASE
| PAD_05_PRESS PAD_05_RELEASE
| PAD_06_PRESS PAD_06_RELEASE
| PAD_07_PRESS PAD_07_RELEASE
| PAD_08_PRESS PAD_08_RELEASE
;

controller: CONTROL_01 {
  printf("K1! %d\n", $1);
 }
| CONTROL_02
| CONTROL_03
| CONTROL_04
| CONTROL_05
| CONTROL_06
| CONTROL_07
| CONTROL_08
;

program: PROGRAM_01 {
  printf("PROG1!\n");
 }
| PROGRAM_02
| PROGRAM_03
| PROGRAM_04
| PROGRAM_05
| PROGRAM_06
| PROGRAM_07
| PROGRAM_08
;


%%

int yylex(snd_seq_t *seq)
{
  struct pollfd *pfds;
  int npfds;
  int err;
  int token = 0;
  
  signal(SIGINT, sighandler);
  signal(SIGTERM, sighandler);
  
  npfds = snd_seq_poll_descriptors_count(seq, POLLIN);
  pfds = static_cast<struct pollfd *>(alloca(sizeof(*pfds) * npfds));

  snd_seq_poll_descriptors(seq, pfds, npfds, POLLIN);
  if (poll(pfds, npfds, -1) < 0) {
    //puts("Some error?");
  }

  do {
    snd_seq_event_t *event;
    err = snd_seq_event_input(seq, &event);
    if (err < 0) break;
   
    if (event) {
      switch (event->type) {
      case SND_SEQ_EVENT_NOTEON: {
	token = SND_SEQ_EVENT_NOTEON | (event->data.note.note << 8) | (event->data.note.channel << 16);
	yylval = event->data.note.velocity;
	break;
      }
      case SND_SEQ_EVENT_NOTEOFF: {
	token = SND_SEQ_EVENT_NOTEOFF | (event->data.note.note << 8) | (event->data.note.channel << 16);
	yylval = 0;
	break;
      }
      case SND_SEQ_EVENT_CONTROLLER: {
	token = SND_SEQ_EVENT_CONTROLLER | (event->data.control.param << 8) | (event->data.control.channel << 16);
	yylval = event->data.control.value;
	break;	
      }
      case SND_SEQ_EVENT_PGMCHANGE: {
	token = SND_SEQ_EVENT_PGMCHANGE | (event->data.control.value << 8) | (event->data.control.channel << 16);
	yylval = 0;
	break;
      }	
      default:
	/* do nothing */
	break;
      }

      /* printf("TOKEN %08x\n", token); */
      return token;
    } /* endif (event) */
  } while (err > 0);

  return EOF;
}

void yyerror (snd_seq_t *seq, const char *msg) {
  printf ("%s\n", msg);
}


/* void yyerror (MidiDev *md, const char *msg) { */
/*   printf ("%s\n", msg); */
/* } */

/* void print_event(jack_midi_event_t e) { */
/*   printf ("DEBUG [%d]:\t0x%08x\n", e.time, e.size); */
/* } */

/* void send_simple_osc(MidiDev *md, const char *order) { */
/*   if(lo_send(md->ardour, order, NULL) == -1) { */
/*     std::cout << "OSC error: " << lo_address_errno(md->ardour) << ", " */
/* 	      << lo_address_errstr(md->ardour) << std::endl; */
/*   } else { */
/*     puts(order); */
/*   } */
/* } */
