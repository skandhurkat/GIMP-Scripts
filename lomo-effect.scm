;lomo-effect.scm
;Copyright 2012, Skand Hurkat

;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.

;An example script for the lomo effect.
;This script increases contrast on the red and green channels, decreases contrast on the blue channel, and increases saturation on the image. It also adds a Vignette.

(define (script-fu-lomo-effect 	img
								drawable )

	;Set an undo group to undo the entire operation in one click
	(gimp-image-undo-group-start img)
  
	;Define some local variables to use in this script.
	;Please note that GIMP does not encourage global variables using "define", as that may lead to conflicts with other scripts.
	(let* (
			(original-foreground (car(gimp-context-get-foreground)))
			(curves-layer (car (gimp-layer-new-from-visible img img "Curves")))
			(vignette-group (car (gimp-layer-group-new img)))
			(img-height (car (gimp-image-height img)))
			(img-width (car (gimp-image-width img)))
			(vignette-white)
			(vignette-black))
			
		;And use the local variables here
		
		;Insert the curves-layer in the image
        (gimp-image-insert-layer img curves-layer 0 0)

        ;Modify the curves
        (gimp-curves-spline curves-layer HISTOGRAM-RED 8 #(0 0 60 30 190 220 255 255))
		(gimp-curves-spline curves-layer HISTOGRAM-GREEN 8 #(0 0 60 30 190 220 255 255))
		(gimp-curves-spline curves-layer HISTOGRAM-BLUE 8 #(0 0 30 60 220 190 255 255))
        ;Increase the saturation
        (gimp-hue-saturation curves-layer ALL-HUES 0 0 50)

        ;Now, add vignette layer group
		(gimp-item-set-name vignette-group "Vignette")
		(gimp-layer-set-mode vignette-group OVERLAY-MODE)
		(gimp-layer-set-opacity vignette-group 100)
		(gimp-image-insert-layer img vignette-group 0 0)
 
		;Now, for the vignette layers
		(set! vignette-white (car (gimp-layer-new img img-width img-height RGBA-IMAGE "White" 100 NORMAL-MODE)))
		(gimp-image-insert-layer img vignette-white vignette-group 0)
		(gimp-context-set-foreground '(255 255 255))
		(gimp-edit-blend vignette-white FG-TRANSPARENT-MODE NORMAL-MODE GRADIENT-RADIAL 100 0 REPEAT-NONE FALSE FALSE 1 0 TRUE (/ img-width 2) (/ img-height 2) (* img-width 1.5) (* img-height 1.5))
		(set! vignette-black (car (gimp-layer-new img img-width img-height RGBA-IMAGE "Black" 100 NORMAL-MODE)))
		(gimp-image-insert-layer img vignette-black vignette-group 0)
		(gimp-context-set-foreground '(0 0 0))
		(gimp-edit-blend vignette-black FG-TRANSPARENT-MODE NORMAL-MODE GRADIENT-RADIAL 100 0 REPEAT-NONE TRUE FALSE 1 0 TRUE (/ img-width 2) (/ img-height 2) img-width img-height)
		;Reset the foregound colour so that the user is none the wiser.
		(gimp-context-set-foreground original-foreground))

	;Refresh the display
	(gimp-displays-flush)
	
	;Finally, end the undo group
	(gimp-image-undo-group-end img)
)

; Register the script so that GIMP may use it.
(script-fu-register "script-fu-lomo-effect"
   "Lomo Effect"
   "Apply a Lomo effect to visible image"
   "Skand Hurkat"
   "© Skand Hurkat, 2012"
   "June 21, 2012"
   "RGB*"
   SF-IMAGE "Image" 0
   SF-DRAWABLE "Image to apply Lomo effect" 0)

; This script will appear as a filter named "Lomo Effect" in the Filters > Photography block
(script-fu-menu-register "script-fu-lomo-effect"
   "<Image>/Filters/Photography")
