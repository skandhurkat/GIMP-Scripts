;add-border.scm
;© Skand Hurkat, 2012

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

;This script adds a border by increasing the canvas size, moving the existing
;image to the centre, adding a layer to the bottom of the image, and painting
;it with the colour chosen by the user. The difference between this and the
;default script in the GIMP is that this script takes in border size in percentage
;which is the percentage of the smaller side. It produces a constant border.

(define (script-fu-add-border	img
                                drawable
                                borderPercentage
                                borderColour)

;Start undo group. This allows the entire operation to be undone using a single click
(gimp-image-undo-group-start img)

;define some local variables and use them
(let* (
		(imgWidth (car (gimp-image-width img)))
        (imgHeight (car (gimp-image-height img)))
		(imgDimension (if (< imgWidth imgHeight) imgWidth imgHeight))	;To store the smaller of the height/width.
												;This dimension is used to measure the border width.
		(borderWidth (round (/ (* imgDimension borderPercentage) 100)))
		(borderLayer (car (gimp-layer-new img (+ imgWidth (* 2 borderWidth)) (+ imgHeight (* 2 borderWidth)) RGB-IMAGE "Border Layer" 100 NORMAL-MODE)))
		(originalForeground (car(gimp-context-get-foreground))))
		
	(gimp-image-resize img (+ imgWidth (* 2 borderWidth)) (+ imgHeight (* 2 borderWidth)) borderWidth borderWidth)
	(gimp-image-insert-layer img borderLayer 0 (+ (car (gimp-image-get-layers img)) 1))
	(gimp-context-set-foreground borderColour)
	(gimp-edit-fill borderLayer FOREGROUND-FILL)
	;Reset the foregound colour so that the user is none the wiser.
	(gimp-context-set-foreground originalForeground))
	
	;And flush the display so as to reflect the changes
	(gimp-displays-flush)
	
	;Finally, end the undo group
	(gimp-image-undo-group-end img)
)

;Register the script that GIMP can use it
(script-fu-register
        "script-fu-add-border"
        "Add Border"
        "Adds a border to an image"
        "Skand Hurkat"
        "© Skand Hurkat, 2012"
        "July 9, 2012"
        ""
        SF-IMAGE "Image" 0
        SF-DRAWABLE "Image to apply the Border" 0
        SF-ADJUSTMENT "Border Percentage" '(15 0 100 1 5 0 SF-SLIDER)
        SF-COLOR "Border Colour" '(0 0 0))
(script-fu-menu-register "script-fu-add-border" "<Image>/Filters/Decor")        
