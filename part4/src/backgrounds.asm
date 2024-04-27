.include "constants.inc"

.segment "ZEROPAGE"
; .importzp generalcounter
.importzp generalcounter, rowcounter, mindex, index
.importzp mx, my, xb, yb
.importzp temp, level, tile, tilecounter, decreasecounter

.segment "CODE"
.export draw_map
.proc draw_map

	; ;******DETERMINE LEVEL IN ANOTHER AREA****
	; ; ;load 1 digit binary
	; ; LDA %0
	; ;Store in variable level to switch later on between levels 1 and 2 and to determine which to load
	; STA level
	;load 8 digit binary that will be used to calculate the index (should it be binary or hex?)
	LDA #$00
	;initiate all the variables we will need
	STA index
	STA mindex
	;add the value of rowcounter to mxb and myb
	LDA rowcounter
	STA my
	STA mx
	;same thing for general counter and yb and xb
	LDA generalcounter
	STA yb
	STA xb
	;first off lets calculate mindex
	;mindex = my*4+mxb
	;my*4
	ASL my
	ASL my
	;mindex = mx
	CLC 
	ADC mx
	STA mindex
	;mindex += my
	CLC 
	ADC my
	STA mindex
	;My = mindex >> 2 aka mindex/4
	LDA mindex
	STA my
	LSR my
	LSR my
	;mx = mindex && 0x03 aka mindex %4
	;maybe consider just keeping it as 0
	LDA mx
	AND #$03
	STA mx
	;Index = 64*Myb + 8 *Mxb
	;64*myb
	LDA my
	ASL my
	ASL my
	ASL my
	ASL my
	ASL my
	STA index
	;8*mxb
	LDA mx
	ASL mx
	ASL mx
	ASL mx
	; index = index+ mx
	CLC 
	ADC mx
	STA index


	; ;Initiate PPUSTATUS and the high byte of the nametable to the PPUADDR
	; LDA PPUSTATUS
	; ;we take the nametable value stored in x before starting draw map (which would be #$20 or #$24 and put it in the accumulator to store it in the PPUADDR)
	; TXA
	; STA PPUADDR
	; ;do I add a section with carry values here in case it doesn't go past #$20 or #$24? probably should
	; LDA generalcounter
	; CLC
	; ADC #$06
	; STA generalcounter
	; LDA generalcounter
	; STA PPUADDR
	; ; JSR determine_background_tile
	; ;compare to see if we need to continue
	; INY
	; STA PPUDATA
	; ; CPY #$3c
	; CPY #$08
	; BNE draw_map

; spawn_background:
; 	;test spawn all backgrounds to see them
	LDA PPUSTATUS
	TXA 
	STA PPUADDR
	; ADC #$26
	LDA index
	STA PPUADDR
	; JSR determine_background_tile
	INY
	STY PPUDATA
	INX
	LDA generalcounter
	INC generalcounter
	LDA generalcounter
	; CMP #$3c
	CMP #$08
	BNE draw_map

	;attribute table
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$c2
	STA PPUADDR
	LDA #%11111111
	STA PPUDATA
	RTS
.endproc

; .export determine_background_tile
; .proc determine_background_tile
; ; 	;***should probably add a condition to determine which nametable I am saving later on
; 	; LDA %10101010
; 	LDA backgrounds,Y
; 	STA tile
; 	LDA tile
; 	; CPY #$00
; 	; BNE jump_initiate
; compare_tile:
; 	;eliminate all the tiles except for one
; 	AND %00000011
; 	STA tile
; 	LDA tile
; 	CMP %00000000
; 	BEQ tile_zero
; 	CMP %00000001
; 	BEQ tile_one
; 	CMP %00000010
; 	BEQ tile_two
; 	CMP %00000011
; 	BEQ jump_three
; 	JMP end_subroutine
; jump_three:
; 	JMP tile_three
; ; jump_initiate:
; ; 	JMP initiate_tile
; tile_zero:
; 	LDY #$01
; 	STY PPUDATA
; 	LDA PPUSTATUS
; 	LDA PPUADDR
; 	INC PPUADDR
; 	LDY #$02
; 	STY PPUDATA
; 	LDA PPUSTATUS
; 	CLC
; 	ADC #$20
; 	STA PPUADDR
; 	LDY #$11
; 	STY PPUDATA
; 	LDA PPUSTATUS
; 	LDA PPUADDR
; 	INC PPUADDR
; 	LDY #$12
; 	STY PPUDATA
; 	JMP dec_33
; tile_one:
; 	LDY #$03
; 	STY PPUDATA
; 	LDA PPUSTATUS
; 	LDA PPUADDR
; 	INC PPUADDR
; 	LDY #$04
; 	STY PPUDATA
; 	LDA PPUSTATUS
; 	CLC
; 	ADC #$20
; 	STA PPUADDR
; 	LDY #$13
; 	LDA PPUSTATUS
; 	STY PPUDATA
; 	LDA PPUADDR
; 	INC PPUADDR
; 	LDY #$14
; 	STY PPUDATA
; 	JMP dec_33
; tile_two:
; 	LDY #$05
; 	STY PPUDATA
; 	LDA PPUSTATUS
; 	LDA PPUADDR
; 	INC PPUADDR
; 	LDY #$06
; 	STY PPUDATA
; 	LDA PPUSTATUS
; 	CLC
; 	ADC #$20
; 	STA PPUADDR
; 	LDY #$15
; 	LDA PPUSTATUS
; 	STY PPUDATA
; 	LDA PPUADDR
; 	INC PPUADDR
; 	LDY #$16
; 	STY PPUDATA
; 	JMP dec_33
; tile_three:
; 	LDY #$07
; 	STY PPUDATA
; 	LDA PPUSTATUS
; 	LDA PPUADDR
; 	INC PPUADDR
; 	LDY #$08
; 	STY PPUDATA
; 	LDA PPUSTATUS
; 	CLC
; 	ADC #$20
; 	STA PPUADDR
; 	LDY #$17
; 	STY PPUDATA
; 	LDA PPUSTATUS
; 	LDA PPUADDR
; 	INC PPUADDR
; 	LDY #$18
; 	STY PPUDATA
; 	JMP dec_33
; ; initiate_tile:
; ; 	LDA PPUSTATUS
; ; 	LDA PPUADDR
; ; 	ADC #$08
; ; 	STA PPUADDR
; ; 	JMP compare_tile
; increase_tile:
; 	LDA PPUSTATUS
; 	LDA PPUADDR
; 	DEC PPUADDR
; 	DEC PPUADDR
; 	LDA tile
; 	LSR tile
; 	LSR tile
; 	LDA tilecounter
; 	INC tilecounter
; 	LDA tilecounter
; 	CMP #$03
; 	BNE jump_compare
; dec_33:
; 	LDA PPUADDR
; 	DEC PPUADDR
; 	LDA decreasecounter
; 	INC decreasecounter
; 	LDA decreasecounter
; 	CMP #$21
; 	BNE dec_33
; 	JMP increase_tile
; jump_compare:
; 	JMP compare_tile
; end_subroutine:
; 	INY
; 	INC tilecounter
; 	RTS
; .endproc

; .export draw_backgrounds
; .proc draw_backgrounds
; 	LDA PPUSTATUS
; 	TXA
; 	STA PPUADDR
; 	ADC #$08
; 	STA PPUADDR
; 	LDY #$01
; 	STY PPUDATA
; more_backgrounds:
; 	LDA PPUSTATUS
; 	TXA
; 	STA PPUADDR
; 	CLC
; 	ADC #$10
; 	STA PPUADDR
; 	INY
; 	STY PPUDATA
; 	LDA generalcounter
; 	INC generalcounter
; 	CMP #$10
; 	BNE more_backgrounds
; 	RTS
; .endproc

.segment "RODATA"
.import backgrounds