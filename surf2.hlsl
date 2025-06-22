// "Surf 2" shader
// Original work by XorDev
//
// Golfed GLSL for ShaderToy:
// for(float z,d,i;i++<1e2;o+=(1.+cos(i*.7+t+vec4(6,1,2,0)))/d/i){
// vec3 p=z*normalize(FC.rgb*2.-r.xyx);p=vec3(atan(p.y,p.x)*2.,p.z
// /3.,length(p.xy)-6.);for(d=1.;d<9.;d++)p+=sin(p.yzx*d-t+.2*i)/d;
// z+=d=.2*length(vec4(.1*cos(p*3.)-.1,p.z));}o=tanh(o*o/9e2);
//
// https://x.com/XorDev/status/1936174781352517638
// Ported to OBS ShaderFilter HLSL
// [SGEORGET20250622130649]



uniform float _019_Speed< 
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 2;
  float step = 0.01;
> = 0.2;


uniform int _019_Iterations< 
  string label = "Iterations (100)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 1;
  int maximum = 120;
  int step = 1;
> = 100;



uniform int _019_Turbulence< 
  string label = "Iterations (7)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 1;
  int maximum = 12;
  int step = 1;
> = 7;




// Required for OBS ShaderFilter
sampler_state textureSampler
{
    Filter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

// Vertex input/output structure
struct VertData
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
};

// Vertex passthrough — no transformation applied
VertData mainTransform(VertData v_in)
{
    return v_in;
}

// Main pixel shader function
float4 mainImage(VertData v_in) : TARGET
{
    float2 r = v_in.uv * uv_size; // screen-space pixel position in pixels
    float t = elapsed_time * _019_Speed; // animation time
    float4 o = 0;                 // output color accumulator

    // Original GLSL: vec3 p = z * normalize(FC.rgb * 2. - r.xyx);
    // In HLSL we don't have FC.rgb, so we approximate using UV coordinates and center-relative position
    // This vector is fixed per pixel, not per iteration, but still approximates the GLSL behavior
    float2 uv = v_in.uv * (-2.0) + 1.0; // viewing direction from UV (centered). Flip y direction when porting from Twigl to OBS ShaderFilter
    uv.x /= uv_size.y / uv_size.x; // maintain 1:1 aspect
    float3 dir = normalize(float3(uv, 2.0));

    // Original GLSL: z is uninitialized and updated in the loop: z += d = ...
    // In HLSL, uninitialized means 0, which causes degenerate output. A small non-zero init fixes it.
    // Original GLSL: z is uninitialized and updated in the loop: z += d = ...
    // In HLSL, uninitialized means exactly 0.0, which leads to degenerate output:
    // - p = z * dir becomes zero -> all trigonometric distortion vanishes
    // - d becomes near-zero or undefined, causing either division artifacts or black screen
    // A small positive init (e.g. 0.01) kicks off meaningful displacement and allows the loop to evolve
    float z = 0.01;

    // Raymarching loop
    for (float i = 1.0; i <= _019_Iterations; i++)
    {

        float3 p = z * dir; // compute point along ray

        // Project into pseudo-spherical coordinates
        p = float3(
            atan2(p.y, p.x) * 2.0, // angle
            p.z / 3.0,             // scaled depth
            length(p.xy) - 6.0     // radial distance
        );

        float d = 0.0;
        // Add wave-like displacement to p
        for (float j = 1.0; j < _019_Turbulence; j++)
        {
            p += sin(p.yzx * j - t + 0.2 * i) / j;
        }

        // Compute step size from modulated point length
        d = 0.2 * length(float4(0.1 * cos(p * 3.0) - 0.1, p.z));
        z += d; // move forward along ray

        // Accumulate color based on position, time, and iteration count
        o += (1.0 + cos(i * 0.7 + t + float4(6, 1, 2, 0))) / d / i;
    }

    // Contrast compression and shaping
    o = tanh(o * o / 900.0);
    return float4(o.rgb, 1.0);
}

technique Draw
{
    pass
    {
        vertex_shader = mainTransform(v_in);
        pixel_shader = mainImage(v_in);
    }
}
