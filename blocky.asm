.include "defines.inc"

.define BIGDOOR_TILE $0bc
.define BIGDOOR_TILE2 $0c8
.define BIGDOOR_TILE3 $0d4
.define BIGDOOR_TILE4 $0e0
.define URN_TILE     $0ec

.code

PROC gen_blocky_puzzle
	LOAD_ALL_TILES $080, cave_border_tiles
	LOAD_ALL_TILES BIGDOOR_TILE, bigdoor_tiles
	LOAD_ALL_TILES URN_TILE, urn_tiles 
	; Load cave palette
	LOAD_PTR cave_palette
	jsr load_background_game_palette

	lsr gen_map_opening_locations
	; Generate the sides of the cave wall
	lda #$80 + BORDER_CENTER
	jsr gen_left_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_right_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_top_wall_bigdoor
	;jsr gen_top_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_bot_wall_1

	lda #0
	jsr gen_walkable_bot_path

	; Write our door in the open space
	; and make it interactive
	lda #INTERACT_BIGDOOR
	sta interactive_tile_types + 2
	lda #INTERACT_BIGDOOR
	sta interactive_tile_types + 3
	lda #INTERACT_BIGDOOR
	sta interactive_tile_types + 4

	;Make sure the open door variant is traversable
	lda #BIGDOOR_TILE4
	sta traversable_tiles
	lda #BIGDOOR_TILE4 + 4
	sta traversable_tiles + 1
	lda #BIGDOOR_TILE4 + 8
	sta traversable_tiles + 2

	ldx #6
	ldy #0
	lda #BIGDOOR_TILE
	clc
	adc blocky_door_state
	sta interactive_tile_values + 2
	jsr write_gen_map
	
	ldx #7
	ldy #0
	lda #BIGDOOR_TILE + 4
	clc
	adc blocky_door_state
	sta interactive_tile_values + 3
	jsr write_gen_map

	ldx #8
	ldy #0
	lda #BIGDOOR_TILE + 8
	clc
	adc blocky_door_state
	sta interactive_tile_values + 4
	jsr write_gen_map

	lda #$80
	jsr process_border_sides

	; Place the rows of urns and make them interactable
	lda #INTERACT_URN
	sta interactive_tile_types
	lda #INTERACT_URN
	sta interactive_tile_types + 1

	lda #URN_TILE
	sta interactive_tile_values
	lda #URN_TILE + 4
	sta interactive_tile_values + 1

	ldy #2
	jsr write_urn_row
	ldy #4
	jsr write_urn_row
	ldy #7
	jsr write_urn_row
	ldy #9
	jsr write_urn_row
	rts
.endproc

PROC write_urn_row
	ldx #2
loop_write_urn:
	cpx #14
	beq done
	;save x and y in arg2/3
	stx arg2
	sty arg3
	;determine which urn tile to use
	jsr is_urn_on
	cmp #0
	beq urn_off
	lda #URN_TILE
	jmp write_urn
urn_off:
	lda #URN_TILE + 4
write_urn:
	ldx arg2
	ldy arg3
	jsr write_gen_map
	inx
	inx
	jmp loop_write_urn
done:
	rts
.endproc

PROC gen_blocky_treasure
	LOAD_ALL_TILES $080, cave_border_tiles
	LOAD_ALL_TILES $0c0, treasure_tiles
	LOAD_ALL_TILES $0e0, urn_tiles 
	; Load cave palette
	LOAD_PTR cave_palette
	jsr load_background_game_palette

	; Generate the sides of the cave wall
	lda #$80 + BORDER_CENTER
	jsr gen_left_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_right_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_top_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_bot_wall_bigdoor

	lda #$80
	jsr process_border_sides


	; Place the treasure chest
	ldx #7
	ldy #3
	lda #$c0
	jsr write_gen_map

	; Place some urns around the room for some ambiance
	ldx #5
	ldy #3
	lda #$e0	
	jsr write_gen_map

	ldx #9
	ldy #3
	lda #$e0
	jsr write_gen_map

	ldx #3
	ldy #5
	lda #$e0	
	jsr write_gen_map

	ldx #11
	ldy #5
	lda #$e0
	jsr write_gen_map

	ldx #3
	ldy #8
	lda #$e0	
	jsr write_gen_map

	ldx #11
	ldy #8
	lda #$e0
	jsr write_gen_map
	
	rts
.endproc

PROC gen_left_wall_1
	sta arg4

	lda #0
	sta left_wall_top_extent
	sta left_wall_bot_extent
	sta arg0
	lda #0
	sta arg1
	lda #0
	sta arg2
	lda #MAP_HEIGHT-1
	sta arg3

	lda arg4
	jsr fill_map_box
	rts
.endproc

PROC gen_right_wall_1
	sta arg4

	lda #MAP_WIDTH-1
	sta left_wall_top_extent
	sta left_wall_bot_extent
	sta arg0
	lda #0
	sta arg1
	lda #MAP_WIDTH-1
	sta arg2
	lda #MAP_HEIGHT-1
	sta arg3

	lda arg4
	jsr fill_map_box
	rts
.endproc

PROC gen_top_wall_1
	sta arg4

	lda #1
	sta top_wall_left_extent
	sta top_wall_right_extent

	lda #0
	sta arg1
	lda #0
	sta arg3
	lda #0
	sta arg0
	lda #MAP_WIDTH-1
	sta arg2
	lda arg4
	jsr fill_map_box
	rts
.endproc

PROC gen_top_wall_bigdoor
	sta arg4

	lda #1
	sta top_wall_left_extent
	sta top_wall_right_extent

	lda #0
	sta arg1
	lda #0
	sta arg3
	lda #0
	sta arg0
	lda #5
	sta arg2
	lda arg4
	jsr fill_map_box

	lda #9
	sta arg0
	lda #0
	sta arg1
	lda #MAP_WIDTH-1
	sta arg2
	lda #0
	sta arg3
	lda arg4
	jsr fill_map_box

	rts
.endproc

PROC gen_bot_wall_bigdoor
	sta arg4

	lda #MAP_HEIGHT-1
	sta arg1

	sta bot_wall_left_extent
	sta bot_wall_right_extent
	lda #MAP_HEIGHT
	sta arg3
	lda #0
	sta arg0
	lda #5
	sta arg2
	lda arg4
	jsr fill_map_box

	lda #9
	sta arg0
	lda #MAP_HEIGHT-1
	sta arg1
	lda #MAP_WIDTH-1
	sta arg2
	lda #MAP_HEIGHT-1
	sta arg3
	lda arg4
	jsr fill_map_box

	rts
.endproc

PROC gen_bot_wall_1
	sta arg4

	lda #MAP_HEIGHT-1
	sta arg1

	sta bot_wall_left_extent
	sta bot_wall_right_extent
	lda #MAP_HEIGHT
	sta arg3
	lda #0
	sta arg0
	lda #MAP_WIDTH-1
	sta arg2
	lda arg4
	jsr fill_map_box
	rts
.endproc

PROC gen_walkable_bot_path
	sta arg4

	; Generate bottom opening
	lda top_opening_size
	lsr
	sta arg0
	lda top_opening_pos
	sec
	sbc arg0
	sta arg0
	clc
	adc top_opening_size
	adc #$ff
	sta arg2
	lda #MAP_HEIGHT - 1
	sta arg3
	sta arg1
	lda arg4
	jsr fill_map_box

	rts
.endproc

PROC urn_interact
	jsr wait_for_vblank

	ldx interaction_tile_x
	ldy interaction_tile_y
	jsr toggle_urn

	ldx interaction_tile_x
	ldy interaction_tile_y
	jsr is_urn_on
	cmp #0
	beq urn_off
	lda #URN_TILE
	jmp write_urn
urn_off:
	lda #URN_TILE + 4
write_urn:
	ldx interaction_tile_x
	ldy interaction_tile_y
	jsr write_large_tile

	jsr prepare_for_rendering
	rts
.endproc


;x = urns x value
;y = urns y value
PROC toggle_urn
	;trickery to get bit index of blocky_state from
	; urn x and y position
	txa
	sec
	sbc #2
	lsr
	asl
	asl
	sta temp

	tya
	sec
	sbc #2
	lsr
	ora temp
	sta temp
	lsr
	lsr
	lsr
	tax

	lda temp
	and #7
	tay

	;now we have the bit position y
	;and the byte position in x
	lda blocky_state, x
	eor toggleMask, y
	sta blocky_state, x
	rts
.endproc


;x = urns x value
;y = urns y value
; return 0 or non-zero in a
PROC is_urn_on
	; same tirckery as above
	txa
	sec
	sbc #2
	lsr
	asl
	asl
	sta temp

	tya
	sec
	sbc #2
	lsr
	ora temp
	sta temp
	lsr
	lsr
	lsr
	tax

	lda temp
	and #7
	tay

	;now we have the bit position y
	;and the byte position in x
	lda blocky_state, x
	and toggleMask, y
	rts
.endproc


PROC bigdoor_interact
	lda blocky_state
	cmp #$0ff
	beq opendoor
	rts
opendoor:
	ldx #30
	jsr wait_for_frame_count
	ldy #0
	ldx #6
	lda #BIGDOOR_TILE2
	jsr write_large_tile
	ldy #0
	ldx #7
	lda #BIGDOOR_TILE2 + 4
	jsr write_large_tile

	ldy #0
	ldx #8
	lda #BIGDOOR_TILE2 + 8
	jsr write_large_tile

	jsr prepare_for_rendering

	ldx #30
	jsr wait_for_frame_count
	ldy #0
	ldx #6
	lda #BIGDOOR_TILE3
	jsr write_large_tile
	ldy #0
	ldx #7
	lda #BIGDOOR_TILE3 + 4
	jsr write_large_tile

	ldy #0
	ldx #8
	lda #BIGDOOR_TILE3 + 8
	jsr write_large_tile

	jsr prepare_for_rendering
	ldx #30
	jsr wait_for_frame_count
	ldy #0
	ldx #6
	lda #BIGDOOR_TILE4
	jsr write_large_tile
	ldy #0
	ldx #7
	lda #BIGDOOR_TILE4 + 4
	jsr write_large_tile

	ldy #0
	ldx #8
	lda #BIGDOOR_TILE4 + 8
	jsr write_large_tile

	jsr prepare_for_rendering

	lda #3
	ora collision
	sta collision
	lda #$080
	ldx 1
	ora collision, x
	sta collision, x
	lda #36
	sta blocky_door_state
	rts
.endproc

PROC diplay_door_frame
	
.endproc
.bss

VAR blocky_state
	.byte 0, 0, 0

VAR blocky_door_state
	.byte 0
.data

VAR toggleMask
	.byte 1, 2, 4, 8, 16, 32, 64, 128

VAR blocky_urn
	.word always_interactable
	.word urn_interact

VAR blocky_bigdoor
	.word always_interactable
	.word bigdoor_interact
;VAR blocky_chest
;	.word blocky_chest_interactable
;	.word blodky_chest_interact

TILES bigdoor_tiles, 2, "tiles/cave/bigdoor.chr", 48
TILES treasure_tiles, 2, "tiles/cave/chest.chr", 8
TILES urn_tiles, 2, "tiles/cave/urn-orig.chr", 16