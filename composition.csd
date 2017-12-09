<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

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

; complex fm synthesis
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
idev		=		p6 * imfreq
; triangle
kmod2   linseg  0, p3/2, p10, p3/2, 0
amod2   oscil   kmod2, imfreq * p9, gisine
; decrease over time
kmod    linseg  imfreq, p3, 0
kcenv	linseg	0, 0.01, p5, p3-.11, p5, 0.1, 0
amod		oscil	idev, imfreq + amod2, p8
acar		oscil	kcenv, icfreq+amod, gisine
		out 		acar*0.9
	endin

; drum using pluck
    instr 2
; p4 = pitch
; p5 = amp
; p6 = roughness
; p7 = stretch factor
ifreq = cpspch(p4)
kfreq = k(ifreq)
kamp  = k(p5)
kenv  expseg 0.01, 0.01, 1, p3 - 0.11, 1, 0.1, 0.01
ifun = giconst
; stretched drum
imeth = 3
irough = p6
istretch = p7

asig pluck kamp, kfreq, ifreq, ifun, imeth, irough
     out kenv * asig

    endin

    instr 3
ifreq = cpspch(p4)
iamp = p5
kenv linseg 0, 0.01, 1, p3 - 0.08, 1, 0.07, 0

asig oscil iamp, ifreq, gisine

    out kenv * asig * (0.3)
    endin

</CsInstruments>
<CsScore>
; TODO: Figure out the bin= command

; 200 bpm
t 0 200

{5 CNT
; C
i3 [0 + 32 * $CNT] 4 8.00 1
i3 [0 + 32 * $CNT] 4 8.04 1
i3 [0 + 32 * $CNT] 4 8.07 1

; G
i3 [4 + 32 * $CNT] 4 8.02 1
i3 [4 + 32 * $CNT] 4 8.07 1
i3 [4 + 32 * $CNT] 4 8.11 1

; F
i3 [8 + 32 * $CNT] 4 8.05 1
i3 [8 + 32 * $CNT] 4 8.09 1
i3 [8 + 32 * $CNT] 4 9.00 1

; C
i3 [12 + 32 * $CNT] 4 8.00 1
i3 [12 + 32 * $CNT] 4 8.04 1
i3 [12 + 32 * $CNT] 4 8.07 1

; F
i3 [16 + 32 * $CNT] 4 8.05 1
i3 [16 + 32 * $CNT] 4 8.09 1
i3 [16 + 32 * $CNT] 4 9.00 1

; C
i3 [20 + 32 * $CNT] 4 8.00 1
i3 [20 + 32 * $CNT] 4 8.04 1
i3 [20 + 32 * $CNT] 4 8.07 1

; G/D
i3 [24 + 32 * $CNT] 8 8.02 1
i3 [24 + 32 * $CNT] 8 8.07 1
i3 [24 + 32 * $CNT] 8 9.02 1
}

{20 CNT2
i2 [0 + 8 * $CNT2] 2 6.05 0.1 0.5
i2 [2 + 8 * $CNT2] 2 6.05 0.1 0.5
i2 [4 + 8 * $CNT2] 2 6.05 0.1 0.5
i2 [6 + 8 * $CNT2] 2 6.05 0.1 0.5
}

i1 32 2 8.00 -1 2 1 1 1 1
i1 34 2 8.04 -1 2 1 1 1 1
i1 36 1 8.00 -1 2 1 1 1 1
i1 37 1 7.11 -1 2 1 1 1 1
i1 38 2 7.09 -1 2 1 1 1 1
i1 40 1 7.05 -1 2 1 1 1 1
i1 41 1 7.09 -1 2 1 1 1 1
i1 42 4 8.00 -1 2 1 1 1 1
i1 46 1 7.11 -1 2 1 1 1 1
i1 47 2 7.09 -1 2 1 1 1 1
i1 49 1 7.07 -1 2 1 1 1 1
i1 50 1 7.05 -1 2 1 1 1 1
i1 51 2 7.07 -1 2 1 1 1 1
i1 53 1 7.04 -1 2 1 1 1 1
i1 54 3 7.02 -1 2 1 1 1 1
i1 57 1 7.05 -1 2 1 1 1 1
i1 58 1 7.11 -1 2 1 1 1 1
i1 59 2 8.00 -1 2 1 1 1 1
i1 61 2 7.09 -1 2 1 1 1 1
i1 63 1 7.11 -1 2 1 1 1 1
i1 64 2 8.00 -1 2 1 1 1 1
i1 66 6 8.02 -1 2 1 1 1 1
i1 72 1 8.04 -1 2 1 1 1 1
i1 73 1 8.05 -1 2 1 1 1 1
i1 74 4 8.07 -1 2 1 1 1 1
i1 78 1 8.05 -1 2 1 1 1 1
i1 79 1 8.04 -1 2 1 1 1 1
i1 80 2 8.07 -1 2 1 1 1 1
i1 82 2 8.09 -1 2 1 1 1 1
i1 84 6 8.11 -1 2 1 1 1 1
i1 90 2 8.09 -1 2 1 1 1 1
i1 92 2 8.11 -1 2 1 1 1 1
i1 94 4 8.09 -1 2 1 1 1 1
i1 98 1 8.07 -1 2 1 1 1 1
i1 99 3 8.05 -1 2 1 1 1 1
i1 102 4 8.07 -1 2 1 1 1 1
i1 106 2 8.09 -1 2 1 1 1 1
i1 108 1 8.11 -1 2 1 1 1 1
i1 109 1 9.02 -1 2 1 1 1 1
i1 110 2 9.05 -1 2 1 1 1 1
i1 112 3 9.07 -1 2 1 1 1 1
i1 115 4 10.00 -1 2 1 1 1 1

</CsScore>
</CsoundSynthesizer>
