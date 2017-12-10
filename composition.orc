; Derivative, by Cole Kurashige, 2017
; Original Composition  made for Intro to Computer Music (Mus 88)
	sr 		= 	44100
	kr 		= 	44100
	nchnls 	= 	1
	0dbfs	=	1
	
; sine
gisine	ftgen	1,0,2^18,10,1
; triangle
gitri	ftgen	2,0,2^18,7,0,2^16,1,2^17,-1,2^16,0
; square
gisquare	ftgen	3,0,2^18,7,1,2^17,1,0,-1,2^17,-1
; sawtooth
gisawt	ftgen	4,0,2^18,7,0,2^17,1,0,-1,2^17,0
; const
giconst ftgen 5,0,2^18,7,1,2^18,1
; pulse
gipulse ftgen 6,0,2^18,10,1,1,1,1,0.7,0.5,0.3,0.1

; double fm synth used for oboe and bass.
	instr	1
;   p3  =   duration
;	p4	=	car pitch
;	p5	=	amp
;	p6	=	index of modulation
;	p7	=	modulator/carrier ratio
;	p8	=	modulator waveform
;   p9  =   modulator2/modulator ratio
;   p10 =   modulator2 max amplitude
icfreq	=		cpspch(p4)
imfreq	=		icfreq*p7
ivdepth = 0.015
ivfreq = 8
ivibdelay = 0.2
ivibbuild = 0.1

idev		=		p6 * imfreq
; triangle
kmod2   linseg  0, p3/2, p10, p3/2, 0
amod2   oscil   kmod2, imfreq * p9, gisine
; decrease over time
kmod    linseg  imfreq, p3, 0
kcenv	linseg	0, 0.01, p5, p3-.11, p5, 0.1, 0
amod		oscil	idev, imfreq + amod2, p8

; vibrato
kvcar linseg 0, ivibdelay, 0, ivibbuild, 1, p3 - ivibbuild, 0
av   oscil kvcar * ivdepth, ivfreq, gisine
avib  = (1 + av)

acar		oscil	kcenv, (icfreq+amod)*avib, gisine
		out 		acar*0.9
	endin

; hi-hat using pluck.
    instr 2
; p4 = pitch
; p5 = amp
; p6 = roughness
ifreq = cpspch(p4)
kfreq = k(ifreq)
kamp  = k(p5)
kenv  expseg 0.01, 0.01, 1, p3 - 0.11, 1, 0.1, 0.01
ifun = giconst 
; stretched drum
imeth = 3
irough = p6

asig pluck kamp, kfreq, ifreq, ifun, imeth, irough
     out kenv * asig

    endin

; organ tone using additive snthesis.
    instr 3
ifreq = cpspch(p4)
iamp = p5
kenv linseg 0, 0.01, 1, p3 - 0.08, 1, 0.07, 0

asig1 oscil iamp, ifreq, gisine
asig2 oscil iamp / 2, ifreq * 2, gisine
asig3 oscil iamp / 3, ifreq * 3, gisine
asig4 oscil iamp / 4, ifreq * 4, gisine

    out kenv * 0.3 * (asig1 + asig2 + asig3 + asig4)/4
    endin

; repluck acoustic guitar using chorus effect and sympathetic strings.
    instr 4
; p4 = pitch
; p5 = amplitude

ifreq = cpspch(p4)
iamp = p5
kenv linseg 0, 0.01, 1, p3 - 0.08, 1, 0.07, 0
iplk = 0.75
ipick = 0.75
irefl = 0.5
axcite oscil 1,1,gisine
; main source of pluck
a1 repluck iplk, iamp, ifreq, ipick, irefl, axcite
; sympathetic strings
a2 repluck 0, 0.5 * iamp, 1.5 * ifreq, ipick, irefl - 0.1, a1
a3 repluck 0, 0.4 * iamp, 2.5 * ifreq, ipick, irefl, a1
; main source of pluck
a4 repluck iplk, iamp, ifreq*1.002, ipick, irefl, axcite
; sympathetic strings
a5 repluck 0, 0.5 * iamp, 1.5 * ifreq, ipick, irefl - 0.1, a1
a6 repluck 0, 0.4 * iamp, 2.5 * ifreq, ipick, irefl, a1
; main source of pluck
a7 repluck iplk, iamp, ifreq*0.998, ipick, irefl, axcite
; sympathetic strings
a8 repluck 0, 0.5 * iamp, 1.5 * ifreq, ipick, irefl - 0.1, a1
a9 repluck 0, 0.4 * iamp, 2.5 * ifreq, ipick, irefl, a1
    out kenv * (a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9)/3
    endin

; bowed string instrument.
; Adapted from CSound manual.
    instr 5
; p4 = pitch
; p5 = amplitude

ifreq = cpspch(p4)
iamp = p5
; Suggested value.
kpres = 3
; Suggested value. Who knows how they figured out this one.
krat = 0.127236
; Suggested value. Probably the inverse of a nice ratio.
kvibf = 6.12723

kenv linseg 0, 0.01, 1, p3 - 0.11, 1, 0.1, 0


; short notes don't get vibrato, long notes do.
kvib  linseg 0, 0.2, 0, 0.1, 1, p3-0.1, 1
kvamp = kvib * 0.01
asig1 wgbow iamp, ifreq, kpres, krat, kvibf, kvamp, 1
; chorus effect.
      out kenv * (asig1) 
    endin

; piano sound. As it turns out this went unused.
; Adapted from CSound manual.
    instr 6
ifreq = cpspch(p4)
iamp = p5
; Number of strings (1-3)
iNS = 3
; Amount each string is detued from the base frequency (in cents).
iD = 8
; Stiffness paramter.
iK = 1
; 30 dB decay time in seconds
iT30 = 5
; High-frequency loss parameter.
iB = 0.002
; Boundary condition on the left and right ends (leave at 2 for pivoting).
ibcL = 2
ibcR = 2
; Mass of the hammer.
imass = 1
; Frequency of the natural vibrations of the hammer.
ihfvfreq = 5000
; Position of the hammer.
iinit = -0.01
; Position where it strikes.
ipos = 0.1
; Velocity of the hammer.
ivel = 60
; Scanning frequency and spread.
isfreq = 0
isspread = 0.1

kenv linseg 0, 0.02, 1, p3 - 0.10, 1, 0.08, 0

aout prepiano ifreq, iNS, iD, iK, iT30, iB, ibcL, ibcR, imass, ihfvfreq, iinit, \ 
              ipos, ivel, isfreq, isspread
; for some reason this needs to be amplified a lot.
      outs iamp * 10 * kenv * aout
    endin

;    instr 7
; Failed close-to-subaudio sine kick (too quiet).
; iamp = p4
; ifreq = 60
; kenv expsegr 0.01, 0.01, 0.5, 1, 0.01, p3 - 0.51, 0.01
; aout1 oscil iamp, ifreq, gisine
; aout2 oscil iamp, ifreq*1.1, gisine
; aout3 oscil iamp, ifreq*0.9, gisine
; 
; out kenv * (aout1 + aout2 + aout3) / 3
;     endin


; sampled kick.
; Sample found here http://freewavesamples.com/deep-kick
    instr 7
iamp = p4
aout, aoutr diskin "Deep-Kick.wav"
    out 0.5 * aout 
    endin

; "snare."
    instr 8
iamp = p4
kenv expsegr 0.01, 0.01, 1, 0.2, 0.01, p3 - 0.21, 0.01
ar randh 1, 6000
arand atone ar, 1500
arand atone arand, 1500
arand tone arand, 2500
arand tone arand, 2500
    out kenv * arand
    endin
