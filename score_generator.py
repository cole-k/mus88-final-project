import quandl
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
        # Params should be mutable.
        self.params = list(params)
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


def normalize(df, upper=1):
    '''
    Returns the data frame df normalized from 0 to the range given.
    '''
    return df * (upper / max(df))


def run_length_encode(l1, l2):
    '''
    Takes two lists l1 and l2 and returns a generator giving run length
    encoding based on l1. The format is (l1_elem, l2_avg, rle) where l2 is
    averaged over the compressed range.
    '''
    count, run_value, l2_sum = 1, l1[0], l2[0]
    for i, elem in enumerate(l1[1:]):
        # While equal to the run value, increment and add to l2_sum.
        if elem == run_value:
            count += 1
            l2_sum += l2[i]
        # Once we encounter a change, yield the run length encoding of the
        # previous value and the average l2 value.
        else:
            yield run_value, l2_sum / count, count
            # Start the run length encoding of the current value.
            count, run_value, l2_sum = 1, elem, 0
    yield (run_value, count)


if __name__ == '__main__':
    # Try to read data from the pickled dataframe.
    try:
        intel_data = pd.read_pickle('intc.pickle')
    # Otherwise, grab it from the API.
    except Exception as e:
        quandl.ApiConfig.api_key = open('quandl_key.secret').read().strip()
        intel_data = quandl.get("EOD/INTC")
        # Cache for future use.
        intel_data.to_pickle('intc.pickle')

    with open('output.txt', 'w') as output:
        open_prices = intel_data['Open'].apply(lambda x: round(x))
        volumes = intel_data['Volume']
        # Run length encode prices and average volume over the range for which
        # a price is run-length ecoded.
        prices_volumes_rle = list(run_length_encode(open_prices, volumes))
        # Get the tuple containing the max volume and extract the max volume
        # from it.
        max_volume = max(prices_volumes_rle, key=lambda t: t[1])[1]
        # Cmaj
        scale = ['C', 'D', 'E', 'F', 'G', 'A', 'B']
        # Parameters for my csd. params[0] is the volume in dB.
        params = [-1, 2, 1, 1, 1, 1]
        note = Note('C', 8, 0, 1, 1, scale, *params)
        # Starting value is the first element, starting length is its duration,
        # starting volume is params[0].
        prev_value, note.params[0], note.duration = prices_volumes_rle[0]
        for value, volume, rle in prices_volumes_rle[1:42]:
            output.write(str(note))
            output.write('\n')
            note.time += note.duration
            # The new duration is the rle of the next value.
            note.duration = rle
            # Don't set the volume for now.
            # note.params[0] = volume / max_volume
            # print(volume, max_volume)
            # Change pitch by the delta in value.
            note.change_pitch(value - prev_value)
            prev_value = value
