import quandl
import itertools
import pandas as pd

# Translation of notes to numbers
PITCH_TO_NUM = {'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5, 'F#':
                6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11}


class Note:
    '''
    A simple note class.
    '''
    def __init__(self, pitch, octave, time, duration, instrument, scale=None,
                 *params):
        '''
        pitch: the note's pitch (in string format with # used for sharps and no
            flats allowed).

        octave: the note's octave (must be integral).

        time: what beat the note starts on (does not have to be integral).

        duration: how many beats the note lasts (doesn't have to be integral).

        instrument: the instrument playing the note (must be integral).

        key (optional): the scale the note is in (if used, changing pitch will
            shift along the scale and not the chromatic scale). This scale
            moves in the order of notes given (so you can give a scale not in
            order).

        *params (optional): additional parameters to give the instrument in
            CSound, appended in order.
        '''
        self.octave = octave
        self.time = time
        self.duration = duration
        self.instrument = instrument
        if scale:
            # Convert the scale to a machine-readable format.
            self.scale = list(map(lambda p: PITCH_TO_NUM[p], scale))
        else:
            # Chromatic scale.
            self.scale = list(range(12))
        self.params = params

        # Convert the pitch to a machine-readable format.
        pitch = PITCH_TO_NUM[pitch]
        self.pitch = pitch
        # Location in the scale.
        self._pitch_index = self.scale.index(pitch)

    def __str__(self):
        '''
        Returns a csound representation of itself.
        '''
        # The :02 part of the pitch portion front pads a 0 to reach length 2 if
        # needed.
        formatted = 'i{0} {1} {2} {3}.{4:02}'.format(self.instrument,
                                                     self.time, self.duration,
                                                     self.octave, self.pitch)
        # If there are additional parameters, add them to the end.
        if self.params:
            formatted += ' ' + ' '.join(map(str, self.params))

        return formatted

    def change_pitch(self, by):
        '''
        Changes pitch by the amount given, shifting up an octave when shifting
        past the last value in the scale, and down when shifting past the
        first.

        If the optional variable scale is declared, each step goes up one note
        along that scale, not along the chromatic scale. If you don't want the
        note guessing what octave shift it has, define your own method to
        change pitch.
        '''

        self._pitch_index += by
        # Calculate how many octaves we're shifting by.
        # Note that integer division behaves weird with negative numbers and we
        # aren't actually off by one.
        octave_shift = self._pitch_index // len(self.scale)
        self.octave += octave_shift
        # Mod by the length of the scale.
        self._pitch_index %= len(self.scale)
        # Calculate the new pitch.
        self.pitch = self.scale[self._pitch_index]


def run_length_encode(l):
    '''
    Takes a list and returns a generator giving tuples (element, rle)
    '''
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


if __name__ == '__main__':
    # Try to read data from the pickled dataframe.
    try:
        intel_data = pd.read_pickle('intc.pickle')
    # Otherwise, grab it from the API.
    except Exception as e:
        # Get the API key.
        quandl.ApiConfig.api_key = open('quandl_key.secret').read().strip()
        # Read from Quandl.
        intel_data = quandl.get("EOD/INTC")
        # Cache for future use.
        intel_data.to_pickle('intc.pickle')

    with open('output.txt', 'w') as output:
        # Get the open price for INTC.
        open_prices = intel_data['Open'].apply(lambda x: round(x))
        # Get the run length encoding of the prices.
        open_prices_rle = run_length_encode(open_prices)
        # Cmaj
        scale = ['C', 'D', 'E', 'F', 'G', 'A', 'B']
        # Parameters for my csd.
        params = [-1, 2, 1, 1, 1, 1]
        note = Note('C', 8, 0, 1, 1, scale, *params)
        # Starting value is the first element, starting length is its duration.
        prev_value, note.duration = next(open_prices_rle)
        for value, rle in itertools.islice(open_prices_rle, 42):
            output.write(str(note))
            output.write('\n')
            # Move the time along.
            note.time += note.duration
            # The new duration is the rle of the next value.
            note.duration = rle
            # Change pitch by the delta in value.
            note.change_pitch(value - prev_value)
            prev_value = value
