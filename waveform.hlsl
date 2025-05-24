// This shader was adapted from work by XorDev.
// https://x.com/XorDev
// Based on: https://x.com/XorDev/status/1922728309944713334
// https://www.xordev.com/
// [SGEORGET20250524222325]


uniform float _011_Speed<
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.05;
  float maximum = 2;
  float step = 0.01;
> = 0.2;

uniform int _011_ParamA<
  string label = "Wave Shape - detail (30)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 1;
  int maximum = 50;
  int step = 1;
> = 30;

uniform float _011_ParamB<
  string label = "Wave Shape - amplitude (0.5)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 1;
  float step = 0.01;
> = 0.5;

uniform float _011_ParamC<
  string label = "Blur (0)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 1;
  float step = 0.01;
> = 0.0;

uniform float _011_ParamD<
  string label = "Reflection perspective (0)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -5;
  float maximum = 5;
  float step = 0.1;
> = 0;

uniform float _011_ParamE<
  string label = "Rainbow (0)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 2;
  float step = 0.1;
> = 0;

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

float4 mainImage(VertData v_in) : TARGET {
    float2 uv = v_in.uv;
    float2 size = uv_size;
    float t = elapsed_time * _011_Speed;

    float2 fragCoord = float2(uv.x * size.x, (1.0 - uv.y) * size.y);
    float3 r = float3(size.x, size.y, size.y);

    float4 O = float4(0, 0, 0, 1);
    float i = 0.0, d = 0.0, z = 0.0, refl = 0.0;

    for (O *= i; i++ < 90.0; O += (cos(z * (0.5 + _011_ParamE) + t + float4(0, 2, 4, 3)) + 1.3) / d / z) {
        float3 p = z * normalize(float3(fragCoord * 2.0, 0.0) - r);

        // Reflection
        refl = max(-++p, 0.1 + _011_ParamC).y;
        p.y += refl * (_011_ParamD +2);

        // Waveform logic
        for (d = 1.0; d < _011_ParamA; d += d) {
            float3 w = cos(p * d + 2.0 * t * cos(d) + z);
            p.y += w.x / d * _011_ParamB / 0.5;
        }

        d = (0.1 * refl + abs(p.y - 1.0) / (1.0 + refl + refl + refl * refl) + max(d = p.z + 3.0, -d * 0.1)) / 8.0;
        z += d;
    }

    O = tanh(O / 900.0);
    O.a = 1.0;
    return O;
}


technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
