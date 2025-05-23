# obs-shaderfilter-shaders
This repository contains my collection of HLSL shaders that work well with obs-shaderfilter (tested with 2.5.0).
It comes handy to create backgrounds in OBS studio.
These shaders do not modify a video source, they simply generate mesmerizing and peaceful blobs and colors.

Pre-requisites:
- obs studio
- obs-shaderfilter plugin

How to add a shader background:
- add a "color source"
- to that color source, add a filter
- select shaderfilter
- tick the box load shader text from file, point to one of the files in this repo, or copy-paste one of the shaders in the shader text box
- adjust parameters from the obs-shaderfilter user interface, although normally the default values should work ok

