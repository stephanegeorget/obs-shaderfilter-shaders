// This shader was adapted from work by XorDev.
// https://x.com/XorDev
// Based on: https://x.com/XorDev/status/1903091482904478140
// https://www.xordev.com/
// [SGEORGET20250523181938]


uniform float _010_Speed<
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.05;
  float maximum = 2;
  float step = 0.01;
> = 1;



uniform int _010_Style<
  string label = "Style (0)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 0;
  int maximum = 5;
  int step = 1;
> = 0;


uniform float _010_Zoom<
  string label = "Zoom (1.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.1;
  float maximum = 5;
  float step = 0.01;
> = 1.2;

uniform float _010_Amplitude<
  string label = "Amplitude (0.1)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.01;
  float maximum = 0.3;
  float step = 0.01;
> = 0.1;



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

// rotate3D using axis-angle approximation
float3 rotate3D(float3 v, float angle, float3 axis) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    float3x3 m = float3x3(
        oc * axis.x * axis.x + c,
        oc * axis.x * axis.y - axis.z * s,
        oc * axis.x * axis.z + axis.y * s,

        oc * axis.x * axis.y + axis.z * s,
        oc * axis.y * axis.y + c,
        oc * axis.y * axis.z - axis.x * s,

        oc * axis.x * axis.z - axis.y * s,
        oc * axis.y * axis.z + axis.x * s,
        oc * axis.z * axis.z + c
    );

    return mul(v, m);
}

float4 mainImage(VertData v_in) : TARGET {
    float2 uv = v_in.uv;
    float2 size = uv_size;
    float t = elapsed_time * _010_Speed;

    // 📐 Coordinate setup (Y-flipped)
    float2 fragCoord = float2(uv.x * size.x, (1.0 - uv.y) * size.y);
    float3 FC = float3(fragCoord, 0.5);
    float3 r = float3(size.x, size.y, size.y); // r.xyy

    float4 o = float4(0, 0, 0, 1);

    float3 p = float3(0, 0, 2); // p.z += 2.
    float3 v, a;
    float d;
    float increment = 0;

    for (float i = 0.; i++ < 100.; o += increment) {

    switch(_010_Style)
    {
        case 1: increment = 0.01 / exp(d * 100.0); break;
        case 2: increment = 0.01 / exp(sqrt(d) * 1.0); break;
        case 3: increment = 0.01 / exp(pow(d, 0.2) * 0.5); break;
        case 4: increment = 0.01 / exp(pow(d, 5) * 100000000); break;
        case 5: increment = 0.001 / exp(d * 100); break;
        default: increment = 0.01 / exp(d * d * 1000.0); break;
    }

        v = rotate3D(p, t * 0.2, float3(1.0, 1.0, 1.0));
        a = abs(v);
        float3 vmax = max(a, max(a.yzx, a.zxy));
        v = round(v / vmax / 0.1);
        d = length(p) - _010_Zoom - dot(cos(v), cos(v.yxz * 0.6 + t)) * _010_Amplitude;

        float3 dir = (FC * 2.0 - float3(r.x, r.y, r.y)) / r.y;
        p += dir * 0.1 * d;
    }

    o.a = 1.0;
    return o;
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
