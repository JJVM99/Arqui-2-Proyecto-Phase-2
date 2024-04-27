.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
; ;Should store the X scroll amount
scroll: .res 1
; Stores the current settings that were sent to PPUCTRL, will be used later to switch between nametables
ppuctrl_settings: .res 1
;I may use all of this
generalcounter: .res 1
rowcounter: .res 1
mindex: .res 1
index: .res 1
mx: .res 1
my: .res 1
xb: .res 1
yb: .res 1
temp: .res 1
level: .res 1
tile: .res 1
tilecounter: .res 1
decreasecounter: .res 1
; .exportzp generalcounter
.exportzp generalcounter, rowcounter, mindex, index
.exportzp mx, my, xb, yb
.exportzp temp, level, tile, tilecounter, decreasecounter

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00
  STA $2005
  STA $2005
	LDA scroll
  ;did we reach the end (may need to switch to 255 later on)
	CMP #$00
	BNE set_scroll_positions
	LDA ppuctrl_settings
	EOR #%00000001 ; switch from nametable 2000 to 24000 (00 to 01)
	STA ppuctrl_settings
	STA PPUCTRL
	LDA #255 ;store max amount of horizontal pixels to scroll
	STA scroll

set_scroll_positions:
	; DEC scroll
	LDA scroll ; assign #255 to X scroll
	STA PPUSCROLL
	LDA #$00 ; initiate Y scroll to 0 since we will not use it
	STA PPUSCROLL

  RTI
.endproc

.import reset_handler
.import draw_map
.import determine_background_tile
; .import draw_backgrounds

.export main
.proc main
  LDA #$00
  ;initiate the new counters to 0
  STA generalcounter
  STA rowcounter
  STA mindex
  STA index
  STA mx
  STA my
  STA yb
  STA xb
  STA temp
  STA level
  STA tile
  STA tilecounter
  STA decreasecounter

  ;initiate values used in the scroll
  LDA #255
	STA scroll

  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

	; write nametables
	LDX #$20
  ; STA rowcounter
  ; STA tilecounter
  ; STA decreasecounter
  ;initiate y for the bytes
  LDY #$00
	JSR draw_map
  ; JSR draw_backgrounds

	LDX #$24
	JSR draw_map


vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
	STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
.export backgrounds
palettes:
.byte $0f, $24, $25, $11
.byte $0f, $30, $21, $31
.byte $0f, $37, $16, $26
.byte $0f, $2b, $1c, $36

.byte $0f, $11, $24, $31
.byte $0f, $12, $22, $32
.byte $0f, $13, $23, $33
.byte $0f, $2b, $1c, $36

backgrounds:
.byte %00000000 ;0
.byte %00000000 ;1
.byte %00000000 ;2
.byte %00000000 ;3
.byte %01010101 ;4
.byte %01010101 ;5
.byte %01010101 ;6
.byte %01010101 ;7
.byte %01101011 ;8
.byte %11111010 ;9
.byte %01010101 ;10
.byte %01010101 ;11
.byte %01101011 ;12
.byte %11111010 ;13
.byte %11111111 ;14
.byte %10101010 ;15
.byte %01101011 ;16
.byte %11111010 ;17
.byte %01010101 ;18
.byte %10101010 ;19
.byte %01101001 ;20
.byte %01010110 ;21
.byte %01010101 ;22
.byte %10101010 ;23
.byte %01101001 ;24
.byte %01010110 ;25
.byte %01010101 ;26
.byte %10101010 ;27
.byte %01101001 ;28
.byte %01010110 ;29
.byte %01010101 ;30
.byte %10101010 ;31
.byte %01101001 ;32
.byte %01010110 ;33
.byte %01010101 ;34
.byte %10101010 ;35
.byte %01101001 ;36
.byte %01010110 ;37
.byte %01010101 ;38
.byte %10101010 ;39
.byte %01101001 ;40
.byte %01010110 ;41
.byte %10101010 ;42
.byte %11111010 ;43
.byte %10101001 ;44
.byte %01010110 ;45
.byte %10101010 ;46
.byte %11111010 ;47
.byte %10101001 ;48
.byte %01010101 ;49
.byte %01010101 ;50
.byte %11111010 ;51
.byte %10101001 ;52
.byte %01010101 ;53
.byte %01010101 ;54
.byte %11111010 ;55
.byte %00000000 ;56
.byte %00000000 ;57
.byte %00000000 ;58
.byte %00000000 ;59


.segment "CHR"
.incbin "gamespritesphase2.chr"
