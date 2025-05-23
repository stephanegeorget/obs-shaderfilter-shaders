// This shader was copied and adapted from XorDev
// Twitter account: https://x.com/XorDev
// Exact Tweet: https://x.com/XorDev/status/1894123951401378051
// See also: https://www.xordev.com/
// [SGEORGET20250523153132]

// A good set of parameters is indicated in parenthesis
// => shows a zoomed part of the blob and pan around the screen,
// great for slow moving background with camera at the center.

uniform float _006_blob_speed<
  string label = "Blob Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.0;
  float maximum = 3.0;
  float step = 0.01;
> = 1;

uniform float _006_panning_speed<
  string label = "Panning Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.0;
  float maximum = 3.0;
  float step = 0.01;
> = 1;



uniform float _006_zoom<
  string label = "Zoom (1.5)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.1;
  float maximum = 3.0;
  float step = 0.01;
> = 1;

uniform float _006_vertical_amplitude<
  string label = "Vertical amplitude (1.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.0;
  float maximum = 3.0;
  float step = 0.01;
> = 0;


uniform float _006_horizontal_amplitude<
  string label = "Horizontal amplitude (1.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.0;
  float maximum = 3.0;
  float step = 0.01;
> = 0;


uniform float _006_offset_X<
  string label = "Offset X (0.4)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -3.0;
  float maximum = 3.0;
  float step = 0.01;
> = 0;


uniform float _006_offset_Y<
  string label = "Offset Y (0.5)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -3.0;
  float maximum = 3.0;
  float step = 0.01;
> = 0;


float4 mainImage(VertData v_in) : TARGET {
    
    float A = _006_vertical_amplitude;
    float B = _006_horizontal_amplitude;
    float C = _006_panning_speed;
    float offsetX = _006_offset_X;
    float offsetY = _006_offset_Y;

    float4 O = float4(0.0, 0.0, 0.0, 1.0);
    // Resolution for scaling
    float2 r = uv_size * _006_zoom;
    // Centered, ratio corrected, coordinates
    float2 p = ((v_in.uv * uv_size) + (v_in.uv * uv_size) - r) / r.y;
    // Apply circular panning motion
    float timeFactor = C * elapsed_time * _006_panning_speed;
    p.x += B * cos(timeFactor) + offsetX;
    p.y += A * sin(timeFactor) + offsetY;
    // Z depth
    float z = 0.0;
    // Iterator (x=0)
    float2 i = float2(0.0, 0.0);
    // Fluid coordinates
    float2 f = p * (z += 4.0 - 4.0 * abs(0.7 - dot(p, p)));
    
    // Clear frag color and loop 8 times
    for (O *= 0.0; i.y++ < 8.0;
        // Set color waves and line brightness
        O += (sin(f) + 1.0).xyyx * abs(f.x - f.y)) {
        // Add fluid waves
        f += cos(f.yx * i.y + i + elapsed_time * _006_blob_speed /2) / i.y + 0.7;
    }
    float4 tmpout = tanh(7.0 * exp(z - 4.0 - p.y * float4(-1.0, 1.0, 2.0, 0.0)) / O);
    // Tonemap, fade edges and color gradient
    tmpout = tmpout;
    return tmpout;
}
