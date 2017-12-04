from collections import namedtuple
import quandl
import pandas as pd
import numpy as np

# Simple note class
class Note:
    # Translation of notes to numbers
    PITCH_TO_NUM = {'C' : 0, 'C#' : 1, 'D' : 2, 'D#' : 3, 'E' : 4, 'F' : 5, 'F#' : 6,
            'G' : 7, 'G#' : 8, 'A' : 9, 'A#' : 10, 'B' : 11}

    def __init__(self, pitch, octave, time, duration, instrument, *params):
        # Convert the pitch to a machine-readable format.
        self._pitch = PITCH_TO_NUM[pitch]
        self._octave = octave
        self._time = time
        self._params = params

    def __str__(self):
        # Returns a CSound representation of itself.
        formatted = 'i{0} {1} {2} {3}.{4}'.format(instrument, time, duration,
                octave, pitch)
        # If there are additional parameters, add them to the end.
        if params:
            formatted.append(' ' + ' '.join(params))

        return formatted

    def change_pitch(by):
        self.pitch_ += by 
        # Take mod 12 (there are only 12 notes).
        self.pitch_ %= 12


def run_length_encode(l):
    ''' Takes a list and returns a generator giving tuples (element, rle)'''
    count, run_value = 1, l[0]
    for elem in l[1:]:
        # While equal to the run value, we increment.
        if elem == run_value:
            count += 1
        # Once we encounter a change, yield the run length encoding of the
        # previous value.
        else:
            yield (run_value, count)
            # We now start the run length encoding of the current value
            count, run_value = 1, elem
    yield (run_value, count)


try:
    intel_data = pd.read_pickle('intc.pickle')
except:
    # Get my API key.
    quandl.ApiConfig.api_key = open('quandl_key.secret').read().strip()
    # Read from Quandl.
    intel_data = quandl.get("EOD/INTC")
    # Cache for future use.
    intel_data.to_pickle('intc.pickle')

print(intel_data[0])
