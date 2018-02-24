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
  snd_seq_t *seq;
  
private:
  void check_snd(const char *operation, int err);
};

#endif // MIDIDEV_HPP
