// This shader was adapted from work by Yonatan.
// https://x.com/zozuar
// Based on: https://x.com/zozuar/status/1430657958329917450
// [SGEORGET20250524231804]


uniform float _012_Speed<
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.05;
  float maximum = 2;
  float step = 0.01;
> = 0.2;

uniform float _012_Amplitude<
  string label = "Jellyfish Amplitude (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.01;
  float maximum = 0.3;
  float step = 0.01;
> = 0.2;

uniform float _012_FishDetail<
  string label = "Jellyfish Detail (3.0)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 2.5;
  float maximum = 15;
  float step = 0.01;
> = 3.0;


uniform float _012_Viewpoint<
  string label = "Viewpoint (0.5)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.10;
  float maximum = 1.0;
  float step = 0.01;
> = 0.5;


uniform int _012_Depth<
  string label = "Depth (10)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 10;
  int maximum = 90;
  int step = 1;
> = 10;

uniform float _012_Brightness<
  string label = "Brightness (1)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.10;
  float maximum = 5.0;
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

float3 hsv(float h, float s, float v) {
    float3 rgb = clamp(abs(frac(h + float3(0., 2./3., 1./3.)) * 6. - 3.) - 1., 0., 1.);
    return v * lerp(float3(1.,1.,1.), rgb, s);
}

float4 mainImage(VertData v_in) : TARGET {
    float2 size = uv_size;
    float t = elapsed_time * _012_Speed;
    float2 r = size;
    float2 FC = float2(v_in.uv.x * r.x, (1.0 - v_in.uv.y) * r.y);
    float4 o = 0;

    for (float i = _012_Depth, e, g = 0., s; i < 200.;i=i+1) {
        float3 p = float3((FC - r * _012_Viewpoint) / r.y * g + (_012_Viewpoint - 0.50 + 0.7), g += e);
        p.y -= t * 0.1;
        p -= round(p);
        p.xz *= 1. + sin(t * 3.14159 + (round(g) + p.y) * 10.) * _012_Amplitude;

        for (e = s = 9.; s < 400.; s += s) {
            e = s / 2000000. + min(e, max(-p.y, abs(length(p) - 0.20)) / s);
            p.y += length(p.xz) * 2.;
            p = 0.2 - abs(p * _012_FishDetail);
        }

        o.rgb += hsv(0.6 + 0.9 / p.y, 0.9, 0.000004 / e * _012_Brightness);
    }

    return float4(o.rgb, 1.0);
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
