#ifndef MIDIDEV_HPP
#define MIDIDEV_HPP

#include <string>
#include <lo/lo.h>
#include <alsa/asoundlib.h>

class MidiDev {
public:
  MidiDev(std::string& osc_url);
  ~MidiDev();

  void parse();

  lo_address ardour;
  
private:
  snd_seq_t *seq;

  void check_snd(const char *operation, int err);
};

#endif // MIDIDEV_HPP
