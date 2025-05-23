// This shader was adapted from work by XorDev.
// https://x.com/XorDev
// Based on: https://x.com/XorDev/status/1923048330059227477
// https://www.xordev.com/
// [SGEORGET20250523170321]



uniform float _009_Speed<
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.05;
  float maximum = 2;
  float step = 0.01;
> = 1;


uniform int _009_Smoothing<
  string label = "Smoothing (2)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 1;
  int maximum = 4;
  int step = 1;
> = 2;


uniform int _009_Depth<
  string label = "Depth (120)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 50;
  int maximum = 200;
  int step = 1;
> = 90;


uniform int _009_Stripes<
  string label = "Stripes (6)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 1;
  int maximum = 20;
  int step = 1;
> = 6;


uniform float _009_Wireframe<
  string label = "Wireframe (1)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.1;
  float maximum = 10;
  float step = 0.01;
> = 1;


uniform float _009_Brightness<
  string label = "Brightness (1.3)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.5;
  float maximum = 3;
  float step = 0.1;
> = 1;



sampler_state textureSampler {
    Filter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

struct VertData {
    float4 pos : POSITION;
    float2 uv  : TEXCOORD0;
};

VertData mainTransform(VertData v_in) {
    return v_in;
}

float3 hueShift(float3 color, float angle) {
    float s = sin(angle);
    float c = cos(angle);

    // YIQ-like rotation around the luminance axis
    float3x3 hueRotation = float3x3(
        0.299 + 0.701 * c + 0.168 * s, 0.587 - 0.587 * c + 0.330 * s, 0.114 - 0.114 * c - 0.497 * s,
        0.299 - 0.299 * c - 0.328 * s, 0.587 + 0.413 * c + 0.035 * s, 0.114 - 0.114 * c + 0.292 * s,
        0.299 - 0.3   * c + 1.25  * s, 0.587 - 0.588 * c - 1.05  * s, 0.114 + 0.886 * c - 0.203 * s
    );

    return mul(color, hueRotation);
}




float4 mainImage(VertData v_in) : TARGET {
    float2 uv = v_in.uv;
    float2 size = uv_size;
    float t = elapsed_time * _009_Speed;

    // Fragment coordinates (Y-flipped)
    float2 fragCoord = float2(uv.x * size.x, (1.0 - uv.y) * size.y);
    float3 FC = float3(fragCoord, 0.5);
    float3 r = float3(size.x, size.y, size.y);

    float4 o = float4(0.0, 0.0, 0.0, 1.0);
    float z = 3.0;
    float d = 0.0;

    for (float i = 0.0; i < _009_Depth; i++) {
        float3 p = z * normalize(r - FC * 2.0) - 1.0;

        d = max(p.y, 0.0);
        p.y -= d + d;
        p.z += t;

        d += 1.0;
        float lenPart = length(float2(
            cos(p.z * _009_Stripes) / 6.0,
            1.0 - dot(cos(p), sin(p).yzx)
        )) / (d*d);

        d = 0.25 * (0.1 * d + 0.01 + lenPart* _009_Wireframe);
        z += pow(d,_009_Smoothing);

        float4 wave = cos(p.z + float4(0.0, 1.0, 3.0, 0.0)) + 1.5;

        // Sharpen line presence using exponential falloff
        float envelope = exp(-2.0 * d);
        float4 term = wave * envelope / (d * z);

        o += term;
    }

    o = tanh(o / 800.0*_009_Brightness);
    o.a = 1.0;
    float hueAngle = sin(elapsed_time*_009_Speed)*0.25;
    o.rgb = hueShift(o.rgb, hueAngle);

    return o;
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
