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
kcenv	linseg	0, 0.01, p4, p3-.11, p4, 0.1, 0
amod		oscil	idev, imfreq + amod2, p8
acar		oscil	kcenv, icfreq+amod, gisine
		out 		acar*0.9
	endin

</CsInstruments>
<CsScore>
; TODO: Figure out the bin= command

; 200 bpm
t 0 200

i1 0 2 8.00 -1 2 1 1 1 1
i1 2 2 8.04 -1 2 1 1 1 1
i1 4 1 8.00 -1 2 1 1 1 1
i1 5 1 7.11 -1 2 1 1 1 1
i1 6 2 7.09 -1 2 1 1 1 1
i1 8 1 7.05 -1 2 1 1 1 1
i1 9 1 7.09 -1 2 1 1 1 1
i1 10 4 8.00 -1 2 1 1 1 1
i1 14 1 7.11 -1 2 1 1 1 1
i1 15 2 7.09 -1 2 1 1 1 1
i1 17 1 7.07 -1 2 1 1 1 1
i1 18 1 7.05 -1 2 1 1 1 1
i1 19 2 7.07 -1 2 1 1 1 1
i1 21 1 7.04 -1 2 1 1 1 1
i1 22 3 7.02 -1 2 1 1 1 1
i1 25 1 7.05 -1 2 1 1 1 1
i1 26 1 7.11 -1 2 1 1 1 1
i1 27 2 8.00 -1 2 1 1 1 1
i1 29 2 7.09 -1 2 1 1 1 1
i1 31 1 7.11 -1 2 1 1 1 1
i1 32 2 8.00 -1 2 1 1 1 1
i1 34 6 8.02 -1 2 1 1 1 1
i1 40 1 8.04 -1 2 1 1 1 1
i1 41 1 8.05 -1 2 1 1 1 1
i1 42 4 8.07 -1 2 1 1 1 1
i1 46 1 8.05 -1 2 1 1 1 1
i1 47 1 8.04 -1 2 1 1 1 1
i1 48 2 8.07 -1 2 1 1 1 1
i1 50 2 8.09 -1 2 1 1 1 1
i1 52 6 8.11 -1 2 1 1 1 1
i1 58 2 8.09 -1 2 1 1 1 1
i1 60 2 8.11 -1 2 1 1 1 1
i1 62 4 8.09 -1 2 1 1 1 1
i1 66 1 8.07 -1 2 1 1 1 1
i1 67 3 8.05 -1 2 1 1 1 1
i1 70 4 8.07 -1 2 1 1 1 1
i1 74 2 8.09 -1 2 1 1 1 1
i1 76 1 8.11 -1 2 1 1 1 1
i1 77 1 9.02 -1 2 1 1 1 1
i1 78 2 9.05 -1 2 1 1 1 1
i1 80 3 9.07 -1 2 1 1 1 1
i1 83 4 10.00 -1 2 1 1 1 1

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
