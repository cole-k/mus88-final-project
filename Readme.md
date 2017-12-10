# Mus 88 Final Project: "Derivative"
This is an algorithmically composed song created using Python 3, Quandl, and
CSound. It plays the 'song' of various financial derivatives. 

## Setup

You will need [Quandl](https://docs.quandl.com/docs/python-installation) and
its dependencies installed.

Place your API key in a file called `quandl_key.secret`.

Download the kick drum sample from [here](http://freewavesamples.com/deep-kick)
and place it into the same directory as the repo. In case it goes down, you may
just comment out using `;` every line in the `.sco` starting with `i7`.

## Running

Run the CSound score generator file so aptly named `score_generator.py` using the command

```
python score_generator.py
```

N.B. For those with separate Python 2 and 3 installations, you'll want to run
this with your Python 3 installation for best compatability (though it may
still work in Python 2).

This will generate the score file (`score.sco`). There are some extra
instruments and parts of the score file in my composition that are not
algorithmically generated, but these are not added to the repo.

## Configuration

I plan on adding command line arguments and other means of configuration at
some point. If you are reading this sufficiently far in the future, that point
is probably never (you can increase the chances of it being sooner by
contacting me).
