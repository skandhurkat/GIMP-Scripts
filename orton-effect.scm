;orton-effect.scm
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

;This is a script for simulating the Orton Effect.
;The Orton effect is a method to soften images by blending an overexposed, blurry image with the focused, correctly exposed image.
;© Skand Hurkat, 2012
;Licensed under GNU GPL V3.

(define (script-fu-orton-effect img
                                drawable
                                blurPercentage
                                opacity)

;Start undo group. This allows the entire operation to be undone using a single click
(gimp-image-undo-group-start img)

;Define some local variables
(let* (
        (overexposed (car (gimp-layer-new-from-visible img img "Overexposed")))
        (screenLayer (car (gimp-layer-copy overexposed FALSE)))
        (blurredLayer)
        (sharpLayer)
        (OrtonOverlay (car (gimp-layer-group-new img)))
        (imgWidth (car (gimp-image-width img)))
        (imgHeight (car (gimp-image-height img)))
        (blurRadius (/ (* (if (< imgWidth imgHeight) imgWidth imgHeight) blurPercentage) 100)))

;And use them
        (gimp-item-set-name OrtonOverlay "Orton Overlay")
        (gimp-layer-set-mode OrtonOverlay MULTIPLY-MODE)
        (gimp-layer-set-opacity OrtonOverlay opacity)
        (gimp-image-insert-layer img overexposed 0 0)
        (gimp-image-insert-layer img screenLayer 0 0)
        ;Brighten the image by around 1 stop
        (gimp-layer-set-mode screenLayer SCREEN-MODE)
        (set! overexposed (car (gimp-image-merge-down img screenLayer EXPAND-AS-NECESSARY)))
        ;Insert layer group into image
        (gimp-image-insert-layer img OrtonOverlay 0 0)
        ;Make a copy as sharp
        (set! sharpLayer (car (gimp-layer-copy overexposed FALSE)))
        (gimp-item-set-name sharpLayer "Sharp")
        (gimp-image-insert-layer img sharpLayer OrtonOverlay 0)
        ;Make another copy
        (set! blurredLayer (car (gimp-layer-copy overexposed FALSE)))
        (gimp-item-set-name blurredLayer "Blurred")
        (gimp-image-insert-layer img blurredLayer OrtonOverlay 0)
        ;Blur it
        (plug-in-gauss-iir2 RUN-NONINTERACTIVE img blurredLayer blurRadius blurRadius)
)

;Flush the display so as to display the result
(gimp-displays-flush)

;End the undo group
(gimp-image-undo-group-end img)
)

;Register the script that GIMP can use it
(script-fu-register
        "script-fu-orton-effect"
        "Orton Effect"
        "Softens a photograph using the Orton Effect"
        "Skand Hurkat"
        "© Skand Hurkat, 2012"
        "May 31, 2012"
        ""
        SF-IMAGE "Image" 0
        SF-DRAWABLE "Image to apply the Orton Effect" 0
        SF-ADJUSTMENT "Blur percentage" '(20 0 100 1 5 0 SF-SLIDER)
        SF-ADJUSTMENT "Opacity" '(30 0 100 1 5 0 SF-SLIDER))
(script-fu-menu-register "script-fu-orton-effect" "<Image>/Filters/Blur")        
