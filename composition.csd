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

; simpe sine wave. was meant to be a placeholder but it grew on me too much.
    instr 3
ifreq = cpspch(p4)
iamp = p5
kenv linseg 0, 0.01, 1, p3 - 0.08, 1, 0.07, 0

asig oscil iamp, ifreq, gisine

    out kenv * asig * (0.3)
    endin

; repluck acoustic guitar.
    instr 4

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

; prepiano
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

</CsInstruments>
<CsScore>
; TODO: Figure out the bin= command

; 200 bpm
t 0 200

{20 CNT
; C
i3 [0 + 32 * $CNT] 4 8.00 0.3
i3 [0 + 32 * $CNT] 4 8.04 0.3
i3 [0 + 32 * $CNT] 4 8.07 0.3
i1 [0 + 32 * $CNT] 4 6.00 0.1 2 1 1 1 1

; G
i3 [4 + 32 * $CNT] 4 8.02 0.3
i3 [4 + 32 * $CNT] 4 8.07 0.3
i3 [4 + 32 * $CNT] 4 8.11 0.3
i1 [4 + 32 * $CNT] 4 6.07 0.1 2 1 1 1 1

; F
i3 [8 + 32 * $CNT] 4 8.05 0.3
i3 [8 + 32 * $CNT] 4 8.09 0.3
i3 [8 + 32 * $CNT] 4 9.00 0.3
i1 [8 + 32 * $CNT] 4 6.05 0.1 2 1 1 1 1

; C
i3 [12 + 32 * $CNT] 4 8.00 0.3
i3 [12 + 32 * $CNT] 4 8.04 0.3
i3 [12 + 32 * $CNT] 4 8.07 0.3
i1 [12 + 32 * $CNT] 4 6.00 0.1 2 1 1 1 1

; F
i3 [16 + 32 * $CNT] 4 8.05 0.3
i3 [16 + 32 * $CNT] 4 8.09 0.3
i3 [16 + 32 * $CNT] 4 9.00 0.3
i1 [16 + 32 * $CNT] 4 6.05 0.1 2 1 1 1 1

; C
i3 [20 + 32 * $CNT] 4 8.00 0.3
i3 [20 + 32 * $CNT] 4 8.04 0.3
i3 [20 + 32 * $CNT] 4 8.07 0.3
i1 [20 + 32 * $CNT] 4 6.00 0.1 2 1 1 1 1

; G/D
i3 [24 + 32 * $CNT] 8 8.02 0.3
i3 [24 + 32 * $CNT] 8 8.07 0.3
i3 [24 + 32 * $CNT] 8 9.02 0.3
i1 [24 + 32 * $CNT] 8 6.07 0.1 2 1 1 1 1
}

{80 CNT2
i2 [0 + 8 * $CNT2] 2 6.05 0.1 0.5
i2 [2 + 8 * $CNT2] 2 6.05 0.1 0.5
i2 [4 + 8 * $CNT2] 2 6.05 0.1 0.5
i2 [6 + 8 * $CNT2] 2 6.05 0.1 0.5
}

; intc
i1 32 2 8.00 0.5 2 1 1 1 1
i1 34 2 8.04 0.5 2 1 1 1 1
i1 36 1 8.00 0.5 2 1 1 1 1
i1 37 1 7.11 0.5 2 1 1 1 1
i1 38 2 7.09 0.5 2 1 1 1 1
i1 40 1 7.05 0.5 2 1 1 1 1
i1 41 1 7.09 0.5 2 1 1 1 1
i1 42 4 8.00 0.5 2 1 1 1 1
i1 46 1 7.11 0.5 2 1 1 1 1
i1 47 2 7.09 0.5 2 1 1 1 1
i1 49 1 7.07 0.5 2 1 1 1 1
i1 50 1 7.05 0.5 2 1 1 1 1
i1 51 2 7.07 0.5 2 1 1 1 1
i1 53 1 7.04 0.5 2 1 1 1 1
i1 54 3 7.02 0.5 2 1 1 1 1
i1 57 1 7.05 0.5 2 1 1 1 1
i1 58 1 7.11 0.5 2 1 1 1 1
i1 59 2 8.00 0.5 2 1 1 1 1
i1 61 2 7.09 0.5 2 1 1 1 1
i1 63 1 7.11 0.5 2 1 1 1 1
i1 64 2 8.00 0.5 2 1 1 1 1
i1 66 6 8.02 0.5 2 1 1 1 1
i1 72 1 8.04 0.5 2 1 1 1 1
i1 73 1 8.05 0.5 2 1 1 1 1
i1 74 4 8.07 0.5 2 1 1 1 1
i1 78 1 8.05 0.5 2 1 1 1 1
i1 79 1 8.04 0.5 2 1 1 1 1
i1 80 2 8.07 0.5 2 1 1 1 1
i1 82 2 8.09 0.5 2 1 1 1 1
i1 84 6 8.11 0.5 2 1 1 1 1
i1 90 2 8.09 0.5 2 1 1 1 1
i1 92 2 8.11 0.5 2 1 1 1 1
i1 94 4 8.09 0.5 2 1 1 1 1
i1 98 1 8.07 0.5 2 1 1 1 1
i1 99 3 8.05 0.5 2 1 1 1 1
i1 102 4 8.07 0.5 2 1 1 1 1
i1 106 2 8.09 0.5 2 1 1 1 1
i1 108 1 8.11 0.5 2 1 1 1 1
i1 109 1 9.02 0.5 2 1 1 1 1
i1 110 2 9.05 0.5 2 1 1 1 1
i1 112 3 9.07 0.5 2 1 1 1 1
i1 115 4 10.00 0.5 2 1 1 1 1
; nqusa
i4 128 2 8.07 0.8
i4 130 3 8.09 0.8
i4 133 2 8.05 0.8
i4 135 2 8.07 0.8
i4 137 1 8.09 0.8
i4 138 1 8.11 0.8
i4 139 2 8.05 0.8
i4 141 1 8.04 0.8
i4 142 2 8.02 0.8
i4 144 1 8.00 0.8
i4 145 1 8.02 0.8
i4 146 2 8.00 0.8
i4 148 1 8.02 0.8
i4 149 1 7.11 0.8
i4 150 3 8.00 0.8
i4 153 1 8.04 0.8
i4 154 2 8.02 0.8
i4 156 1 8.00 0.8
i4 157 1 8.02 0.8
i4 158 1 8.04 0.8
i4 159 1 8.05 0.8
i4 160 1 8.07 0.8
i4 161 3 8.09 0.8
i4 164 2 8.11 0.8
i4 166 1 8.07 0.8
i4 167 1 8.05 0.8
i4 168 1 8.07 0.8
i4 169 2 8.05 0.8
i4 171 1 8.04 0.8
i4 172 2 8.07 0.8
i4 174 3 8.09 0.8
i4 177 1 8.07 0.8
i4 178 2 8.04 0.8
i4 180 2 8.02 0.8
i4 182 1 7.09 0.8
i4 183 1 7.11 0.8
i4 184 2 7.02 0.8
i4 186 1 6.04 0.8
i4 187 1 6.11 0.8
i4 188 1 6.04 0.8
i4 189 2 6.11 0.8
i4 191 3 7.02 0.8
i4 194 1 6.05 0.8
i4 195 2 6.04 0.8
i4 197 1 6.09 0.8
i4 198 1 6.11 0.8
i4 199 1 6.09 0.8
i4 200 1 6.11 0.8
i4 201 2 7.04 0.8
i4 203 1 7.05 0.8
i4 204 1 7.02 0.8
i4 205 1 6.11 0.8
i4 206 1 6.09 0.8
i4 207 1 7.02 0.8
i4 208 4 7.00 0.8
; cme_cl31
i5 224 1 8.00 0.5
i5 225 4 8.02 0.5
i5 229 1 8.04 0.5
i5 230 2 8.02 0.5
i5 232 1 8.00 0.5
i5 233 4 8.02 0.5
i5 237 3 8.04 0.5
i5 240 1 8.05 0.5
i5 241 1 8.09 0.5
i5 242 1 8.07 0.5
i5 243 1 8.09 0.5
i5 244 1 8.11 0.5
i5 245 2 8.09 0.5
i5 247 6 8.07 0.5
i5 253 3 8.09 0.5
i5 256 1 8.05 0.5
i5 257 3 8.09 0.5
i5 260 1 8.11 0.5
i5 261 4 9.00 0.5
i5 265 1 8.11 0.5
i5 266 1 9.00 0.5
i5 267 4 8.11 0.5
i5 271 2 9.00 0.5
i5 273 4 9.02 0.5
i5 277 2 9.04 0.5
i5 279 2 9.02 0.5
i5 281 1 9.04 0.5
i5 282 2 9.02 0.5
i5 284 1 9.04 0.5
i5 285 3 9.02 0.5
i5 288 1 8.11 0.5
i5 289 3 8.09 0.5
i5 292 5 8.11 0.5
i5 297 2 8.09 0.5
i5 299 1 8.07 0.5
i5 300 1 8.09 0.5
i5 301 3 8.07 0.5
i5 304 1 8.05 0.5
i5 305 1 8.07 0.5
i5 306 2 8.11 0.5
i5 308 3 8.09 0.5
i5 311 1 8.11 0.5
i5 312 3 8.09 0.5
i5 315 1 8.07 0.5
i5 316 2 8.04 0.5
i5 318 2 8.00 0.5
i5 320 1 8.04 0.5
i5 321 2 8.02 0.5
i5 323 5 8.04 0.5
i5 328 1 8.02 0.5
i5 329 1 8.04 0.5
i5 330 1 8.00 0.5
i5 331 1 7.11 0.5
i5 332 1 8.00 0.5
i5 333 1 8.02 0.5
; ice_oj3
i6 352 1 8.00 0.5
i6 353 4 8.02 0.5
i6 357 2 8.00 0.5
i6 359 3 8.02 0.5
i6 362 2 8.04 0.5
i6 364 1 8.02 0.5
i6 365 1 8.04 0.5
i6 366 3 8.05 0.5
i6 369 1 8.07 0.5
i6 370 4 8.09 0.5
i6 374 3 8.11 0.5
i6 377 1 8.09 0.5
i6 378 2 9.00 0.5
i6 380 2 9.02 0.5
i6 382 2 9.04 0.5
i6 384 3 9.02 0.5
i6 387 1 9.05 0.5
i6 388 1 9.07 0.5
i6 389 2 9.05 0.5
i6 391 1 9.07 0.5
i6 392 2 9.05 0.5
i6 394 4 9.04 0.5
i6 398 2 9.02 0.5
i6 400 4 9.04 0.5
i6 404 1 9.05 0.5
i6 405 1 9.04 0.5
i6 406 3 9.02 0.5
i6 409 5 9.04 0.5
i6 414 1 9.02 0.5
i6 415 2 9.04 0.5
i6 417 7 9.02 0.5
i6 424 1 9.00 0.5
i6 425 2 8.11 0.5
i6 427 1 8.07 0.5
i6 428 3 8.09 0.5
i6 431 1 8.07 0.5
i6 432 1 8.09 0.5
i6 433 2 8.11 0.5
i6 435 2 8.09 0.5
i6 437 1 8.07 0.5
i6 438 2 8.09 0.5
i6 440 8 8.11 0.5
</CsScore>
</CsoundSynthesizer>
