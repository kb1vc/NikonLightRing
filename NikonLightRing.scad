/*
  Nikon Light Ring
 
  Author: radiogeek381@gmail.com

  A widget that holds four 12V white LED strips on a ring
  that fits around the base of a Nikon binocular microscope
  with a 2.39 inch diameter ring.
*/ 
/*
Copyright (c) 2016, Matthew H. Reilly (kb1vc)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


// All dimensions are in inches -- scaling to mm is at the end.

// render round things kinda round
$fn = 32;

// These shouldn't require much.
InnerRingDia = 2.4;  // diameter of hole that fits around the mounting point
StripWidth = 0.41;   // width of the LED strip
LEDWidth = 0.2;      // LEDs are square -- this size
LEDSpace = 0.46;     // space between LEDs
MountThickness = 0.5; // thickness of ring
WallThickness = 0.1;  // how thick is the wall

WireX = 0.125; 
WireY = 0.25; 

SwitchHoleDia = 0.25; 

// Derived from above... don't mess with this.
BoxSize = StripWidth * 2 + InnerRingDia + 4 * WallThickness;
StripLength = BoxSize - 2 * WallThickness;

SwitchWidth = 0.75;
SwitchDepth = 1;
SwitchHeight = 1;


module show_text(string, loc) {
    translate([loc[0], loc[1], loc[2] - Text_Height]) {
        rotate([0,0,90]) {      
            linear_extrude(height=(2 * Text_Height)) {
                scale([0.015, 0.018, 0.15]) {
                    text(text = string, 
                    halign="center", valign="center", 
                    font="DejaVu LGC Sans:style=Bold");
                }
            }
        }
    }
}

module make_block() {
  OuterSquare = InnerRingDia + WallThickness * 8 + StripWidth;
  cube([BoxSize, BoxSize, MountThickness], center=true);
}

module make_centerhole() {
 translate([0, 0, -MountThickness]) {
    cylinder(d=InnerRingDia, h = MountThickness * 2);
  }
}

module make_lamphole(angle, pos) {
    XOffset = LEDWidth + LEDSpace;
    translate(pos) {
        rotate([0, 0, angle]) {
          union() {
            translate([0, 0, -MountThickness * 0.25]) {
              cube([LEDWidth, LEDWidth, MountThickness * 2], center=true);
            }
            translate([-XOffset, 0, -MountThickness * 0.25]) {
              cube([LEDWidth, LEDWidth, MountThickness * 2], center=true);
            }
            translate([XOffset, 0, -MountThickness * 0.25]) {
              cube([LEDWidth, LEDWidth, MountThickness * 2], center=true);
            }
          }
        }
    }
}

module make_lampholes() {
    RadialOffset = InnerRingDia * 0.5 + StripWidth * 0.5 + WallThickness;
    make_lamphole(0, [0, RadialOffset, 0]);
    make_lamphole(0, [0, -RadialOffset, 0]);
    make_lamphole(90, [RadialOffset, 0, 0]);
    make_lamphole(90, [-RadialOffset, 0, 0]);
}

module make_holes() {
    make_centerhole();
    make_lampholes();
}

module make_groove(angle, pos) {
  translate(pos) { 
    rotate([0, 0, angle]) {
      cube([StripLength, StripWidth, MountThickness], center=true);
    }
  }
}

module make_grooves() {
  RadialOffset = StripWidth / 2 + InnerRingDia / 2 + WallThickness; 
  NormalOffset = StripLength / 2;
  make_groove(0, [0, -RadialOffset, WallThickness]);
  make_groove(0, [0, RadialOffset, WallThickness]);
  make_groove(90, [- RadialOffset, 0, WallThickness]);
  make_groove(90, [RadialOffset, 0, WallThickness]);
}


module switch_box() {
    translate([0.5 * (BoxSize + SwitchWidth), 0, 0.5 * (-MountThickness +SwitchHeight)]) {
      difference() {
          cube([SwitchWidth, SwitchDepth, SwitchHeight], center=true);
          translate([- 0.25 * WallThickness, 0, WallThickness]) {
            cube([SwitchWidth - 2 * WallThickness, SwitchDepth - 2 * WallThickness, SwitchHeight - 2 * WallThickness + 0.005], center=true); 
          }
          translate([0.5 * SwitchWidth - 2 * WallThickness, 0, 0]) {
            rotate([0, 90, 0])
              cylinder(d = SwitchHoleDia, h = WallThickness * 4);
          }
          translate([0, 2 * WallThickness + 0.5 * SwitchDepth, 0]) {
            rotate([90, 0, 0])
              cylinder(d = SwitchHoleDia, h = WallThickness * 4);              
          }
    }
  }
}


module switch_box_notch() {
  SWHoleW = SwitchWidth;
  SWHoleD = SwitchDepth - 2 * WallThickness;
  ZOffset = SwitchHeight/2 - MountThickness/2 + WallThickness;
  translate([(BoxSize/2  - 0.005), 0, ZOffset]) {
      cube([SWHoleW, SWHoleD, SwitchHeight], center=true);
  }
}

module NikonLightRing() {
  difference() {
    union() {
      make_block();
      switch_box();
    }
    union() {
      make_grooves();
      make_holes();
      switch_box_notch();
    }
  }
}


scale([25.4,25.4,25.4]) {
    NikonLightRing();
}